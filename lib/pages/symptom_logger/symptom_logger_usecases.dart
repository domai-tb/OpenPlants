import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_repository.dart';

/// Business logic for the symptom logger feature.
class SymptomLoggerUseCases {
  final SymptomLoggerRepository _repository;
  final PlantCollectionUsecases _plantCollection;

  const SymptomLoggerUseCases({
    required SymptomLoggerRepository repository,
    required PlantCollectionUsecases plantCollection,
  })  : _repository = repository,
        _plantCollection = plantCollection;

  /// Logs a new symptom entry for a plant.
  ///
  /// If the symptom severity is [Severity.severe] and the plant's current
  /// care status is not already [CareStatus.needsAttention], the plant's
  /// status is automatically updated to [CareStatus.needsAttention].
  Future<SymptomLogEntry> logSymptom(SymptomLogEntry entry) async {
    final savedEntry = await _repository.logSymptom(entry);

    // Auto-update plant care status for severe symptoms
    if (entry.severity == Severity.severe) {
      final plants = await _plantCollection.loadPlants();
      final plant = plants.where((p) => p.id == entry.plantId).firstOrNull;
      if (plant != null && plant.careStatus != CareStatus.needsAttention) {
        final updated = plant.copyWith(careStatus: CareStatus.needsAttention);
        await _plantCollection.updatePlant(updated);
      }
    }

    return savedEntry;
  }

  /// Returns symptom history for a plant, newest first.
  Future<List<SymptomLogEntry>> getSymptomHistory(String plantId) => _repository.getAllByPlant(plantId);

  /// Returns all symptom entries across all plants, newest first.
  Future<List<SymptomLogEntry>> getAllSymptoms() => _repository.getAllEntries();

  /// Marks a symptom entry as resolved.
  Future<void> markResolved(String entryId) => _repository.markResolved(entryId);

  /// Saves the current form as a draft for later resumption.
  Future<void> saveDraft(String plantId, Map<String, dynamic> draft) => _repository.saveDraft(plantId, draft);

  /// Loads the saved draft for a plant, or null if none exists.
  Future<Map<String, dynamic>?> getDraft(String plantId) => _repository.getDraft(plantId);

  /// Deletes the draft for a plant.
  Future<void> deleteDraft(String plantId) => _repository.deleteDraft(plantId);
}
