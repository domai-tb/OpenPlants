import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

void main() {
  late SymptomLoggerDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = SymptomLoggerDataSource();
  });

  SymptomLogEntry makeEntry({String? diagnosisResultId}) {
    return SymptomLogEntry(
      id: 'symptom-1',
      plantId: 'plant-1',
      symptomTypes: const [PlantSymptom.yellowingLeaves],
      severity: Severity.mild,
      affectedParts: const [AffectedPart.leaves],
      onsetTiming: OnsetTiming.today,
      createdAt: DateTime(2026),
      diagnosisResultId: diagnosisResultId,
    );
  }

  group('symptom diagnosis association', () {
    test('persists a reciprocal diagnosis result ID without duplicating the symptom', () async {
      // Arrange
      await dataSource.save(makeEntry());

      // Act
      await dataSource.update(makeEntry().copyWith(diagnosisResultId: 'diagnosis-1'));
      final entries = await dataSource.loadAllEntries();

      // Assert
      expect(entries, hasLength(1));
      expect(entries.single.diagnosisResultId, equals('diagnosis-1'));
    });

    test('decodes existing symptom records without a diagnosis result ID', () {
      // Arrange
      final json = makeEntry().toJson()..remove('diagnosisResultId');

      // Act
      final restored = SymptomLogEntry.fromJson(json);

      // Assert
      expect(restored.diagnosisResultId, isNull);
    });
  });
}
