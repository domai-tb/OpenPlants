import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class PlantJournalDataSource {
  static const String _prefsKey = 'plant_journal_v1';
  static const String _photoSubdir = 'journal_photos';

  final SymptomLoggerDataSource _symptomLoggerDataSource;
  final DiagnosisDataSource _diagnosisDataSource;

  PlantJournalDataSource({
    SymptomLoggerDataSource? symptomLoggerDataSource,
    DiagnosisDataSource? diagnosisDataSource,
  })  : _symptomLoggerDataSource = symptomLoggerDataSource ?? SymptomLoggerDataSource(),
        _diagnosisDataSource = diagnosisDataSource ?? DiagnosisDataSource();

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
