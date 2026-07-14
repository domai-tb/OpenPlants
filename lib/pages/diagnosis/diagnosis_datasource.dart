import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';

/// Data source for diagnosis result persistence.
///
/// Stores diagnosis records as JSON in SharedPreferences.
/// Uses [LocalCollectionCodec] to distinguish missing keys from corruption,
/// preserve raw values on failure, and block mutations after a decode failure.
class DiagnosisDataSource {
  static const String _prefsKey = 'diagnosis_results_v1';

  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<DiagnosisResultEntity>? _codec;

  DiagnosisDataSource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  Future<LocalCollectionCodec<DiagnosisResultEntity>> _getCodec() async {
    if (_codec == null) {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      _codec = LocalCollectionCodec<DiagnosisResultEntity>(
        prefs: prefs,
        key: _prefsKey,
        fromJson: DiagnosisResultEntity.fromJson,
        toJson: (e) => e.toJson(),
        keyExtractor: (e) => e.id,
      );
    }
    return _codec!;
  }

  /// Whether the collection is in a corrupted state that blocks mutations.
  Future<bool> get isBlocked async {
    final codec = await _getCodec();
    return codec.isBlocked;
  }

  /// Loads all diagnosis results, newest first.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<DiagnosisResultEntity>> getAll() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Loads all diagnosis results for a given plant, newest first.
  Future<List<DiagnosisResultEntity>> getAllByPlant(String plantId) async {
    final all = await getAll();
    return all.where((record) => record.plantId == plantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns a diagnosis result by its ID, or null if not found.
  Future<DiagnosisResultEntity?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((record) => record.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Saves a diagnosis result, replacing an existing record with the same ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> save(DiagnosisResultEntity record) async {
    final codec = await _getCodec();
    await codec.update(record, matchKey: (e) => e.id);
  }

  /// Deletes a diagnosis result by ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> delete(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  /// Save the full list of diagnosis results.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> saveAll(List<DiagnosisResultEntity> records) async {
    final codec = await _getCodec();
    await codec.save(records);
  }

  /// Delete all diagnosis results for a specific plant.
  ///
  /// Idempotent: succeeds even if plant has no results.
  Future<void> deleteForPlant(String plantId) async {
    final all = await getAll();
    final remaining = all.where((r) => r.plantId != plantId).toList();
    await saveAll(remaining);
  }
}
