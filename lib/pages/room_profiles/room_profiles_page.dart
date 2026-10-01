import 'package:flutter/material.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/l10n/l10n_x.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_form_page.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';

/// Page for managing room profiles.
class RoomProfilesPage extends StatefulWidget {
  const RoomProfilesPage({super.key});

  @override
  State<RoomProfilesPage> createState() => _RoomProfilesPageState();
}

class _RoomProfilesPageState extends State<RoomProfilesPage> {
  late RoomProfilesUsecases _usecases;
  late PlantCollectionUsecases _plantUsecases;
  bool _wired = false;

  List<RoomEntity> _rooms = [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    final services = AppScope.of(context).services;
    _usecases = services.roomProfiles;
    _plantUsecases = services.plantCollection;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final rooms = await _usecases.getAll();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load room profiles: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _addRoom() async {
    final result = await Navigator.of(context).push<RoomEntity>(
      MaterialPageRoute(builder: (_) => const RoomProfilesFormPage()),
    );
    if (result != null) await _load();
  }

  Future<void> _editRoom(RoomEntity room) async {
    final result = await Navigator.of(context).push<RoomEntity>(
      MaterialPageRoute(builder: (_) => RoomProfilesFormPage(room: room)),
    );
    if (result != null) await _load();
  }

  Future<void> _deleteRoom(RoomEntity room) async {
    late final List<PlantEntity> plants;
    try {
      plants = await _plantUsecases.loadPlants();
    } catch (error, stackTrace) {
      debugPrint('Failed to load plants before deleting room ${room.id}: $error\n$stackTrace');
      if (mounted) _showDeleteFailure();
      return;
    }
    final affectedCount = plants.where((p) => p.roomId == room.id).length;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteRoomDialog(
        roomName: room.name,
        affectedPlantCount: affectedCount,
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _usecases.deleteAndUnassignPlants(room.id, plantCollection: _plantUsecases);
        await _load();
      } catch (error, stackTrace) {
        debugPrint('Failed to delete room ${room.id}: $error\n$stackTrace');
        if (mounted) {
          _showDeleteFailure();
        }
      }
    }
  }

  void _showDeleteFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generalFailureMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.moreRoomsTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
              ? _buildLoadError(context)
              : _rooms.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) => _buildRoomTile(context, _rooms[index]),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.generalFailureMessage),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
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
            Icons.room_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.roomEmptyTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.moreRoomsSubtitle,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _addRoom,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.roomAddAction),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, RoomEntity room) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editRoom(room),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            context,
                            label: _lightLevelLabel(context, room.lightLevel),
                            icon: Icons.light_mode,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            context,
                            label: _humidityLevelLabel(context, room.humidityLevel),
                            icon: Icons.water_drop_outlined,
                          ),
                        ],
                      ),
                      if (room.notes != null && room.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          room.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteRoom(room),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, {required String label, required IconData icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _lightLevelLabel(BuildContext context, RoomLightLevel level) {
    switch (level) {
      case RoomLightLevel.low:
        return context.l10n.speciesLibraryLightLow;
      case RoomLightLevel.medium:
        return context.l10n.speciesLibraryLightMedium;
      case RoomLightLevel.bright:
        return context.l10n.speciesLibraryLightBright;
      case RoomLightLevel.directSun:
        return context.l10n.speciesLibraryLightDirect;
    }
  }

  String _humidityLevelLabel(BuildContext context, RoomHumidityLevel level) {
    switch (level) {
      case RoomHumidityLevel.low:
        return context.l10n.diagnosisHumidityLow;
      case RoomHumidityLevel.medium:
        return context.l10n.diagnosisHumidityModerate;
      case RoomHumidityLevel.high:
        return context.l10n.diagnosisHumidityHigh;
    }
  }
}

/// Dialog for confirming room deletion.
class _DeleteRoomDialog extends StatelessWidget {
  final String roomName;
  final int affectedPlantCount;

  const _DeleteRoomDialog({
    required this.roomName,
    required this.affectedPlantCount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.roomDeleteTitle(roomName)),
      content: affectedPlantCount > 0
          ? Text(context.l10n.roomDeleteAssignedPlants(affectedPlantCount))
          : Text(context.l10n.roomDeleteNoAssignments),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.confirm),
        ),
      ],
    );
  }
}
