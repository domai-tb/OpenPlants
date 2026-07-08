import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/widgets/care_task_card.dart';
import 'package:open_plant/pages/care_schedule/widgets/empty_schedule_state.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_extensions.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Care schedule page — dashboard showing overdue, due-today, and upcoming tasks.
class CareSchedulePage extends StatefulWidget {
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  /// Optional callback: navigate to the Plant Collection tab from the empty state.
  final VoidCallback? onNavigateToPlantCollection;

  /// Notifies this page to reload data after a tab switch.
  final Listenable? tabSwitchNotifier;

  const CareSchedulePage({
    super.key,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.onNavigateToPlantCollection,
    this.tabSwitchNotifier,
  });

  @override
  State<CareSchedulePage> createState() => _CareSchedulePageState();
}

class _CareSchedulePageState extends State<CareSchedulePage> with AutomaticKeepAliveClientMixin<CareSchedulePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  late CareScheduleUsecases _usecases;
  bool _wired = false;

  List<CareTask> _tasks = [];
  List<String> _plantNames = [];
  List<SymptomLogEntry> _recentSymptoms = [];
  bool _loading = true;
  String? _selectedPlantId;
  BuiltInTaskType? _selectedTaskType;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.careSchedule;
    _wired = true;
    widget.tabSwitchNotifier?.addListener(_reloadOnTabSwitch);
    _load();
  }

  void _reloadOnTabSwitch() {
    _load();
  }

  @override
  void dispose() {
    widget.tabSwitchNotifier?.removeListener(_reloadOnTabSwitch);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _usecases.getSchedule();
      if (!mounted) return;

      // Load recent symptom entries for the timeline
      final symptomLogger = AppScope.of(context).services.symptomLogger;
      final allSymptoms = await symptomLogger.getAllSymptoms();
      allSymptoms.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final plantNames = tasks.map((t) => t.plantName).toSet().toList()..sort();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _plantNames = plantNames;
        _recentSymptoms = allSymptoms.take(20).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<CareTask> get _filteredTasks {
    var tasks = _tasks;

    if (_selectedPlantId != null) {
      tasks = tasks.where((t) => t.plantId == _selectedPlantId).toList();
    }

    if (_selectedTaskType != null) {
      tasks = tasks.where((t) => t.taskType.builtIn == _selectedTaskType).toList();
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return AnimatedExit(
      key: widget.pageExitAnimationKey,
      child: AnimatedEntry(
        key: widget.pageEntryAnimationKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.careScheduleTitle),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _tasks.isEmpty && _recentSymptoms.isEmpty
                  ? EmptyScheduleState(
                      onNavigateToPlantCollection: widget.onNavigateToPlantCollection,
                    )
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _load,
                      child: _buildContent(theme),
                    ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final filtered = _filteredTasks;
    final overdue = filtered.where((t) => t.status == CareTaskStatus.overdue).toList();
    final dueToday = filtered.where((t) => t.status == CareTaskStatus.dueToday).toList();
    final upcoming = filtered.where((t) => t.status == CareTaskStatus.upcoming).toList();

    return Column(
      children: [
        _buildFilters(theme),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (overdue.isNotEmpty) ...[
                _buildSectionHeader(theme, context.l10n.careScheduleOverdue, Colors.red),
                ...overdue.map(
                  (task) => CareTaskCard(
                    task: task,
                    onDone: () => _completeTask(task),
                    onSnooze: (days) => _snoozeTask(task, days),
                    onSkip: () => _skipTask(task),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (dueToday.isNotEmpty) ...[
                _buildSectionHeader(theme, context.l10n.careScheduleDueToday, Colors.orange),
                ...dueToday.map(
                  (task) => CareTaskCard(
                    task: task,
                    onDone: () => _completeTask(task),
                    onSnooze: (days) => _snoozeTask(task, days),
                    onSkip: () => _skipTask(task),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                _buildSectionHeader(theme, context.l10n.careScheduleUpcoming, Colors.green),
                ...upcoming.map(
                  (task) => CareTaskCard(
                    task: task,
                    onDone: () => _completeTask(task),
                    onSnooze: (days) => _snoozeTask(task, days),
                    onSkip: () => _skipTask(task),
                  ),
                ),
              ],
              if (overdue.isEmpty && dueToday.isEmpty && upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(context.l10n.careScheduleEmpty),
                  ),
                ),

              // Recent health events section
              if (_recentSymptoms.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(theme, context.l10n.symptomLoggerRecentEvents, Colors.purple),
                ..._recentSymptoms.take(5).map(_buildSymptomEventTile),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomEventTile(SymptomLogEntry entry) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.15),
          child: const Icon(Icons.healing, color: Colors.purple, size: 20),
        ),
        title: Text(
          entry.symptomTypes.map((t) => t.label(context)).join(', '),
          style: theme.textTheme.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${entry.severity.label(context)} • ${_formatDate(entry.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: entry.resolved
            ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
            : const Icon(Icons.circle_outlined, color: Colors.orange, size: 18),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSectionHeader(ThemeData theme, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String?>(
              value: _selectedPlantId,
              isExpanded: true,
              hint: Text(context.l10n.careScheduleAllPlants),
              items: [
                DropdownMenuItem<String?>(
                  child: Text(context.l10n.careScheduleAllPlants),
                ),
                ..._plantNames.map((name) {
                  final id = _tasks
                      .firstWhere(
                        (t) => t.plantName == name,
                        orElse: () => _tasks.first,
                      )
                      .plantId;
                  return DropdownMenuItem<String?>(
                    value: id,
                    child: Text(name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedPlantId = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<BuiltInTaskType?>(
              value: _selectedTaskType,
              isExpanded: true,
              hint: Text(context.l10n.careScheduleAllTypes),
              items: [
                DropdownMenuItem<BuiltInTaskType?>(
                  child: Text(context.l10n.careScheduleAllTypes),
                ),
                ...BuiltInTaskType.values.map(
                  (type) => DropdownMenuItem<BuiltInTaskType?>(
                    value: type,
                    child: Text(type.label),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedTaskType = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTask(CareTask task) async {
    await _usecases.completeTask(task: task);
    if (!mounted) return;
    await _load();
  }

  Future<void> _snoozeTask(CareTask task, int days) async {
    await _usecases.snoozeTask(task: task, days: days);
    if (!mounted) return;
    await _load();
  }

  Future<void> _skipTask(CareTask task) async {
    await _usecases.skipTask(task: task);
    if (!mounted) return;
    await _load();
  }
}
