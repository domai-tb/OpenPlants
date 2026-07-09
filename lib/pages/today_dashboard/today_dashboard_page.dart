import 'dart:io' show File;

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_entity.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_usecases.dart';

class TodayDashboardPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  /// Optional callback: navigate to the Plant Collection tab and open the
  /// add-plant form.
  final VoidCallback? onNavigateToAddPlant;

  /// Optional callback: navigate to a plant's detail page by ID.
  /// The callback receives the plant ID and handles tab switching + navigation.
  final ValueChanged<String>? onNavigateToPlantDetail;

  /// Notifies this page to reload data after a tab switch.
  final Listenable? tabSwitchNotifier;

  const TodayDashboardPage({
    super.key,
    required this.mainNavigatorKey,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.onNavigateToAddPlant,
    this.onNavigateToPlantDetail,
    this.tabSwitchNotifier,
  });

  @override
  State<TodayDashboardPage> createState() => _TodayDashboardPageState();
}

class _TodayDashboardPageState extends State<TodayDashboardPage>
    with AutomaticKeepAliveClientMixin<TodayDashboardPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
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
        onNavigateToAddPlant: widget.onNavigateToAddPlant,
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
                  mainNavigatorKey: widget.mainNavigatorKey,
                  onNavigateToAddPlant: widget.onNavigateToAddPlant,
                ),
                const SizedBox(height: 24),
                if (data.dueToday.isNotEmpty)
                  _DueTasksSection(
                    tasks: data.dueToday,
                    onNavigateToPlantDetail: widget.onNavigateToPlantDetail,
                  ),
                if (data.overdue.isNotEmpty)
                  _OverdueTasksSection(
                    tasks: data.overdue,
                    onNavigateToPlantDetail: widget.onNavigateToPlantDetail,
                  ),
                if (data.recentPlants.isNotEmpty)
                  _RecentPlantsCarousel(
                    plants: data.recentPlants,
                    mainNavigatorKey: widget.mainNavigatorKey,
                    onNavigateToPlantDetail: widget.onNavigateToPlantDetail,
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
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final VoidCallback? onNavigateToAddPlant;

  const _QuickActionStrip({
    required this.mainNavigatorKey,
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
                mainNavigatorKey.currentState?.pushNamed('/identify');
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
                mainNavigatorKey.currentState?.pushNamed('/care_schedule');
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

// ─── Recent Plants Carousel ─────────────────────────────────────────────────

class _RecentPlantsCarousel extends StatelessWidget {
  final List<PlantSummary> plants;
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final ValueChanged<String>? onNavigateToPlantDetail;

  const _RecentPlantsCarousel({
    required this.plants,
    required this.mainNavigatorKey,
    this.onNavigateToPlantDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            context.l10n.recentPlants,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: plants.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final plant = plants[index];
                return GestureDetector(
                  onTap: () {
                    onNavigateToPlantDetail?.call(plant.id);
                  },
                  child: Column(
                    children: [
                      _PlantThumbnail(photoPath: plant.photoPath),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 80,
                        child: Text(
                          plant.name,
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantThumbnail extends StatelessWidget {
  final String? photoPath;

  const _PlantThumbnail({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath != null
          ? Image.file(
              File(photoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _plantIcon(theme),
            )
          : _plantIcon(theme),
    );
  }

  Widget _plantIcon(ThemeData theme) {
    return Icon(
      Icons.yard_outlined,
      color: theme.colorScheme.primary.withValues(alpha: 0.5),
      size: 36,
    );
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
