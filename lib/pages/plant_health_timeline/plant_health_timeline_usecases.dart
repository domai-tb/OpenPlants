import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_item_entity.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_repository.dart';

/// Business logic for the plant health timeline feature.
class PlantHealthTimelineUseCases {
  final PlantHealthTimelineRepository _repository;

  const PlantHealthTimelineUseCases({
    required PlantHealthTimelineRepository repository,
  }) : _repository = repository;

  /// Returns the full health timeline for a plant, newest first.
  Future<List<TimelineEntry>> getTimeline(String plantId) =>
      _repository.getTimeline(plantId);

  /// Returns timeline entries for a plant within the given date range.
  Future<List<TimelineEntry>> getTimelineForRange(
    String plantId,
    DateTime start,
    DateTime end,
  ) async {
    final all = await _repository.getTimeline(plantId);
    return all.where((entry) {
      return !entry.date.isBefore(start) && !entry.date.isAfter(end);
    }).toList();
  }

  /// Returns the most recent timeline entry for a plant, or null if empty.
  Future<TimelineEntry?> getLatestEntry(String plantId) async {
    final entries = await _repository.getTimeline(plantId);
    return entries.isEmpty ? null : entries.first;
  }

  /// Returns the full health timeline across all plants, newest first.
  Future<List<TimelineEntry>> getAllTimeline() =>
      _repository.getAllTimeline();
}
