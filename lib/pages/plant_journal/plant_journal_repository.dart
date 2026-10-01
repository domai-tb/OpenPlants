import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:openplants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:openplants/pages/plant_journal/plant_journal_item_entity.dart';

/// Repository for plant journal domain operations.
///
/// Maps data source CRUD to domain operations and handles ID generation.
class PlantJournalRepository {
  final PlantJournalDataSource dataSource;
  final Uuid _uuid;

  PlantJournalRepository({required this.dataSource}) : _uuid = const Uuid();

  /// Load all journal entries for a specific plant, newest first.
  Future<List<JournalEntry>> getEntries(String plantId) => dataSource.loadByPlant(plantId);

  /// Add a new journal entry with a generated UUID.
  ///
  /// If [photoFile] is provided, it will be copied to the app's documents
  /// directory and the path will be stored on the entry.
  Future<JournalEntry> addEntry(
    JournalEntry entry, {
    File? photoFile,
  }) async {
    final id = _uuid.v4();
    String? photoPath;

    if (photoFile != null) {
      photoPath = await dataSource.savePhoto(photoFile, id);
    }

    final newEntry = entry.copyWith(
      id: id,
      photoPath: photoPath,
    );

    try {
      await dataSource.save(newEntry);
    } catch (_) {
      if (photoPath != null) {
        await _deletePhotoBestEffort(photoPath);
      }
      rethrow;
    }
    return newEntry;
  }

  /// Update an existing journal entry.
  ///
  /// If [photoFile] is provided, the new photo is staged before metadata is
  /// updated; cleanup of the old photo is attempted after the update succeeds.
  Future<JournalEntry> updateEntry(
    JournalEntry entry, {
    File? photoFile,
  }) async {
    String? photoPath = entry.photoPath;
    final oldPhotoPath = entry.photoPath;

    if (photoFile != null) {
      photoPath = await dataSource.savePhoto(photoFile, entry.id);
    }

    final updatedEntry = entry.copyWith(
      photoPath: photoPath,
      clearPhoto: photoPath == null,
    );

    try {
      await dataSource.update(updatedEntry);
    } catch (_) {
      if (photoFile != null && photoPath != null) {
        await _deletePhotoBestEffort(photoPath);
      }
      rethrow;
    }

    if (oldPhotoPath != null && oldPhotoPath != photoPath) {
      await _deletePhotoBestEffort(oldPhotoPath);
    }
    return updatedEntry;
  }

  /// Delete a journal entry by ID.
  ///
  /// Also attempts to delete the photo file from disk if it exists.
  Future<void> deleteEntry(String id) async {
    final all = await dataSource.loadAll();
    final entry = all.where((e) => e.id == id).firstOrNull;

    await dataSource.delete(id);
    if (entry?.photoPath != null) {
      await _deletePhotoBestEffort(entry!.photoPath!);
    }
  }

  /// Delete all journal entries for a specific plant.
  ///
  /// Deletes associated photo files before removing their metadata so a retry
  /// can resume if any file cannot be removed.
  Future<void> deleteEntriesForPlant(String plantId) async {
    final all = List<JournalEntry>.from(await dataSource.loadAll());
    final plantEntries = all.where((e) => e.plantId == plantId).toList();
    for (final entry in plantEntries) {
      if (entry.photoPath != null) {
        await dataSource.deletePhoto(entry.photoPath!);
      }
    }
    all.removeWhere((e) => e.plantId == plantId);
    await dataSource.saveAll(all);
  }

  Future<void> _deletePhotoBestEffort(String photoPath) async {
    try {
      await dataSource.deletePhoto(photoPath);
    } catch (error) {
      debugPrint('Failed to delete journal photo "$photoPath": $error');
    }
  }

  /// Count journal entries for a specific plant.
  Future<int> countEntries(String plantId) async {
    final entries = await dataSource.loadByPlant(plantId);
    return entries.length;
  }

  /// Returns all journal entries across all plants.
  Future<List<JournalEntry>> getAllEntries() => dataSource.loadAll();

  // ---------------------------------------------------------------------------
  // Unified timeline (journal entries + symptom logs + diagnosis results)
  // ---------------------------------------------------------------------------

  /// Returns a merged timeline for [plantId] sorted newest first.
  Future<List<JournalEntry>> getUnifiedTimeline(String plantId) => dataSource.getUnifiedTimeline(plantId);

  /// Returns the merged timeline across all plants, newest first.
  Future<List<JournalEntry>> getAllUnifiedTimeline() => dataSource.getAllUnifiedTimeline();
}
