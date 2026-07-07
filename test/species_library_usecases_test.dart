import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_plant/pages/species_library/care_plan.dart';
import 'package:open_plant/pages/species_library/species_library_datasource.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';
import 'package:open_plant/pages/species_library/species_library_repository.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';

void main() {
  late SpeciesLibraryRepository repository;
  late SpeciesLibraryUsecases usecases;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Load the actual species.json to use as mock data
    final speciesJson = File('assets/species/species.json').readAsStringSync();
    final decoded = json.decode(speciesJson) as List<dynamic>;
    expect(decoded.length, greaterThan(20));

    final mockBundle = _MockAssetBundle(
      <String, String>{'assets/species/species.json': speciesJson},
    );
    final datasource = SpeciesLibraryDatasource(bundle: mockBundle);
    repository = SpeciesLibraryRepository(datasource: datasource);
    usecases = SpeciesLibraryUsecases(repository: repository);
  });

  group('SpeciesLibraryRepository', () {
    test('listAll returns all species', () async {
      final species = await repository.listAll();
      expect(species.length, greaterThan(20));
    });

    test('search filters by common name (case-insensitive)', () async {
      final results = await repository.search('snake');
      expect(results, isNotEmpty);
      expect(
        results.any((s) => s.commonNames.any((n) => n.toLowerCase().contains('snake'))),
        isTrue,
      );
    });

    test('search filters by scientific name (case-insensitive)', () async {
      final results = await repository.search('monstera');
      expect(results, isNotEmpty);
      expect(
        results.any((s) => s.scientificName.toLowerCase().contains('monstera')),
        isTrue,
      );
    });

    test('search returns empty list for non-matching query', () async {
      final results = await repository.search('zzzno_such_plant');
      expect(results, isEmpty);
    });

    test('findByScientificName finds exact case-insensitive match', () async {
      final result = await repository.findByScientificName('MONSTERA DELICIOSA');
      expect(result, isNotNull);
      expect(result!.scientificName, 'Monstera deliciosa');
    });

    test('findByScientificName returns null for unknown name', () async {
      final result = await repository.findByScientificName('Fictus nonexistus');
      expect(result, isNull);
    });

    test('findByScientificName fuzzy matches with Levenshtein ≤ 2', () async {
      // "Monstera delicios" missing terminal "a" — distance 1
      final result = await repository.findByScientificName('Monstera delicios');
      expect(result, isNotNull);
      expect(result!.scientificName, 'Monstera deliciosa');
    });

    test('filter by difficulty', () async {
      final easy = await repository.filter(difficulty: Difficulty.easy);
      expect(easy, isNotEmpty);
      expect(easy.every((s) => s.difficulty == Difficulty.easy), isTrue);
    });

    test('filter toxicOnly returns toxic species', () async {
      final toxic = await repository.filter(toxicOnly: true);
      expect(toxic, isNotEmpty);
      expect(
        toxic.every((s) => s.toxicToHumans || s.toxicToPets),
        isTrue,
      );
    });
  });

  group('SpeciesLibraryUsecases', () {
    test('generateCarePlan returns CarePlan with all sections', () async {
      final species = (await usecases.getAllSpecies()).first;
      final plan = usecases.generateCarePlan(species);

      expect(plan, isA<CarePlan>());
      expect(plan.wateringGuidance, isNotEmpty);
      expect(plan.lightGuidance, isNotEmpty);
      expect(plan.humidityGuidance, isNotEmpty);
      expect(plan.soilRecommendation, isNotEmpty);
      expect(plan.repottingAdvice, isNotEmpty);
    });

    test('generateCarePlan low water guidance', () async {
      const lowWaterSpecies = SpeciesEntity(
        scientificName: 'Test plant',
        commonNames: ['Test'],
        difficulty: Difficulty.easy,
        lightNeeds: LightNeeds.medium,
        waterNeeds: WaterNeeds.low,
        humidityPreference: HumidityPreference.low,
        soilType: 'Well-draining mix',
        repottingIntervalMonths: 12,
        toxicToHumans: false,
        toxicToPets: false,
        description: 'Test species',
        careSummary: 'Easy care',
      );

      final plan = usecases.generateCarePlan(lowWaterSpecies);
      expect(
        plan.wateringGuidance,
        contains('every 2-3 weeks'),
      );
    });

    test('generateCarePlan frequent water guidance', () async {
      const freqWaterSpecies = SpeciesEntity(
        scientificName: 'Test plant 2',
        commonNames: ['Test 2'],
        difficulty: Difficulty.moderate,
        lightNeeds: LightNeeds.direct,
        waterNeeds: WaterNeeds.frequent,
        humidityPreference: HumidityPreference.high,
        soilType: 'Moist mix',
        repottingIntervalMonths: 24,
        toxicToHumans: false,
        toxicToPets: true,
        description: 'Test species 2',
        careSummary: 'Needs care',
      );

      final plan = usecases.generateCarePlan(freqWaterSpecies);
      expect(
        plan.wateringGuidance,
        contains('2-3 times per week'),
      );
    });

    test('speciesForIdentifiedPlant returns matching species', () async {
      final result = await usecases.speciesForIdentifiedPlant('Monstera deliciosa');
      expect(result, isNotNull);
      expect(result!.scientificName, 'Monstera deliciosa');
    });

    test('speciesForIdentifiedPlant returns null for unknown', () async {
      final result = await usecases.speciesForIdentifiedPlant('Unknownus plantus');
      expect(result, isNull);
    });
  });
}

/// A mock [AssetBundle] that returns canned strings for specific assets.
class _MockAssetBundle extends AssetBundle {
  final Map<String, String> _assets;

  _MockAssetBundle(this._assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) return _assets[key]!;
    throw Exception('Asset $key not found in mock bundle');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError('load() not needed for these tests');
  }
}
