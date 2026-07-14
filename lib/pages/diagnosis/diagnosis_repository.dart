import 'package:uuid/uuid.dart';

import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_usecases.dart';

/// Repository for the diagnosis feature.
///
/// Delegates rule evaluation to the usecases layer (DiagnosisEngine) and
/// persists diagnosis results via [DiagnosisDataSource].
class DiagnosisRepository {
  final DiagnosisEngine _engine;
  final DiagnosisDataSource _dataSource;
  final Uuid _uuid;

  DiagnosisRepository({
    required DiagnosisEngine engine,
    required DiagnosisDataSource dataSource,
  })  : _engine = engine,
        _dataSource = dataSource,
        _uuid = const Uuid();

  /// Evaluates the given [context] and returns ranked causes.
  DiagnosisResult evaluate(DiagnosisContext context) {
    return _engine.evaluate(context);
  }

  /// Persists a diagnosis result, assigning an ID and timestamp to new records.
  Future<DiagnosisResultEntity> saveResult(DiagnosisResultEntity record) async {
    final saved = record.id.isEmpty
        ? record.copyWith(
            id: _uuid.v4(),
            createdAt: DateTime.now(),
          )
        : record;
    await _dataSource.save(saved);
    return saved;
  }

  /// Returns all diagnosis results, newest first.
  Future<List<DiagnosisResultEntity>> getAllResults() {
    return _dataSource.getAll();
  }

  /// Returns all diagnosis results for a plant, newest first.
  Future<List<DiagnosisResultEntity>> getResultsByPlant(String plantId) {
    return _dataSource.getAllByPlant(plantId);
  }

  /// Returns a diagnosis result by ID, or null if not found.
  Future<DiagnosisResultEntity?> getResultById(String id) {
    return _dataSource.getById(id);
  }

  /// Deletes a diagnosis result by ID.
  Future<void> deleteResult(String id) {
    return _dataSource.delete(id);
  }

  /// Delete all diagnosis results for a specific plant.
  Future<void> deleteResultsForPlant(String plantId) {
    return _dataSource.deleteForPlant(plantId);
  }
}
