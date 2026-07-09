import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/constants.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_detail_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/widgets/app_icon_button.dart';
import 'package:open_plant/widgets/app_search_bar.dart';
import 'package:open_plant/widgets/scroll_to_top_button.dart';

class PlantCollectionPage extends StatefulWidget {
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  /// Notifies this page to reload data after a tab switch.
  final Listenable? tabSwitchNotifier;

  const PlantCollectionPage({
    super.key,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.tabSwitchNotifier,
  });

  @override
  State<PlantCollectionPage> createState() => _PlantCollectionPageState();
}

class _PlantCollectionPageState extends State<PlantCollectionPage>
    with AutomaticKeepAliveClientMixin<PlantCollectionPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  late PlantCollectionUsecases _usecases;
  late PlantJournalUseCases _journalUsecases;
  late RoomProfilesUsecases _roomUsecases;
  bool _wired = false;

  List<PlantEntity> _plants = [];
  Map<String, int> _journalCounts = {};
  List<RoomEntity> _rooms = [];
  Map<String, String> _roomNames = {};
  bool _loading = true;
  bool _showSearch = false;
  String _query = '';
  CareStatus? _filterStatus;
  String? _filterRoomId;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantCollection;
    _journalUsecases = AppScope.of(context).services.plantJournal;
    _roomUsecases = AppScope.of(context).services.roomProfiles;
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

    // Load rooms and build name map
    final rooms = await _roomUsecases.getAll();
    final roomNames = <String, String>{};
    for (final room in rooms) {
      roomNames[room.id] = room.name;
    }

    List<PlantEntity> plants;

    if (_query.isNotEmpty) {
      plants = await _usecases.searchPlants(_query);
    } else if (_filterStatus != null) {
      plants = await _usecases.filterByCareStatus(_filterStatus);
    } else {
      plants = await _usecases.loadPlants();
    }

    // Apply room filter
    if (_filterRoomId != null) {
      if (_filterRoomId == kUnassignedSentinel) {
        plants = plants.where((p) => p.roomId == null).toList();
      } else {
        plants = plants.where((p) => p.roomId == _filterRoomId).toList();
      }
    }

    // Fetch journal entry counts for each plant.
    final counts = <String, int>{};
    for (final plant in plants) {
      counts[plant.id] = await _journalUsecases.countEntries(plant.id);
    }

    if (!mounted) return;
    setState(() {
      _plants = plants;
      _journalCounts = counts;
      _rooms = rooms;
      _roomNames = roomNames;
      _loading = false;
    });
  }

  /// Reload data after returning from a detail or form page.
  Future<void> _reloadAfterNavigation() async {
    if (mounted) {
      await _load();
    }
  }

  Future<void> _addPlant() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlantCollectionFormPage()),
    );
    await _reloadAfterNavigation();
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
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.plantCollectionTitle,
                              style: theme.textTheme.displayMedium,
                            ),
                          ),
                          AppIconButton(
                            icon: _showSearch ? Icons.arrow_back : Icons.search,
                            onTap: () {
                              setState(() {
                                _showSearch = !_showSearch;
                                if (!_showSearch) {
                                  _query = '';
                                  _load();
                                }
                              });
                            },
                            transparent: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_showSearch)
                      AppSearchBar(
                        arrowHidden: true,
                        onBack: () {},
                        onChange: (q) {
                          setState(() => _query = q);
                          _load();
                        },
                      ),
                    const SizedBox(height: 10),
                    // Care status filter chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            label: context.l10n.filterAll,
                            selected: _filterStatus == null,
                            onTap: () {
                              setState(() => _filterStatus = null);
                              _load();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: context.l10n.careStatusNeedsWater,
                            selected: _filterStatus == CareStatus.needsWater,
                            onTap: () {
                              setState(() {
                                _filterStatus = _filterStatus == CareStatus.needsWater ? null : CareStatus.needsWater;
                              });
                              _load();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context,
                            label: context.l10n.careStatusNeedsFertilizer,
                            selected: _filterStatus == CareStatus.needsFertilizer,
                            onTap: () {
                              setState(() {
                                _filterStatus =
                                    _filterStatus == CareStatus.needsFertilizer ? null : CareStatus.needsFertilizer;
                              });
                              _load();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Room filter chips
                    if (_rooms.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFilterChip(
                                context,
                                label: 'All Rooms',
                                selected: _filterRoomId == null,
                                onTap: () {
                                  setState(() => _filterRoomId = null);
                                  _load();
                                },
                              ),
                              const SizedBox(width: 8),
                              ..._rooms.map(
                                (room) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterChip(
                                    context,
                                    label: room.name,
                                    selected: _filterRoomId == room.id,
                                    onTap: () {
                                      setState(() {
                                        _filterRoomId = _filterRoomId == room.id ? null : room.id;
                                      });
                                      _load();
                                    },
                                  ),
                                ),
                              ),
                              _buildFilterChip(
                                context,
                                label: 'Unassigned',
                                selected: _filterRoomId == kUnassignedSentinel,
                                onTap: () {
                                  setState(() {
                                    _filterRoomId = _filterRoomId == kUnassignedSentinel ? null : kUnassignedSentinel;
                                  });
                                  _load();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _load,
                        child: _plants.isEmpty && !_loading
                            ? _buildEmptyState(context)
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: _loading ? 6 : _plants.length,
                                itemBuilder: (context, index) {
                                  if (_loading) {
                                    return _buildLoadingTile(context);
                                  }
                                  return _buildPlantTile(context, _plants[index]);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
                // FAB positioned above the navbar
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: _addPlant,
                    child: const Icon(Icons.add),
                  ),
                ),
                // Scroll to top button positioned above the navbar
                Positioned(
                  right: 16,
                  bottom: bottomNavBarHeight + MediaQuery.of(context).padding.bottom + 80,
                  child: ScrollToTopButton(
                    scrollController: _scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.yard_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.plantCollectionEmpty,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.plantCollectionTapToAdd,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTile(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildPlantTile(BuildContext context, PlantEntity plant) {
    final theme = Theme.of(context);
    final journalCount = _journalCounts[plant.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlantCollectionDetailPage(plant: plant),
              ),
            );
            await _reloadAfterNavigation();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Care status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCareStatusColor(plant.careStatus),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (plant.speciesName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          plant.speciesName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                if (plant.roomId != null && _roomNames.containsKey(plant.roomId)) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _roomNames[plant.roomId] ?? 'Unknown',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ] else if (plant.roomId == null && plant.room != null) ...[
                  // Legacy room string fallback
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plant.room!,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
                if (journalCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 12,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$journalCount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCareStatusColor(CareStatus status) {
    switch (status) {
      case CareStatus.happy:
        return Colors.green;
      case CareStatus.needsWater:
        return Colors.blue;
      case CareStatus.needsFertilizer:
        return Colors.orange;
      case CareStatus.needsAttention:
        return Colors.red;
    }
  }
}
