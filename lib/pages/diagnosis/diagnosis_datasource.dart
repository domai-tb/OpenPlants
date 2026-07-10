import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';

/// Data source for diagnosis result persistence.
///
/// Stores diagnosis records as JSON in SharedPreferences.
class DiagnosisDataSource {
  static const String _prefsKey = 'diagnosis_results_v1';

  /// Loads all diagnosis results, newest first.
  Future<List<DiagnosisResultEntity>> getAll() async {
    final all = await _loadAll();
    return all..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Loads all diagnosis results for a given plant, newest first.
  Future<List<DiagnosisResultEntity>> getAllByPlant(String plantId) async {
    final all = await _loadAll();
    return all.where((record) => record.plantId == plantId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns a diagnosis result by its ID, or null if not found.
  Future<DiagnosisResultEntity?> getById(String id) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((record) => record.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Saves a diagnosis result, replacing an existing record with the same ID.
  Future<void> save(DiagnosisResultEntity record) async {
    final all = await _loadAll();
    final index = all.indexWhere((existing) => existing.id == record.id);
    if (index == -1) {
      all.add(record);
    } else {
      all[index] = record;
    }
    await _saveAll(all);
  }

  /// Deletes a diagnosis result by ID.
  Future<void> delete(String id) async {
    final all = await _loadAll();
    all.removeWhere((record) => record.id == id);
    await _saveAll(all);
  }

  Future<List<DiagnosisResultEntity>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => DiagnosisResultEntity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<DiagnosisResultEntity> records) async {
    final prefs = await SharedPreferences.getInstance();
    final json = records.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(json));
  }
}
