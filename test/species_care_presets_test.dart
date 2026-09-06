import 'package:flutter_test/flutter_test.dart';

import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/species_care_presets.dart';
import 'package:open_plants/pages/species_library/species_library_item_entity.dart';

SpeciesEntity _makeSpecies({
  WaterNeeds waterNeeds = WaterNeeds.moderate,
  HumidityPreference humidityPreference = HumidityPreference.moderate,
  int repottingIntervalMonths = 12,
}) {
  return SpeciesEntity(
    scientificName: 'Testus plantus',
    commonNames: const ['Test Plant'],
    difficulty: Difficulty.easy,
    lightNeeds: LightNeeds.medium,
    waterNeeds: waterNeeds,
    humidityPreference: humidityPreference,
    soilType: 'Standard mix',
    repottingIntervalMonths: repottingIntervalMonths,
    toxicToHumans: false,
    toxicToPets: false,
    description: 'A test plant.',
    careSummary: 'Easy care.',
  );
}

void main() {
  group('speciesCarePresets', () {
    test('generates all 8 task types for moderate species', () {
      final species = _makeSpecies();
      final rules = speciesCarePresets(species, plantId: 'p1');

      expect(rules.length, 8);

      final types = rules.map((r) => r.taskType).toSet();
      expect(
        types,
        containsAll([
          BuiltInTaskType.watering.name,
          BuiltInTaskType.fertilizing.name,
          BuiltInTaskType.misting.name,
          BuiltInTaskType.pruning.name,
          BuiltInTaskType.rotating.name,
          BuiltInTaskType.repotting.name,
          BuiltInTaskType.leafCleaning.name,
          BuiltInTaskType.pestInspection.name,
        ]),
      );
    });

    test('watering interval follows WaterNeeds', () {
      final frequent = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.frequent),
        plantId: 'p1',
      );
      final moderate = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.moderate),
        plantId: 'p1',
      );
      final low = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.low),
        plantId: 'p1',
      );

      expect(
        frequent.firstWhere((r) => r.taskType == BuiltInTaskType.watering.name).intervalDays,
        5,
      );
      expect(
        moderate.firstWhere((r) => r.taskType == BuiltInTaskType.watering.name).intervalDays,
        7,
      );
      expect(
        low.firstWhere((r) => r.taskType == BuiltInTaskType.watering.name).intervalDays,
        10,
      );
    });

    test('fertilizing interval follows WaterNeeds', () {
      final frequent = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.frequent),
        plantId: 'p1',
      );
      final moderate = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.moderate),
        plantId: 'p1',
      );
      final low = speciesCarePresets(
        _makeSpecies(waterNeeds: WaterNeeds.low),
        plantId: 'p1',
      );

      expect(
        frequent.firstWhere((r) => r.taskType == BuiltInTaskType.fertilizing.name).intervalDays,
        14,
      );
      expect(
        moderate.firstWhere((r) => r.taskType == BuiltInTaskType.fertilizing.name).intervalDays,
        21,
      );
      expect(
        low.firstWhere((r) => r.taskType == BuiltInTaskType.fertilizing.name).intervalDays,
        30,
      );
    });

    test('high-humidity species gets misting with 3d interval', () {
      final rules = speciesCarePresets(
        _makeSpecies(humidityPreference: HumidityPreference.high),
        plantId: 'p1',
      );

      final misting = rules.firstWhere((r) => r.taskType == BuiltInTaskType.misting.name);
      expect(misting.intervalDays, 3);
    });

    test('moderate-humidity species gets misting with 5d interval', () {
      final rules = speciesCarePresets(
        _makeSpecies(humidityPreference: HumidityPreference.moderate),
        plantId: 'p1',
      );

      final misting = rules.firstWhere((r) => r.taskType == BuiltInTaskType.misting.name);
      expect(misting.intervalDays, 5);
    });

    test('low-humidity species omits misting', () {
      final rules = speciesCarePresets(
        _makeSpecies(humidityPreference: HumidityPreference.low),
        plantId: 'p1',
      );

      final mistingTypes = rules.where((r) => r.taskType == BuiltInTaskType.misting.name);
      expect(mistingTypes, isEmpty);
      expect(rules.length, 7); // 8 - misting
    });

    test('repotting interval scales with months', () {
      final rules6 = speciesCarePresets(
        _makeSpecies(repottingIntervalMonths: 6),
        plantId: 'p1',
      );
      final rules12 = speciesCarePresets(
        _makeSpecies(repottingIntervalMonths: 12),
        plantId: 'p1',
      );

      expect(
        rules6.firstWhere((r) => r.taskType == BuiltInTaskType.repotting.name).intervalDays,
        180,
      );
      expect(
        rules12.firstWhere((r) => r.taskType == BuiltInTaskType.repotting.name).intervalDays,
        360,
      );
    });

    test('all rules have correct defaults', () {
      final rules = speciesCarePresets(_makeSpecies(), plantId: 'p1');

      for (final rule in rules) {
        expect(rule.plantId, 'p1');
        expect(rule.isEnabled, true);
        expect(rule.reminderEnabled, false);
        expect(rule.reminderTime, isNull);
        expect(rule.reminderDays, isNull);
        expect(rule.id, contains('p1_preset_'));
      }
    });

    test('fixed-interval rules are correct', () {
      final rules = speciesCarePresets(_makeSpecies(), plantId: 'p1');

      expect(
        rules.firstWhere((r) => r.taskType == BuiltInTaskType.pruning.name).intervalDays,
        30,
      );
      expect(
        rules.firstWhere((r) => r.taskType == BuiltInTaskType.rotating.name).intervalDays,
        14,
      );
      expect(
        rules.firstWhere((r) => r.taskType == BuiltInTaskType.leafCleaning.name).intervalDays,
        14,
      );
      expect(
        rules.firstWhere((r) => r.taskType == BuiltInTaskType.pestInspection.name).intervalDays,
        21,
      );
    });
  });
}
