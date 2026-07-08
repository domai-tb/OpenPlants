import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_form_page.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';

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
    setState(() => _loading = true);
    final rooms = await _usecases.getAll();
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _loading = false;
    });
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
    final plants = await _plantUsecases.loadPlants();
    final affectedCount = plants.where((p) => p.roomId == room.id).length;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteRoomDialog(
        roomName: room.name,
        affectedPlantCount: affectedCount,
      ),
    );

    if (confirmed == true) {
      try {
        // Update affected plants first (clear roomId)
        for (final plant in plants) {
          if (plant.roomId == room.id) {
            await _plantUsecases.updatePlant(plant.copyWith(clearRoomId: true));
          }
        }
        // Then delete the room
        await _usecases.delete(room.id);
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting room: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
            'No rooms yet',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create rooms to organize your plants by location',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _addRoom,
            icon: const Icon(Icons.add),
            label: const Text('Add Room'),
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
                            label: _lightLevelLabel(room.lightLevel),
                            icon: Icons.light_mode,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            context,
                            label: _humidityLevelLabel(room.humidityLevel),
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

  String _lightLevelLabel(RoomLightLevel level) {
    switch (level) {
      case RoomLightLevel.low:
        return 'Low light';
      case RoomLightLevel.medium:
        return 'Medium';
      case RoomLightLevel.bright:
        return 'Bright';
      case RoomLightLevel.directSun:
        return 'Direct sun';
    }
  }

  String _humidityLevelLabel(RoomHumidityLevel level) {
    switch (level) {
      case RoomHumidityLevel.low:
        return 'Low humidity';
      case RoomHumidityLevel.medium:
        return 'Medium';
      case RoomHumidityLevel.high:
        return 'High humidity';
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
      title: Text('Delete "$roomName"?'),
      content: affectedPlantCount > 0
          ? Text(
              'This room has $affectedPlantCount plant(s) assigned. '
              'They will be unassigned when the room is deleted.',
            )
          : const Text('This room has no plants assigned.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
