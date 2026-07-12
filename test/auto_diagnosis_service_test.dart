import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/diagnosis/auto_diagnosis_service.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_usecases.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_repository.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_datasource.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_repository.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

void main() {
  late AutoDiagnosisService service;
  late DiagnosisRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final dataSource = DiagnosisDataSource();
    final engine = DiagnosisEngine();
    repository = DiagnosisRepository(
      engine: engine,
      dataSource: dataSource,
    );
    service = AutoDiagnosisService(
      repository: repository,
      engine: engine,
    );
  });

  /// Helper to create a SymptomLogEntry for testing.
  SymptomLogEntry makeEntry({
    String id = 'entry-1',
    String plantId = 'plant-1',
    List<PlantSymptom> symptomTypes = const [PlantSymptom.yellowingLeaves],
  }) {
    return SymptomLogEntry(
      id: id,
      plantId: plantId,
      symptomTypes: symptomTypes,
      severity: Severity.moderate,
      affectedParts: const [AffectedPart.leaves],
      onsetTiming: OnsetTiming.fewDaysAgo,
      createdAt: DateTime(2026, 1, 15),
    );
  }

  group('AutoDiagnosisService', () {
    group('diagnoseAndSave', () {
      test('saves diagnosis result and returns entity ID', () async {
        // Arrange
        final entry = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        );

        // Act
        final id = await service.diagnoseAndSave(entry);

        // Assert
        expect(id, isNotNull);
        expect(id!.length, equals(36)); // UUID format
      });

      test('returns null when engine produces no results', () async {
        // Arrange — symptoms that score below threshold for all rules
        final entry = makeEntry(
          symptomTypes: [PlantSymptom.softStems],
        );

        // Act
        final id = await service.diagnoseAndSave(entry);

        // Assert — noClearMatch hasResults = false, so returns null
        expect(id, isNull);
      });

      test('persists result retrievable via repository', () async {
        // Arrange
        final entry = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        );

        // Act
        final id = await service.diagnoseAndSave(entry);
        final results = await repository.getResultsByPlant('plant-1');

        // Assert
        expect(results, isNotEmpty);
        expect(results.first.id, equals(id));
        expect(results.first.plantId, equals('plant-1'));
      });

      test('multiple diagnoses for same plant are all persisted', () async {
        // Arrange
        final entry1 = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves],
        );
        final entry2 = makeEntry(
          id: 'entry-2',
          symptomTypes: [PlantSymptom.droopingWilt, PlantSymptom.brownTips],
        );

        // Act
        await service.diagnoseAndSave(entry1);
        await service.diagnoseAndSave(entry2);

        // Assert
        final results = await repository.getResultsByPlant('plant-1');
        expect(results.length, equals(2));
      });
    });

    group('getLatestDiagnosis', () {
      test('returns most recent diagnosis for plant', () async {
        // Arrange
        final entry1 = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves],
        );
        final entry2 = makeEntry(
          id: 'entry-2',
          symptomTypes: [PlantSymptom.droopingWilt, PlantSymptom.brownTips],
        );
        await service.diagnoseAndSave(entry1);
        await service.diagnoseAndSave(entry2);

        // Act
        final latest = await service.getLatestDiagnosis('plant-1');

        // Assert
        expect(latest, isNotNull);
        // Results are sorted newest first, so entry2 (saved second) should be first
        expect(latest!.plantSymptoms, contains(PlantSymptom.droopingWilt));
      });

      test('returns null when no diagnoses exist for plant', () async {
        // Act
        final latest = await service.getLatestDiagnosis('nonexistent-plant');

        // Assert
        expect(latest, isNull);
      });

      test('returns null for plant with no diagnoses after others exist', () async {
        // Arrange
        final entry = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        );
        await service.diagnoseAndSave(entry);

        // Act
        final latest = await service.getLatestDiagnosis('other-plant');

        // Assert
        expect(latest, isNull);
      });
    });

    group('error handling', () {
      test('diagnoseAndSave does not throw on any input', () async {
        // Arrange
        final entry = makeEntry(
          symptomTypes: PlantSymptom.values.toList(),
        );

        // Act & Assert
        expect(() => service.diagnoseAndSave(entry), returnsNormally);
      });

      test('getLatestDiagnosis does not throw', () async {
        // Act & Assert
        expect(() => service.getLatestDiagnosis('any-plant'), returnsNormally);
      });
    });

    group('context building', () {
      test('maps symptom types from entry to diagnosis context', () async {
        // Arrange
        final entry = makeEntry(
          symptomTypes: [
            PlantSymptom.yellowingLeaves,
            PlantSymptom.brownTips,
            PlantSymptom.visibleInsects,
          ],
        );

        // Act
        final id = await service.diagnoseAndSave(entry);

        // Assert
        expect(id, isNotNull);
        final results = await repository.getResultsByPlant('plant-1');
        expect(results.first.plantSymptoms.length, equals(3));
        expect(results.first.plantSymptoms, contains(PlantSymptom.visibleInsects));
      });

      test('maps logged observations and room profile into the saved context', () async {
        final plantDataSource = PlantCollectionDataSource();
        final roomDataSource = RoomProfilesDatasource();
        final room = RoomEntity(
          id: 'room-1',
          name: 'Kitchen',
          lightLevel: RoomLightLevel.bright,
          humidityLevel: RoomHumidityLevel.high,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        await roomDataSource.saveRooms([room]);
        await plantDataSource.savePlants([
          PlantEntity(
            id: 'plant-1',
            name: 'Monstera',
            roomId: room.id,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ]);
        service = AutoDiagnosisService(
          repository: repository,
          engine: DiagnosisEngine(),
          plantCollection: PlantCollectionUsecases(
            repository: PlantCollectionRepository(dataSource: plantDataSource),
          ),
          roomProfiles: RoomProfilesUsecases(
            repository: RoomProfilesRepository(dataSource: roomDataSource),
          ),
        );
        final entry = makeEntry(
          symptomTypes: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        ).copyWith(
          soilMoisture: SoilMoisture.soggy,
          lightConditions: LightCondition.lowLight,
        );

        await service.diagnoseAndSave(entry);

        final result = (await repository.getResultsByPlant('plant-1')).single;
        expect(result.context.symptoms, entry.symptomTypes);
        expect(result.context.wateringFrequency, WateringFrequency.frequent);
        expect(result.context.lightExposure, LightExposure.low);
        expect(result.context.humidityLevel, HumidityLevel.high);
        expect(result.symptomLogEntryId, entry.id);
      });
    });
  });
}
