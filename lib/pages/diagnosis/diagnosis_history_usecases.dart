import 'package:open_plants/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';

/// Use-cases for querying and managing persisted diagnosis history.
class DiagnosisHistoryUseCases {
  final DiagnosisRepository _repository;

  const DiagnosisHistoryUseCases({required DiagnosisRepository repository}) : _repository = repository;

  /// Returns all diagnosis results, newest first.
  Future<List<DiagnosisResultEntity>> getAllResults() {
    return _repository.getAllResults();
  }

  /// Returns diagnosis results for a specific plant, newest first.
  Future<List<DiagnosisResultEntity>> getResultsForPlant(String plantId) {
    return _repository.getResultsByPlant(plantId);
  }

  /// Deletes a diagnosis result by ID.
  Future<void> deleteResult(String id) {
    return _repository.deleteResult(id);
  }
}
