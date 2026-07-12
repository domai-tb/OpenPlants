import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/diagnosis/auto_diagnosis_service.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_usecases.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_repository.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_repository.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_usecases.dart';

void main() {
  test('logSymptom waits for diagnosis persistence and returns the linked entry', () async {
    SharedPreferences.setMockInitialValues({});
    final diagnosisEngine = DiagnosisEngine();
    final diagnosisRepository = DiagnosisRepository(
      engine: diagnosisEngine,
      dataSource: DiagnosisDataSource(),
    );
    final autoDiagnosis = AutoDiagnosisService(
      repository: diagnosisRepository,
      engine: diagnosisEngine,
    );
    final symptomDataSource = SymptomLoggerDataSource();
    final useCases = SymptomLoggerUseCases(
      repository: SymptomLoggerRepository(dataSource: symptomDataSource),
      plantCollection: PlantCollectionUsecases(
        repository: PlantCollectionRepository(dataSource: PlantCollectionDataSource()),
      ),
      autoDiagnosis: autoDiagnosis,
    );
    final entry = SymptomLogEntry(
      id: '',
      plantId: 'plant-1',
      symptomTypes: const [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
      severity: Severity.moderate,
      affectedParts: const [AffectedPart.leaves],
      onsetTiming: OnsetTiming.today,
      createdAt: DateTime(2026),
    );

    final savedEntry = await useCases.logSymptom(entry);

    expect(savedEntry.diagnosisResultId, isNotNull);
    final persistedEntry = (await symptomDataSource.loadAllEntries()).single;
    final diagnosis = await diagnosisRepository.getResultById(savedEntry.diagnosisResultId!);
    expect(persistedEntry.diagnosisResultId, savedEntry.diagnosisResultId);
    expect(diagnosis?.symptomLogEntryId, savedEntry.id);
  });
}
