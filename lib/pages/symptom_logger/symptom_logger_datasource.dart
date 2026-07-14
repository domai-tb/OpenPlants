import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Data source for symptom logger persistence.
///
/// Stores symptom log entries as JSON in SharedPreferences.
/// Uses [LocalCollectionCodec] to distinguish missing keys from corruption,
/// preserve raw values on failure, and block mutations after a decode failure.
class SymptomLoggerDataSource {
  static const String _prefsKey = 'symptom_logs_v1';
  static const String _draftPrefsKey = 'symptom_draft_v1';

  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<SymptomLogEntry>? _codec;

  SymptomLoggerDataSource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  Future<LocalCollectionCodec<SymptomLogEntry>> _getCodec() async {
    if (_codec == null) {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      _codec = LocalCollectionCodec<SymptomLogEntry>(
        prefs: prefs,
        key: _prefsKey,
        fromJson: SymptomLogEntry.fromJson,
        toJson: (e) => e.toJson(),
        keyExtractor: (e) => e.id,
      );
    }
    return _codec!;
  }

  /// Whether the symptom logs collection is in a corrupted state.
  Future<bool> get isBlocked async {
    final codec = await _getCodec();
    return codec.isBlocked;
  }

  /// Loads all symptom log entries for a given plant, newest first.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<SymptomLogEntry>> getAllByPlant(String plantId) async {
    final all = await _loadAll();
    return all.where((entry) => entry.plantId == plantId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Saves a new symptom log entry.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> save(SymptomLogEntry entry) async {
    final codec = await _getCodec();
    await codec.add(entry);
  }

  /// Updates an existing symptom log entry by ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> update(SymptomLogEntry entry) async {
    final codec = await _getCodec();
    await codec.update(entry, matchKey: (e) => e.id);
  }

  /// Deletes a symptom log entry by ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> delete(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  /// Loads all entries across all plants.
  Future<List<SymptomLogEntry>> loadAllEntries() => _loadAll();

  /// Save the full list of symptom log entries.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> saveAll(List<SymptomLogEntry> entries) async {
    final codec = await _getCodec();
    await codec.save(entries);
  }

  /// Delete all symptom log entries for a specific plant.
  ///
  /// Also deletes the draft for this plant.
  /// Idempotent: succeeds even if plant has no entries.
  Future<void> deleteForPlant(String plantId) async {
    final entries = await _loadAll();
    final remaining = entries.where((e) => e.plantId != plantId).toList();
    await saveAll(remaining);
    await deleteDraft(plantId);
  }

  Future<List<SymptomLogEntry>> _loadAll() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess;
  }

  // --- Draft support ---

  /// Saves form progress as a draft JSON string.
  Future<void> saveDraft(String plantId, Map<String, dynamic> draft) async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    final allDrafts = await _loadAllDrafts(prefs);
    allDrafts[plantId] = draft;
    await prefs.setString(_draftPrefsKey, jsonEncode(allDrafts));
  }

  /// Loads the draft for a specific plant, or null if none exists.
  Future<Map<String, dynamic>?> getDraft(String plantId) async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    final allDrafts = await _loadAllDrafts(prefs);
    return allDrafts[plantId] as Map<String, dynamic>?;
  }

  /// Deletes the draft for a specific plant.
  Future<void> deleteDraft(String plantId) async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    final allDrafts = await _loadAllDrafts(prefs);
    allDrafts.remove(plantId);
    await prefs.setString(_draftPrefsKey, jsonEncode(allDrafts));
  }

  Future<Map<String, dynamic>> _loadAllDrafts(SharedPreferences prefs) async {
    final raw = prefs.getString(_draftPrefsKey);
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
