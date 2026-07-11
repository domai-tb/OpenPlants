import 'dart:io' show File;

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/constants.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/widgets/app_search_bar.dart';

/// Section widget that displays the plant collection as a searchable,
/// filterable grid within the today dashboard.
class PlantGridSection extends StatefulWidget {
  /// Called when a plant card is tapped with the plant's ID.
  final ValueChanged<String> onNavigateToPlantDetail;

  const PlantGridSection({
    super.key,
    required this.onNavigateToPlantDetail,
  });

  @override
  State<PlantGridSection> createState() => PlantGridSectionState();
}

class PlantGridSectionState extends State<PlantGridSection> {
  late PlantCollectionUsecases _usecases;
  late RoomProfilesUsecases _roomUsecases;
  bool _wired = false;

  List<PlantEntity> _plants = [];
  Map<String, String> _roomNames = {};
  bool _loading = true;
  bool _showSearch = false;
  String _query = '';
  CareStatus? _filterStatus;
  String? _filterRoomId;

  /// Reloads plants and room data. Called externally after navigation.
  Future<void> reload() => _load();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantCollection;
    _roomUsecases = AppScope.of(context).services.roomProfiles;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
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

      // Apply room filter.
      if (_filterRoomId != null) {
        if (_filterRoomId == kUnassignedSentinel) {
          plants = plants.where((p) => p.roomId == null).toList();
        } else {
          plants = plants.where((p) => p.roomId == _filterRoomId).toList();
        }
      }

      if (!mounted) return;
      setState(() {
        _plants = plants;
        _roomNames = roomNames;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Section header with search toggle.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.plantCollectionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch && _query.isNotEmpty) {
                      _query = '';
                      _load();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        // Search bar (toggled).
        if (_showSearch) ...[
          const SizedBox(height: 8),
          AppSearchBar(
            arrowHidden: true,
            onBack: () {},
            onChange: (q) {
              setState(() => _query = q);
              _load();
            },
          ),
        ],
        const SizedBox(height: 8),
        // Care status filter chips.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _FilterChip(
                label: l10n.filterAll,
                selected: _filterStatus == null,
                onTap: () {
                  setState(() => _filterStatus = null);
                  _load();
                },
              ),
              _FilterChip(
                label: l10n.careStatusNeedsWater,
                selected: _filterStatus == CareStatus.needsWater,
                onTap: () {
                  setState(() {
                    _filterStatus =
                        _filterStatus == CareStatus.needsWater ? null : CareStatus.needsWater;
                  });
                  _load();
                },
              ),
              _FilterChip(
                label: l10n.careStatusNeedsFertilizer,
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
        const SizedBox(height: 8),
        // Room filter chips (horizontal scroll).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All Rooms',
                  selected: _filterRoomId == null,
                  onTap: () {
                    setState(() => _filterRoomId = null);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ..._roomNames.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: entry.value,
                      selected: _filterRoomId == entry.key,
                      onTap: () {
                        setState(() {
                          _filterRoomId = _filterRoomId == entry.key ? null : entry.key;
                        });
                        _load();
                      },
                    ),
                  ),
                ),
                if (_roomNames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: 'Unassigned',
                      selected: _filterRoomId == kUnassignedSentinel,
                      onTap: () {
                        setState(() {
                          _filterRoomId =
                              _filterRoomId == kUnassignedSentinel ? null : kUnassignedSentinel;
                        });
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Grid or empty / loading state.
        if (_loading) ...[
          _buildLoadingGrid(theme, l10n),
        ] else if (_plants.isEmpty) ...[
          _buildEmptyState(theme, l10n),
        ] else ...[
          _buildPlantGrid(theme, l10n),
        ],
      ],
    );
  }

  Widget _buildPlantGrid(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _plants.length,
        itemBuilder: (context, index) => _buildPlantCard(context, _plants[index]),
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, PlantEntity plant) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onNavigateToPlantDetail(plant.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area.
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.surfaceContainerHighest,
                child: plant.photoPath != null
                    ? Image.file(
                        File(plant.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _plantPlaceholder(theme),
                      )
                    : _plantPlaceholder(theme),
              ),
            ),
            // Info area.
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (plant.speciesName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      plant.speciesName!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _careStatusColor(plant.effectiveCareStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (plant.roomId != null && _roomNames.containsKey(plant.roomId))
                        Flexible(
                          child: Text(
                            _roomNames[plant.roomId]!,
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _careStatusColor(CareStatus status) {
    return switch (status) {
      CareStatus.happy => Colors.green,
      CareStatus.needsWater => Colors.blue,
      CareStatus.needsFertilizer => Colors.orange,
      CareStatus.needsAttention => Colors.red,
    };
  }

  Widget _plantPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.yard_outlined,
        size: 40,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildLoadingGrid(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.plantCollectionEmpty,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
