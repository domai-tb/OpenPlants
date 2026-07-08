import 'package:uuid/uuid.dart';

import 'package:open_plant/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Repository for symptom logger domain operations.
///
/// Maps data source CRUD to domain operations and handles ID generation.
class SymptomLoggerRepository {
  final SymptomLoggerDataSource _dataSource;
  final Uuid _uuid;

  SymptomLoggerRepository({required SymptomLoggerDataSource dataSource})
      : _dataSource = dataSource,
        _uuid = const Uuid();

  /// Returns all symptom entries for a plant, newest first.
  Future<List<SymptomLogEntry>> getAllByPlant(String plantId) => _dataSource.getAllByPlant(plantId);

  /// Returns all symptom entries across all plants, newest first.
  Future<List<SymptomLogEntry>> getAllEntries() => _dataSource.loadAllEntries();

  /// Creates a new symptom entry with a generated ID.
  Future<SymptomLogEntry> logSymptom(SymptomLogEntry entry) async {
    final newEntry = entry.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
    await _dataSource.save(newEntry);
    return newEntry;
  }

  /// Updates an existing symptom entry.
  Future<void> updateEntry(SymptomLogEntry entry) => _dataSource.update(entry);

  /// Deletes a symptom entry by ID.
  Future<void> deleteEntry(String id) => _dataSource.delete(id);

  /// Marks a symptom entry as resolved.
  Future<void> markResolved(String id) async {
    final all = await _dataSource.loadAllEntries();
    final index = all.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception('SymptomLogEntry not found: $id');
    }
    final resolved = all[index].copyWith(
      resolved: true,
      resolvedAt: DateTime.now(),
    );
    await _dataSource.update(resolved);
  }

  // --- Draft support ---

  /// Saves form progress as a draft for a specific plant.
  Future<void> saveDraft(String plantId, Map<String, dynamic> draft) => _dataSource.saveDraft(plantId, draft);

  /// Loads the draft for a specific plant, or null if none exists.
  Future<Map<String, dynamic>?> getDraft(String plantId) => _dataSource.getDraft(plantId);

  /// Deletes the draft for a specific plant.
  Future<void> deleteDraft(String plantId) => _dataSource.deleteDraft(plantId);
}
