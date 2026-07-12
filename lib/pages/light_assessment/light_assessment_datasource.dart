import 'package:open_plant/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Data source for light level persistence.
///
/// Reads and writes the [LightLevel] field on [PlantEntity] via the plant
/// collection's shared_preferences storage.
class LightAssessmentDataSource {
  final PlantCollectionDataSource _plantDataSource;

  const LightAssessmentDataSource({required PlantCollectionDataSource plantDataSource})
      : _plantDataSource = plantDataSource;

  /// Load the current light level for a plant.
  Future<LightLevel?> loadLightLevel(String plantId) async {
    final plants = await _plantDataSource.loadPlants();
    final plant = plants.where((p) => p.id == plantId).firstOrNull;
    return plant?.lightLevel;
  }

  /// Save a light level for a plant.
  Future<void> saveLightLevel(String plantId, LightLevel level) async {
    final plants = await _plantDataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == plantId);
    if (index == -1) return;

    plants[index] = plants[index].copyWith(lightLevel: level);
    await _plantDataSource.savePlants(plants);
  }

  /// Clear the light level for a plant (set to null).
  Future<void> clearLightLevel(String plantId) async {
    final plants = await _plantDataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == plantId);
    if (index == -1) return;

    plants[index] = plants[index].copyWith(clearLightLevel: true);
    await _plantDataSource.savePlants(plants);
  }
}
