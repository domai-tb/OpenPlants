import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';

/// Data source for plant journal persistence.
///
/// Stores journal entries as JSON in SharedPreferences and
/// manages photo files in the app's documents directory.
class PlantJournalDataSource {
  static const String _prefsKey = 'plant_journal_v1';
  static const String _photoSubdir = 'journal_photos';

  /// Load all journal entries from SharedPreferences.
  Future<List<JournalEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => JournalEntry.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Load journal entries for a specific plant, sorted newest first.
  Future<List<JournalEntry>> loadByPlant(String plantId) async {
    final all = await loadAll();
    return all.where((entry) => entry.plantId == plantId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Save the full list of journal entries.
  Future<void> saveAll(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final json = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(json));
  }

  /// Save a journal entry (add to list).
  Future<void> save(JournalEntry entry) async {
    final all = await loadAll();
    all.add(entry);
    await saveAll(all);
  }

  /// Update a journal entry by ID.
  Future<void> update(JournalEntry entry) async {
    final all = await loadAll();
    final index = all.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      throw Exception('JournalEntry not found: ${entry.id}');
    }
    all[index] = entry;
    await saveAll(all);
  }

  /// Delete a journal entry by ID.
  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }

  /// Copy a photo file to the app's documents directory.
  ///
  /// Returns the absolute path to the stored photo.
  Future<String> savePhoto(File sourceFile, String entryId) async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/$_photoSubdir');

    if (!photoDir.existsSync()) {
      await photoDir.create(recursive: true);
    }

    final parts = sourceFile.path.split('.');
    final extension = parts.length > 1 ? parts.last : 'jpg';
    final targetPath = '${photoDir.path}/$entryId.$extension';

    await sourceFile.copy(targetPath);
    return targetPath;
  }

  /// Delete a photo file from disk.
  Future<void> deletePhoto(String photoPath) async {
    final file = File(photoPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
