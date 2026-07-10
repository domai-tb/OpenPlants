import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_datasource.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_item_entity.dart';

/// Repository for plant health timeline domain operations.
///
/// Delegates data fetching to [PlantHealthTimelineDataSource] and provides
/// a clean domain API for the use-cases layer.
class PlantHealthTimelineRepository {
  final PlantHealthTimelineDataSource _dataSource;

  const PlantHealthTimelineRepository({
    required PlantHealthTimelineDataSource dataSource,
  }) : _dataSource = dataSource;

  /// Returns the merged health timeline for a specific plant, newest first.
  Future<List<TimelineEntry>> getTimeline(String plantId) =>
      _dataSource.getTimeline(plantId);

  /// Returns the merged health timeline across all plants, newest first.
  Future<List<TimelineEntry>> getAllTimeline() =>
      _dataSource.getAllTimeline();
}
