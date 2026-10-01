import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:openplants/core/locale_service.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/notifications/notification_entity.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';
import 'package:openplants/pages/notifications/notification_usecases.dart';

/// Reconciles OS reminders with the current care schedule and notification settings.
class NotificationReconciler {
  final NotificationRepository _repository;
  final NotificationUsecases _usecases;
  final CareScheduleRepository _careRepository;
  final CareScheduleUsecases _careSchedule;
  final SettingsController _settings;
  final LocaleService _localeService;

  Future<void> _pendingSync = Future<void>.value();

  NotificationReconciler({
    required NotificationRepository repository,
    required NotificationUsecases usecases,
    required CareScheduleRepository careRepository,
    required CareScheduleUsecases careSchedule,
    required SettingsController settings,
    required LocaleService localeService,
  })  : _repository = repository,
        _usecases = usecases,
        _careRepository = careRepository,
        _careSchedule = careSchedule,
        _settings = settings,
        _localeService = localeService;

  /// Serialize triggers and keep notification failures from failing saved user actions.
  Future<void> reconcileSafely() {
    return _pendingSync = _pendingSync.then((_) async {
      try {
        await reconcileCurrentState();
      } catch (error) {
        debugPrint('Failed to reconcile care notifications: $error');
      }
    });
  }

  /// Reconcile all reminders from persisted rules, tasks, settings, and locale.
  Future<void> reconcileCurrentState() async {
    final settings = _settings.settings;
    if (!settings.notificationsEnabled) {
      await reconcileAll(
        inputs: const [],
        notificationsEnabled: false,
        notifyDueTasks: settings.notifyDueTasks,
        notifyOverdueTasks: settings.notifyOverdueTasks,
      );
      return;
    }
    if (!_usecases.hasResolvedLocalTimezone) {
      debugPrint('Skipping care notification reconciliation because the local timezone is unavailable');
      return;
    }

    final schedule = await _careSchedule.getSchedule();
    final rules = await _careRepository.getAllCustomCareRules();
    final rulesByTask = {for (final rule in rules) '${rule.plantId}\u0000${rule.taskType}': rule};
    final localization = await AppLocalizations.delegate.load(_localeService.activeLocale);
    final now = tz.TZDateTime.now(tz.local);
    final inputs = <ReconcilerInput>[];

    for (final task in schedule.tasks) {
      final taskType = _taskTypeName(task.taskType);
      if (taskType == null) continue;
      final rule = rulesByTask['${task.plantId}\u0000$taskType'];
      if (rule == null || !rule.isEnabled || !rule.reminderEnabled) continue;

      final scheduledTime = nextReminderTime(
        dueDate: task.dueDate,
        reminderTime: rule.reminderTime,
        reminderDays: rule.reminderDays,
        now: now,
        location: tz.local,
      );
      if (scheduledTime == null) continue;

      inputs.add(
        ReconcilerInput(
          plantId: task.plantId,
          ruleId: rule.id,
          taskType: taskType,
          metricId: rule.metricId,
          scheduledTime: scheduledTime,
          isOverdue: task.status == CareTaskStatus.overdue,
          title: localization.notificationReminderTitle,
          body: localization.notificationReminderBody(
            _localizedTaskType(localization, task.taskType),
            task.plantName,
          ),
          channelName: localization.notificationsChannelName,
          channelDescription: localization.notificationsChannelDescription,
        ),
      );
    }

    await reconcileAll(
      inputs: inputs,
      notificationsEnabled: settings.notificationsEnabled,
      notifyDueTasks: settings.notifyDueTasks,
      notifyOverdueTasks: settings.notifyOverdueTasks,
    );
  }

  /// Schedule, update, and cancel the supplied reminders.
  Future<void> reconcileAll({
    required List<ReconcilerInput> inputs,
    required bool notificationsEnabled,
    required bool notifyDueTasks,
    required bool notifyOverdueTasks,
  }) async {
    if (!notificationsEnabled || !await _usecases.areNotificationsEnabled()) {
      await _usecases.cancelAll();
      return;
    }

    // Validate tracking before any cancellation so corrupt state never wipes OS alarms.
    final existingNotifications = await _repository.loadNotifications();
    final pendingNotifications = await _usecases.getPendingNotifications();
    final pendingById = {for (final notification in pendingNotifications) notification.id: notification};

    final existingById = {for (final notification in existingNotifications) notification.id: notification};
    final newIds = <int>{};

    for (final input in inputs) {
      if (input.isOverdue && !notifyOverdueTasks) continue;
      if (!input.isOverdue && !notifyDueTasks) continue;

      final notificationId = _repository.generateNotificationId(input.plantId, input.ruleId);
      final existing = existingById[notificationId];
      final payload = NotificationPayload(
        plantId: input.plantId,
        ruleId: input.ruleId,
        taskType: input.taskType,
        metricId: input.metricId,
      );
      final pending = pendingById[notificationId];
      final unchanged = pending != null &&
          pending.title == input.title &&
          pending.body == input.body &&
          pending.payload == payload.encode() &&
          existing != null &&
          existing.scheduledTime.isAtSameMomentAs(input.scheduledTime) &&
          existing.plantId == input.plantId &&
          existing.ruleId == input.ruleId &&
          existing.taskType == input.taskType &&
          existing.metricId == input.metricId &&
          existing.title == input.title &&
          existing.body == input.body;

      if (!unchanged) {
        await _usecases.scheduleNotification(
          id: notificationId,
          title: input.title,
          body: input.body,
          scheduledTime: input.scheduledTime,
          payload: payload,
          channelName: input.channelName,
          channelDescription: input.channelDescription,
        );
      }

      newIds.add(notificationId);
    }

    for (final notification in existingNotifications) {
      if (!newIds.contains(notification.id)) {
        await _usecases.cancelNotification(notification.id);
      }
    }

    for (final notification in pendingNotifications) {
      if (!newIds.contains(notification.id) && !existingById.containsKey(notification.id)) {
        await _usecases.cancelNotification(notification.id);
      }
    }
  }
}

/// Find the next configured weekday at or after a task's due date, in [location].
tz.TZDateTime? nextReminderTime({
  required DateTime dueDate,
  required String? reminderTime,
  required List<String>? reminderDays,
  required DateTime now,
  required tz.Location location,
}) {
  if (reminderTime == null || reminderDays == null || reminderDays.isEmpty) return null;
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(reminderTime);
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return null;

  const weekdays = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };
  final selectedWeekdays = reminderDays.map((day) => weekdays[day.toLowerCase()]).whereType<int>().toSet();
  if (selectedWeekdays.isEmpty) return null;

  final localNow = tz.TZDateTime.from(now, location);
  final localToday = DateTime(localNow.year, localNow.month, localNow.day);
  var firstDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  if (firstDate.isBefore(localToday)) firstDate = localToday;

  for (var offset = 0; offset <= 7; offset++) {
    final date = firstDate.add(Duration(days: offset));
    final candidate = tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
    if (selectedWeekdays.contains(candidate.weekday) && candidate.isAfter(localNow)) return candidate;
  }
  return null;
}

String? _taskTypeName(CareTaskType type) => type.builtIn?.name ?? type.customName;

String _localizedTaskType(AppLocalizations localization, CareTaskType type) {
  return switch (type.builtIn) {
    BuiltInTaskType.watering => localization.taskTypeWater,
    BuiltInTaskType.fertilizing => localization.taskTypeFertilize,
    BuiltInTaskType.misting => localization.taskTypeMist,
    BuiltInTaskType.pruning => localization.taskTypePrune,
    BuiltInTaskType.rotating => localization.taskTypeRotate,
    BuiltInTaskType.repotting => localization.taskTypeRepot,
    BuiltInTaskType.leafCleaning => localization.taskTypeClean,
    BuiltInTaskType.pestInspection => localization.taskTypeInspect,
    null => type.customName ?? '',
  };
}

/// Input data for reconciling a single notification.
class ReconcilerInput {
  final String plantId;
  final String ruleId;
  final String taskType;
  final String? metricId;
  final DateTime scheduledTime;
  final bool isOverdue;
  final String title;
  final String body;
  final String channelName;
  final String channelDescription;

  const ReconcilerInput({
    required this.plantId,
    required this.ruleId,
    required this.taskType,
    this.metricId,
    required this.scheduledTime,
    required this.isOverdue,
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });
}
