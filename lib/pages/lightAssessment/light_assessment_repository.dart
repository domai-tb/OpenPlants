import 'package:open_plant/pages/lightAssessment/light_assessment_datasource.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Repository for light assessment domain operations.
class LightAssessmentRepository {
  final LightAssessmentDataSource dataSource;

  const LightAssessmentRepository({required this.dataSource});

  /// Get the current light level for a plant.
  Future<LightLevel?> getLightLevel(String plantId) => dataSource.loadLightLevel(plantId);

  /// Set the light level for a plant.
  Future<void> setLightLevel(String plantId, LightLevel level) => dataSource.saveLightLevel(plantId, level);

  /// Clear the light level for a plant.
  Future<void> clearLightLevel(String plantId) => dataSource.clearLightLevel(plantId);
}
