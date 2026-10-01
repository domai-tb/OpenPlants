import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:openplants/core/locale_service.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/core/exceptions.dart';
import 'package:openplants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/notifications/notification_datasource.dart';
import 'package:openplants/pages/notifications/notification_entity.dart';
import 'package:openplants/pages/notifications/notification_reconciler.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';
import 'package:openplants/pages/notifications/notification_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:openplants/pages/plant_journal/plant_journal_repository.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(timezone_data.initializeTimeZones);

  test('timezone refresh fails closed for an unknown system timezone', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = NotificationRepository(datasource: NotificationDataSource(prefs: preferences));
    final previousLocation = tz.local;
    const timezoneChannel = MethodChannel('openplants/local_timezone');
    var timezoneId = 'Europe/Berlin';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      timezoneChannel,
      (call) async => timezoneId,
    );
    addTearDown(() {
      tz.setLocalLocation(previousLocation);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(timezoneChannel, null);
    });
    final usecases = NotificationUsecases(
      repository: repository,
      plugin: FlutterLocalNotificationsPlugin(),
    );

    expect(await usecases.refreshLocalTimezone(), isTrue);
    expect(tz.local.name, 'Europe/Berlin');
    expect(usecases.hasResolvedLocalTimezone, isTrue);

    timezoneId = 'Unknown/Timezone';
    expect(await usecases.refreshLocalTimezone(), isFalse);
    expect(usecases.hasResolvedLocalTimezone, isFalse);
  });

  group('nextReminderTime', () {
    test('uses the next selected local day and configured wall time', () {
      final berlin = tz.getLocation('Europe/Berlin');
      final now = tz.TZDateTime(berlin, 2026, 1, 4, 8);

      final scheduled = nextReminderTime(
        dueDate: DateTime(2026, 1, 5),
        reminderTime: '09:15',
        reminderDays: ['monday'],
        now: now,
        location: berlin,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.year, 2026);
      expect(scheduled.month, 1);
      expect(scheduled.day, 5);
      expect(scheduled.weekday, DateTime.monday);
      expect(scheduled.hour, 9);
      expect(scheduled.minute, 15);
    });

    test('keeps the configured wall time across the spring DST change', () {
      final berlin = tz.getLocation('Europe/Berlin');
      final now = tz.TZDateTime(berlin, 2026, 3, 28, 10);

      final scheduled = nextReminderTime(
        dueDate: DateTime(2026, 3, 29),
        reminderTime: '09:00',
        reminderDays: ['sunday'],
        now: now,
        location: berlin,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.hour, 9);
      expect(scheduled.timeZoneOffset, const Duration(hours: 2));
    });

    test('ignores missing or invalid reminder details', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026);
      DateTime? next(String? time, List<String>? days) => nextReminderTime(
            dueDate: DateTime(2026, 1, 2),
            reminderTime: time,
            reminderDays: days,
            now: now,
            location: location,
          );

      expect(next(null, ['friday']), isNull);
      expect(next('09:00', null), isNull);
      expect(next('9:00', ['friday']), isNull);
      expect(next('25:00', ['friday']), isNull);
      expect(next('09:00', ['funday']), isNull);
    });

    test('finds the next week when today is selected but its reminder time passed', () {
      final location = tz.getLocation('UTC');
      final now = tz.TZDateTime(location, 2026, 1, 4, 10);

      final scheduled = nextReminderTime(
        dueDate: DateTime(2026, 1, 4),
        reminderTime: '09:00',
        reminderDays: ['sunday'],
        now: now,
        location: location,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.day, 11);
      expect(scheduled.hour, 9);
    });
  });

  group('NotificationReconciler', () {
    test('does not change existing reminders before the local timezone is resolved', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final fixture = await _createFixture(preferences);
      await fixture.repository.saveNotification(
        ScheduledNotification(
          id: 1,
          plantId: 'plant-1',
          ruleId: 'rule-1',
          taskType: 'watering',
          scheduledTime: DateTime(2026, 12, 7, 9),
        ),
      );
      fixture.notifications.hasLocalTimezone = false;

      await fixture.reconciler.reconcileSafely();

      expect(await fixture.repository.loadNotifications(), hasLength(1));
      expect(fixture.notifications.cancelled, isEmpty);
      expect(fixture.notifications.cancelAllCount, 0);
      fixture.dispose();
    });

    test('reschedules changed times and localized text using the same ID', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final fixture = await _createFixture(preferences);
      final scheduledTime = DateTime(2026, 12, 7, 9);
      ReconcilerInput input({DateTime? time, String body = 'Water for Fern'}) => ReconcilerInput(
            plantId: 'plant-1',
            ruleId: 'rule-1',
            taskType: 'watering',
            scheduledTime: time ?? scheduledTime,
            isOverdue: false,
            title: 'Care reminder',
            body: body,
            channelName: 'Care reminders',
            channelDescription: 'Plant reminders',
          );

      Future<void> reconcile(ReconcilerInput item) => fixture.reconciler.reconcileAll(
            inputs: [item],
            notificationsEnabled: true,
            notifyDueTasks: true,
            notifyOverdueTasks: true,
          );

      await reconcile(input());
      await reconcile(input());
      expect(fixture.notifications.scheduled, hasLength(1));

      final stableId = fixture.notifications.scheduled.single.id;
      await reconcile(input(time: scheduledTime.add(const Duration(days: 7)), body: 'Water the Fern'));

      expect(fixture.notifications.scheduled, hasLength(2));
      expect(fixture.notifications.scheduled.last.id, stableId);
      final stored = (await fixture.repository.loadNotifications()).single;
      expect(stored.scheduledTime, scheduledTime.add(const Duration(days: 7)));
      expect(stored.body, 'Water the Fern');
      fixture.dispose();
    });

    test('restores a tracked reminder missing from OS pending requests', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final fixture = await _createFixture(preferences);
      final input = ReconcilerInput(
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        scheduledTime: DateTime(2026, 12, 7, 9),
        isOverdue: false,
        title: 'Care reminder',
        body: 'Water for Fern',
        channelName: 'Care reminders',
        channelDescription: 'Plant reminders',
      );
      final id = fixture.repository.generateNotificationId(input.plantId, input.ruleId);
      await fixture.repository.saveNotification(
        ScheduledNotification(
          id: id,
          plantId: input.plantId,
          ruleId: input.ruleId,
          taskType: input.taskType,
          scheduledTime: input.scheduledTime,
          title: input.title,
          body: input.body,
        ),
      );

      await fixture.reconciler.reconcileAll(
        inputs: [input],
        notificationsEnabled: true,
        notifyDueTasks: true,
        notifyOverdueTasks: true,
      );

      expect(fixture.notifications.scheduled, hasLength(1));
      expect(fixture.notifications.pending, contains(id));
      fixture.dispose();
    });

    test('does not cancel OS notifications when tracking data is corrupt', () async {
      SharedPreferences.setMockInitialValues({'scheduled_notifications_v1': '{broken'});
      final preferences = await SharedPreferences.getInstance();
      final fixture = await _createFixture(preferences);
      final input = ReconcilerInput(
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        scheduledTime: DateTime(2026, 12, 7, 9),
        isOverdue: false,
        title: 'Care reminder',
        body: 'Water for Fern',
        channelName: 'Care reminders',
        channelDescription: 'Plant reminders',
      );

      await expectLater(
        fixture.reconciler.reconcileAll(
          inputs: [input],
          notificationsEnabled: true,
          notifyDueTasks: true,
          notifyOverdueTasks: true,
        ),
        throwsA(isA<CollectionDecodeFailure>()),
      );

      expect(fixture.notifications.scheduled, isEmpty);
      expect(fixture.notifications.cancelled, isEmpty);
      expect(fixture.notifications.cancelAllCount, 0);
      fixture.dispose();
    });

    test('cancels OS notifications when disabled even if tracking data is corrupt', () async {
      SharedPreferences.setMockInitialValues({'scheduled_notifications_v1': '{broken'});
      final preferences = await SharedPreferences.getInstance();
      final fixture = await _createFixture(preferences);

      await fixture.reconciler.reconcileAll(
        inputs: const [],
        notificationsEnabled: false,
        notifyDueTasks: true,
        notifyOverdueTasks: true,
      );

      expect(fixture.notifications.cancelAllCount, 1);
      expect(preferences.getString('scheduled_notifications_v1'), '[]');
      fixture.dispose();
    });
  });

  test('tracking persistence failure is preserved when plugin cleanup also fails', () async {
    SharedPreferences.setMockInitialValues({'scheduled_notifications_v1': '{broken'});
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    const pluginChannel = MethodChannel('dexterous.com/flutter/local_notifications');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pluginChannel,
      (call) async {
        calls.add(call.method);
        if (call.method == 'cancel') throw PlatformException(code: 'cancel_failed');
        return null;
      },
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pluginChannel, null);
    });

    final preferences = await SharedPreferences.getInstance();
    final repository = NotificationRepository(datasource: NotificationDataSource(prefs: preferences));
    final usecases = NotificationUsecases(
      repository: repository,
      plugin: FlutterLocalNotificationsPlugin(),
    );
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));

    await expectLater(
      usecases.scheduleNotification(
        id: 1,
        title: 'Care reminder',
        body: 'Water for Fern',
        scheduledTime: scheduledTime,
        payload: const NotificationPayload(
          plantId: 'plant-1',
          ruleId: 'rule-1',
          taskType: 'watering',
        ),
        channelName: 'Care reminders',
        channelDescription: 'Plant reminders',
      ),
      throwsA(isA<CollectionDecodeFailure>()),
    );

    expect(calls, ['zonedSchedule', 'cancel']);
  });
}

Future<_ReconcilerFixture> _createFixture(SharedPreferences preferences) async {
  final notificationRepository = NotificationRepository(
    datasource: NotificationDataSource(prefs: preferences),
  );
  final notifications = _FakeNotificationUsecases(notificationRepository);
  final careRepository = CareScheduleRepository(dataSource: CareScheduleDataSource(prefs: preferences));
  final settings = await SettingsController.load();
  final localeService = LocaleService(settings);
  final careSchedule = CareScheduleUsecases(
    repository: careRepository,
    plantCollection: PlantCollectionUsecases(
      repository: PlantCollectionRepository(dataSource: PlantCollectionDataSource(prefs: preferences)),
    ),
    plantJournal: PlantJournalUseCases(
      repository: PlantJournalRepository(dataSource: PlantJournalDataSource(prefs: preferences)),
    ),
  );

  return _ReconcilerFixture(
    reconciler: NotificationReconciler(
      repository: notificationRepository,
      usecases: notifications,
      careRepository: careRepository,
      careSchedule: careSchedule,
      settings: settings,
      localeService: localeService,
    ),
    notifications: notifications,
    repository: notificationRepository,
    settings: settings,
    localeService: localeService,
  );
}

class _ReconcilerFixture {
  final NotificationReconciler reconciler;
  final _FakeNotificationUsecases notifications;
  final NotificationRepository repository;
  final SettingsController settings;
  final LocaleService localeService;

  const _ReconcilerFixture({
    required this.reconciler,
    required this.notifications,
    required this.repository,
    required this.settings,
    required this.localeService,
  });

  void dispose() {
    localeService.dispose();
    settings.dispose();
  }
}

class _FakeNotificationUsecases extends Fake implements NotificationUsecases {
  final NotificationRepository repository;
  final scheduled = <({int id, DateTime time, String title, String body})>[];
  final cancelled = <int>[];
  final pending = <int, PendingNotificationRequest>{};
  int cancelAllCount = 0;
  bool hasLocalTimezone = true;

  _FakeNotificationUsecases(this.repository);

  @override
  bool get hasResolvedLocalTimezone => hasLocalTimezone;

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async => pending.values.toList();

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationPayload payload,
    required String channelName,
    required String channelDescription,
  }) async {
    scheduled.add((id: id, time: scheduledTime, title: title, body: body));
    pending[id] = PendingNotificationRequest(id, title, body, payload.encode());
    await repository.saveNotification(
      ScheduledNotification(
        id: id,
        plantId: payload.plantId,
        ruleId: payload.ruleId,
        taskType: payload.taskType,
        metricId: payload.metricId,
        scheduledTime: scheduledTime,
        title: title,
        body: body,
      ),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
    pending.remove(id);
    await repository.deleteNotification(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    pending.clear();
    await repository.clearAll();
  }
}
