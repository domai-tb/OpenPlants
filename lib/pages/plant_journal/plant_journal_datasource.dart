import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Data source for plant journal persistence.
///
/// Stores journal entries as JSON in SharedPreferences and
/// manages photo files in the app's documents directory.
/// Also loads symptom logs and diagnosis results for a merged timeline.
///
/// Uses [LocalCollectionCodec] to distinguish missing keys from corruption,
/// preserve raw values on failure, and block mutations after a decode failure.
class PlantJournalDataSource {
  static const String _prefsKey = 'plant_journal_v1';
  static const String _photoSubdir = 'journal_photos';

  final SymptomLoggerDataSource _symptomLoggerDataSource;
  final DiagnosisDataSource _diagnosisDataSource;
  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<JournalEntry>? _codec;

  PlantJournalDataSource({
    SymptomLoggerDataSource? symptomLoggerDataSource,
    DiagnosisDataSource? diagnosisDataSource,
    SharedPreferences? prefs,
  })  : _symptomLoggerDataSource = symptomLoggerDataSource ?? SymptomLoggerDataSource(),
        _diagnosisDataSource = diagnosisDataSource ?? DiagnosisDataSource(),
        _prefsOverride = prefs;

  Future<LocalCollectionCodec<JournalEntry>> _getCodec() async {
    if (_codec == null) {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      _codec = LocalCollectionCodec<JournalEntry>(
        prefs: prefs,
        key: _prefsKey,
        fromJson: JournalEntry.fromJson,
        toJson: (e) => e.toJson(),
        keyExtractor: (e) => e.id,
      );
    }
    return _codec!;
  }

  /// Whether the journal collection is in a corrupted state.
  Future<bool> get isBlocked async {
    final codec = await _getCodec();
    return codec.isBlocked;
  }

  /// Load all journal entries from SharedPreferences.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<JournalEntry>> loadAll() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess;
  }

  /// Load journal entries for a specific plant, sorted newest first.
  Future<List<JournalEntry>> loadByPlant(String plantId) async {
    final all = await loadAll();
    return all.where((entry) => entry.plantId == plantId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Save the full list of journal entries.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> saveAll(List<JournalEntry> entries) async {
    final codec = await _getCodec();
    await codec.save(entries);
  }

  /// Save a journal entry (add to list).
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> save(JournalEntry entry) async {
    final codec = await _getCodec();
    await codec.add(entry);
  }

  /// Update a journal entry by ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> update(JournalEntry entry) async {
    final codec = await _getCodec();
    await codec.update(entry, matchKey: (e) => e.id);
  }

  /// Delete a journal entry by ID.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> delete(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  /// Delete all journal entries for a specific plant.
  ///
  /// Also deletes associated photo files from disk.
  /// Idempotent: succeeds even if plant has no entries.
  Future<void> deleteForPlant(String plantId) async {
    final entries = await loadAll();
    final toRemove = entries.where((e) => e.plantId == plantId).toList();

    // Delete photo files for entries being removed
    for (final entry in toRemove) {
      if (entry.photoPath != null) {
        await deletePhoto(entry.photoPath!);
      }
    }

    final remaining = entries.where((e) => e.plantId != plantId).toList();
    await saveAll(remaining);
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

  // ---------------------------------------------------------------------------
  // Unified timeline (merges journal entries + symptom logs + diagnosis results)
  // ---------------------------------------------------------------------------

  /// Loads unified timeline across all plants.
  Future<List<JournalEntry>> getAllUnifiedTimeline() async {
    final allJournal = await loadAll();
    final allSymptoms = await _symptomLoggerDataSource.loadAllEntries();
    final allDiagnoses = await _diagnosisDataSource.getAll();

    final all = <JournalEntry>[
      ...allJournal,
      ...allSymptoms.map(_symptomToJournalEntry),
      ...allDiagnoses.map(_diagnosisToJournalEntry),
    ];
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  /// Loads journal entries, symptom logs, and diagnosis results for [plantId]
  /// and merges them into a single list sorted by timestamp descending.
  Future<List<JournalEntry>> getUnifiedTimeline(String plantId) async {
    final journalEntries = await loadByPlant(plantId);
    final symptoms = await _symptomLoggerDataSource.getAllByPlant(plantId);
    final diagnoses = await _diagnosisDataSource.getAllByPlant(plantId);

    final mappedSymptoms = symptoms.map(_symptomToJournalEntry);
    final mappedDiagnoses = diagnoses.map(_diagnosisToJournalEntry);

    final all = <JournalEntry>[
      ...journalEntries,
      ...mappedSymptoms,
      ...mappedDiagnoses,
    ];
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  /// Projects a [SymptomLogEntry] into a [JournalEntry] with type `symptom`.
  JournalEntry _symptomToJournalEntry(SymptomLogEntry s) {
    final symptomTypeNames = s.symptomTypes.map((e) => e.name).toList();
    final affectedPartNames = s.affectedParts.map((e) => e.name).toList();

    return JournalEntry(
      id: 'symptom_${s.id}',
      plantId: s.plantId,
      type: JournalEntryType.symptom,
      timestamp: s.createdAt,
      referenceId: s.diagnosisResultId,
      notes: s.notes,
      photoPath: s.photoPath,
      structuredData: <String, dynamic>{
        'symptomTypes': symptomTypeNames,
        'severity': s.severity.name,
        'affectedParts': affectedPartNames,
        'onsetTiming': s.onsetTiming.name,
        'resolved': s.resolved,
        if (s.resolvedAt != null) 'resolvedAt': s.resolvedAt!.toIso8601String(),
        if (s.diagnosisResultId != null) 'diagnosisResultId': s.diagnosisResultId,
      },
    );
  }

  /// Projects a [DiagnosisResultEntity] into a [JournalEntry] with type `diagnosis`.
  JournalEntry _diagnosisToJournalEntry(DiagnosisResultEntity d) {
    String? topCauseName;
    double? topConfidence;
    if (d.causes.isNotEmpty) {
      topCauseName = d.causes.first.causeId;
      topConfidence = d.causes.first.score;
    }

    return JournalEntry(
      id: 'diagnosis_${d.id}',
      plantId: d.plantId,
      type: JournalEntryType.diagnosis,
      timestamp: d.createdAt,
      referenceId: d.symptomLogEntryId,
      notes: '${d.type.name}: ${topCauseName ?? 'No cause identified'}',
      structuredData: <String, dynamic>{
        'topCause': topCauseName,
        'topConfidence': topConfidence,
        'causeCount': d.causes.length,
        'type': d.type.name,
        if (d.symptomLogEntryId != null) 'symptomLogEntryId': d.symptomLogEntryId,
        'evidenceSummary': _buildEvidenceSummary(d),
      },
    );
  }

  /// Builds a summary of the evidence reported during diagnosis.
  String _buildEvidenceSummary(DiagnosisResultEntity d) {
    final parts = <String>[];
    if (d.context.wateringFrequency != null) {
      parts.add('Watering: ${d.context.wateringFrequency!.name}');
    }
    if (d.context.lightExposure != null) {
      parts.add('Light: ${d.context.lightExposure!.name}');
    }
    return parts.isNotEmpty ? parts.join(', ') : '';
  }
}
