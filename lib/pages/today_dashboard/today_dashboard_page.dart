import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_page.dart';
import 'package:open_plant/pages/home/home_page.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/today_dashboard/plant_grid_section.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_detail_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';
import 'package:open_plant/pages/plant_identification/plant_identification_page.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_usecases.dart';

class TodayDashboardPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  /// Notifies this page to reload data after a tab switch.
  final Listenable? tabSwitchNotifier;

  const TodayDashboardPage({
    super.key,
    required this.mainNavigatorKey,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.tabSwitchNotifier,
  });

  @override
  State<TodayDashboardPage> createState() => _TodayDashboardPageState();
}

class _TodayDashboardPageState extends State<TodayDashboardPage>
    with AutomaticKeepAliveClientMixin<TodayDashboardPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<PlantGridSectionState> _plantGridKey = GlobalKey<PlantGridSectionState>();
  final ScrollController _scrollController = ScrollController();

  late TodayDashboardUsecases _usecases;
  bool _wired = false;

  DashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.todayDashboard;
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _usecases.getDashboardData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AnimatedExit(
      key: widget.pageExitAnimationKey,
      child: AnimatedEntry(
        key: widget.pageEntryAnimationKey,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: _buildBody(theme, l10n),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddPlant() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlantCollectionFormPage()),
    );
    if (mounted) {
      await _load();
      await _plantGridKey.currentState?.reload();
    }
  }

  Future<void> _openPlantDetail(String plantId) async {
    final usecases = AppScope.of(context).services.plantCollection;
    try {
      final plants = await usecases.loadPlants();
      if (!mounted) return;
      final plant = plants.firstWhere(
        (p) => p.id == plantId,
        orElse: () => throw PlantNotFoundException(plantId),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlantCollectionDetailPage(plant: plant)),
      );
      if (mounted) {
        await _load();
        await _plantGridKey.currentState?.reload();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant not found')),
      );
    }
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_loading) {
      return _buildLoadingState(theme);
    }

    if (_error != null) {
      return _buildErrorState(theme, l10n);
    }

    final data = _data;
    if (data == null || data.isEmpty) {
      return _OnboardingEmptyState(
        onNavigateToAddPlant: _openAddPlant,
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _load,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(theme, l10n),
                const SizedBox(height: 8),
                _QuickActionStrip(
                  onNavigateToAddPlant: _openAddPlant,
                ),
                const SizedBox(height: 24),
                if (data.dueToday.isNotEmpty)
                  _DueTasksSection(
                    tasks: data.dueToday,
                    onNavigateToPlantDetail: _openPlantDetail,
                  ),
                if (data.overdue.isNotEmpty)
                  _OverdueTasksSection(
                    tasks: data.overdue,
                    onNavigateToPlantDetail: _openPlantDetail,
                  ),
                // Plant grid replaces the recent plants carousel.
                PlantGridSection(
                  key: _plantGridKey,
                  onNavigateToPlantDetail: _openPlantDetail,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Text(
        l10n.todayDashboardTitle,
        style: theme.textTheme.displayMedium,
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorMessage,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.plantIdTryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 60,
      ),
      child: ListView(
        children: [
          _buildHeader(theme, context.l10n),
          const SizedBox(height: 24),
          _buildShimmerBlock(theme, height: 48),
          const SizedBox(height: 24),
          _buildShimmerBlock(theme),
          const SizedBox(height: 12),
          _buildShimmerBlock(theme),
          const SizedBox(height: 12),
          _buildShimmerBlock(theme, width: 200),
        ],
      ),
    );
  }

  Widget _buildShimmerBlock(
    ThemeData theme, {
    double height = 72,
    double? width,
  }) {
    return _ShimmerPlaceholder(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Shimmer Placeholder ────────────────────────────────────────────────────

class _ShimmerPlaceholder extends StatefulWidget {
  final Widget child;

  const _ShimmerPlaceholder({required this.child});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Quick Action Strip ─────────────────────────────────────────────────────

class _QuickActionStrip extends StatelessWidget {
  final VoidCallback? onNavigateToAddPlant;

  const _QuickActionStrip({
    this.onNavigateToAddPlant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_circle_outline,
              label: l10n.quickAddPlant,
              color: theme.colorScheme.primary,
              onTap: () {
                onNavigateToAddPlant?.call();
              },
            ),
          ),
          const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_outlined,
                label: l10n.quickIdentify,
                color: theme.colorScheme.secondary,
                onTap: () {
                  PlantIdentificationPage.showAsModal(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.healing_outlined,
                label: l10n.quickDiagnose,
                color: theme.colorScheme.tertiary,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const DiagnosisPage()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Due Tasks Section ──────────────────────────────────────────────────────

class _DueTasksSection extends StatelessWidget {
  final List<CareTask> tasks;
  final ValueChanged<String>? onNavigateToPlantDetail;

  const _DueTasksSection({
    required this.tasks,
    this.onNavigateToPlantDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dueToday,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CareTaskCard(
                task: task,
                isOverdue: false,
                onNavigateToPlantDetail: onNavigateToPlantDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overdue Tasks Section ──────────────────────────────────────────────────

class _OverdueTasksSection extends StatelessWidget {
  final List<CareTask> tasks;
  final ValueChanged<String>? onNavigateToPlantDetail;

  const _OverdueTasksSection({
    required this.tasks,
    this.onNavigateToPlantDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.overdue,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CareTaskCard(
                task: task,
                isOverdue: true,
                onNavigateToPlantDetail: onNavigateToPlantDetail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Care Task Card ─────────────────────────────────────────────────────────

class _CareTaskCard extends StatelessWidget {
  final CareTask task;
  final bool isOverdue;
  final ValueChanged<String>? onNavigateToPlantDetail;

  const _CareTaskCard({
    required this.task,
    required this.isOverdue,
    this.onNavigateToPlantDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Material(
      color: isOverdue ? theme.colorScheme.errorContainer : theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: task.plantId != null ? () => onNavigateToPlantDetail?.call(task.plantId!) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              _iconForTaskType(task.taskType),
              size: 24,
              color: isOverdue ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.plantName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _taskTypeLabel(l10n, task.taskType),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isOverdue && task.daysOverdue > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${task.daysOverdue}${l10n.daysOverdue}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  IconData _iconForTaskType(CareTaskType type) {
    return switch (type) {
      CareTaskType.water => Icons.water_drop,
      CareTaskType.fertilize => Icons.spa,
      CareTaskType.mist => Icons.water,
      CareTaskType.prune => Icons.content_cut,
      CareTaskType.rotate => Icons.replay,
      CareTaskType.repot => Icons.inventory_2_outlined,
      CareTaskType.clean => Icons.cleaning_services,
      CareTaskType.inspect => Icons.search,
    };
  }

  String _taskTypeLabel(AppLocalizations l10n, CareTaskType type) {
    return switch (type) {
      CareTaskType.water => l10n.taskTypeWater,
      CareTaskType.fertilize => l10n.taskTypeFertilize,
      CareTaskType.mist => l10n.taskTypeMist,
      CareTaskType.prune => l10n.taskTypePrune,
      CareTaskType.rotate => l10n.taskTypeRotate,
      CareTaskType.repot => l10n.taskTypeRepot,
      CareTaskType.clean => l10n.taskTypeClean,
      CareTaskType.inspect => l10n.taskTypeInspect,
    };
  }
}

// ─── Onboarding Empty State ─────────────────────────────────────────────────

class _OnboardingEmptyState extends StatelessWidget {
  final VoidCallback? onNavigateToAddPlant;

  const _OnboardingEmptyState({this.onNavigateToAddPlant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.yard_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPlantsYet,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addYourFirstPlant,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                onNavigateToAddPlant?.call();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.quickAddPlant),
            ),
          ],
        ),
      ),
    );
  }
}
