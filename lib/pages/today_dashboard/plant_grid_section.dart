import 'dart:io' show File;

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/constants.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';

/// Section widget that displays the plant collection as a searchable,
/// filterable grid within the today dashboard.
///
/// Filter state (search query, care-status filter, room filter) is
/// managed externally by the parent and passed via constructor — the
/// state reacts to changes through `didUpdateWidget`.
class PlantGridSection extends StatefulWidget {
  /// Called when a plant card is tapped with the plant's ID.
  final ValueChanged<String> onNavigateToPlantDetail;

  /// Current search query (empty string = no search).
  final String query;

  /// Active care-status filter, or `null` for "All".
  final CareStatus? filterStatus;

  /// Active room-id filter, or `null` for "All".
  final String? filterRoomId;

  /// Called after room names are loaded so the parent can render room
  /// filter chips in the fixed section of the page layout.
  final ValueChanged<Map<String, String>>? onRoomNamesChanged;

  const PlantGridSection({
    super.key,
    required this.onNavigateToPlantDetail,
    this.query = '',
    this.filterStatus,
    this.filterRoomId,
    this.onRoomNamesChanged,
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

  @override
  void didUpdateWidget(PlantGridSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.filterStatus != widget.filterStatus ||
        oldWidget.filterRoomId != widget.filterRoomId) {
      _load();
    }
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
      if (widget.query.isNotEmpty) {
        plants = await _usecases.searchPlants(widget.query);
      } else if (widget.filterStatus != null) {
        plants = await _usecases.filterByCareStatus(widget.filterStatus);
      } else {
        plants = await _usecases.loadPlants();
      }

      // Apply room filter.
      if (widget.filterRoomId != null) {
        if (widget.filterRoomId == kUnassignedSentinel) {
          plants = plants.where((p) => p.roomId == null).toList();
        } else {
          plants = plants.where((p) => p.roomId == widget.filterRoomId).toList();
        }
      }

      if (!mounted) return;
      setState(() {
        _plants = plants;
        _roomNames = roomNames;
        _loading = false;
      });
      widget.onRoomNamesChanged?.call(roomNames);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Grid or empty / loading state — filter controls are rendered
    // by the parent in the fixed section of the page layout.
    if (_loading) {
      return _buildLoadingGrid(theme, l10n);
    } else if (_plants.isEmpty) {
      return _buildEmptyState(theme, l10n);
    } else {
      return _buildPlantGrid(theme, l10n);
    }
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
