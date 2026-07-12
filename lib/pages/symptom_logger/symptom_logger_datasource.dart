import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Data source for symptom logger persistence.
///
/// Stores symptom log entries as JSON in SharedPreferences.
class SymptomLoggerDataSource {
  static const String _prefsKey = 'symptom_logs_v1';
  static const String _draftPrefsKey = 'symptom_draft_v1';

  /// Loads all symptom log entries for a given plant, newest first.
  Future<List<SymptomLogEntry>> getAllByPlant(String plantId) async {
    final all = await _loadAll();
    return all.where((entry) => entry.plantId == plantId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Saves a new symptom log entry.
  Future<void> save(SymptomLogEntry entry) async {
    final all = await _loadAll();
    all.add(entry);
    await _saveAll(all);
  }

  /// Updates an existing symptom log entry by ID.
  Future<void> update(SymptomLogEntry entry) async {
    final all = await _loadAll();
    final index = all.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      throw Exception('SymptomLogEntry not found: ${entry.id}');
    }
    all[index] = entry;
    await _saveAll(all);
  }

  /// Deletes a symptom log entry by ID.
  Future<void> delete(String id) async {
    final all = await _loadAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  /// Loads all entries across all plants.
  Future<List<SymptomLogEntry>> loadAllEntries() => _loadAll();

  Future<List<SymptomLogEntry>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => SymptomLogEntry.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves the full list of entries.
  Future<void> _saveAll(List<SymptomLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final json = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(json));
  }

  // --- Draft support ---

  /// Saves form progress as a draft JSON string.
  Future<void> saveDraft(String plantId, Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    final allDrafts = await _loadAllDrafts(prefs);
    allDrafts[plantId] = draft;
    await prefs.setString(_draftPrefsKey, jsonEncode(allDrafts));
  }

  /// Loads the draft for a specific plant, or null if none exists.
  Future<Map<String, dynamic>?> getDraft(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final allDrafts = await _loadAllDrafts(prefs);
    return allDrafts[plantId] as Map<String, dynamic>?;
  }

  /// Deletes the draft for a specific plant.
  Future<void> deleteDraft(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
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
