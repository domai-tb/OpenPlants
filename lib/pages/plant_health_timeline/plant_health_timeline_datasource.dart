import 'package:flutter/material.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_datasource.dart';

/// Data source that merges symptom logs and diagnosis results into a
/// unified [TimelineEntry] list.
class PlantHealthTimelineDataSource {
  final SymptomLoggerDataSource _symptomLoggerDataSource;
  final DiagnosisDataSource _diagnosisDataSource;

  const PlantHealthTimelineDataSource({
    required SymptomLoggerDataSource symptomLoggerDataSource,
    required DiagnosisDataSource diagnosisDataSource,
  })  : _symptomLoggerDataSource = symptomLoggerDataSource,
        _diagnosisDataSource = diagnosisDataSource;

  /// Fetches and merges symptom logs and diagnosis results for [plantId]
  /// into a single timeline, sorted by date descending.
  Future<List<TimelineEntry>> getTimeline(String plantId) async {
    final symptoms = await _symptomLoggerDataSource.getAllByPlant(plantId);
    final diagnoses = await _diagnosisDataSource.getAllByPlant(plantId);

    final symptomEntries = symptoms.map((s) {
      return TimelineEntry(
        id: s.id,
        plantId: s.plantId,
        type: TimelineEntryType.symptom,
        title: s.symptomTypes.isNotEmpty ? s.symptomTypes.first.name : TimelineEntryType.symptom.name,
        subtitle: s.severity.name,
        date: s.createdAt,
        severity: s.severity.name,
        iconData: Icons.bug_report_outlined,
      );
    });
    final diagnosisEntries = diagnoses.map((d) {
      return TimelineEntry(
        id: d.id,
        plantId: d.plantId,
        type: TimelineEntryType.diagnosis,
        title: TimelineEntryType.diagnosis.name,
        subtitle: d.causes.isNotEmpty ? d.causes.first.causeId : null,
        date: d.createdAt,
        iconData: Icons.medical_services_outlined,
      );
    });

    final entries = [...symptomEntries, ...diagnosisEntries];
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Fetches timeline entries for all plants.
  Future<List<TimelineEntry>> getAllTimeline() async {
    final symptoms = await _symptomLoggerDataSource.loadAllEntries();
    final diagnoses = await _diagnosisDataSource.getAll();

    final symptomEntries = symptoms.map((s) {
      return TimelineEntry(
        id: s.id,
        plantId: s.plantId,
        type: TimelineEntryType.symptom,
        title: s.symptomTypes.isNotEmpty ? s.symptomTypes.first.name : TimelineEntryType.symptom.name,
        subtitle: s.severity.name,
        date: s.createdAt,
        severity: s.severity.name,
        iconData: Icons.bug_report_outlined,
      );
    });
    final diagnosisEntries = diagnoses.map((d) {
      return TimelineEntry(
        id: d.id,
        plantId: d.plantId,
        type: TimelineEntryType.diagnosis,
        title: TimelineEntryType.diagnosis.name,
        subtitle: d.causes.isNotEmpty ? d.causes.first.causeId : null,
        date: d.createdAt,
        iconData: Icons.medical_services_outlined,
      );
    });

    final entries = [...symptomEntries, ...diagnosisEntries];

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}
