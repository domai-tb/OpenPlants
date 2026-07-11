import 'dart:io';

import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_repository.dart';

/// Use cases for plant journal business logic.
class PlantJournalUseCases {
  final PlantJournalRepository repository;

  const PlantJournalUseCases({required this.repository});

  /// Fetches entries for a plant sorted by timestamp descending.
  Future<List<JournalEntry>> getEntries(String plantId) => repository.getEntries(plantId);

  /// Validates and persists a new entry with optional photo.
  Future<JournalEntry> addEntry(
    JournalEntry entry, {
    File? photoFile,
  }) {
    return repository.addEntry(entry, photoFile: photoFile);
  }

  /// Updates entry notes and/or photo.
  Future<JournalEntry> updateEntry(
    JournalEntry entry, {
    File? photoFile,
  }) {
    return repository.updateEntry(entry, photoFile: photoFile);
  }

  /// Removes entry and associated photo file.
  Future<void> deleteEntry(String id) => repository.deleteEntry(id);

  /// Delete all journal entries for a specific plant.
  Future<void> deleteEntriesForPlant(String plantId) => repository.deleteEntriesForPlant(plantId);

  /// Count entries for a specific plant.
  Future<int> countEntries(String plantId) => repository.countEntries(plantId);

  // ---------------------------------------------------------------------------
  // Unified timeline (journal entries + symptom logs + diagnosis results)
  // ---------------------------------------------------------------------------

  /// Returns the full unified timeline for [plantId], merging journal entries,
  /// symptom logs, and diagnosis results sorted newest first.
  Future<List<JournalEntry>> getUnifiedTimeline(String plantId) =>
      repository.getUnifiedTimeline(plantId);

  /// Returns the most recent entry across all types for [plantId], or null.
  Future<JournalEntry?> getLatestUnifiedEntry(String plantId) async {
    final entries = await getUnifiedTimeline(plantId);
    return entries.isEmpty ? null : entries.first;
  }

  /// Returns the unified timeline across all plants.
  Future<List<JournalEntry>> getAllUnifiedTimeline() =>
      repository.getAllUnifiedTimeline();
}
