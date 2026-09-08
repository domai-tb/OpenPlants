import 'package:flutter_test/flutter_test.dart';
import 'package:openplants/pages/species_catalog/species_catalog_entity.dart';

void main() {
  group('SpeciesCatalogEntry', () {
    test('fromJson round-trips correctly', () {
      final json = {
        'id': 'monstera_deliciosa',
        'modelIndex': 42,
        'scientificName': 'Monstera deliciosa',
        'aliases': ['Swiss Cheese Plant'],
        'careMeta': {
          'difficulty': 'easy',
          'lightNeeds': 'medium',
          'waterNeeds': 'moderate',
          'humidityPreference': 'moderate',
          'soilType': 'Well-draining',
          'repottingIntervalMonths': 24,
          'toxicToHumans': true,
          'toxicToPets': true,
        },
      };

      final entry = SpeciesCatalogEntry.fromJson(json);
      expect(entry.id, 'monstera_deliciosa');
      expect(entry.modelIndex, 42);
      expect(entry.scientificName, 'Monstera deliciosa');
      expect(entry.aliases, ['Swiss Cheese Plant']);
      expect(entry.careMeta.difficulty, 'easy');
    });

    test('toJson round-trips correctly', () {
      const entry = SpeciesCatalogEntry(
        id: 'test_species',
        scientificName: 'Test species',
        careMeta: SpeciesCareMeta(
          difficulty: 'easy',
          lightNeeds: 'low',
          waterNeeds: 'low',
          humidityPreference: 'low',
          soilType: 'Any',
          repottingIntervalMonths: 12,
          toxicToHumans: false,
          toxicToPets: false,
        ),
      );

      final json = entry.toJson();
      final restored = SpeciesCatalogEntry.fromJson(json);
      expect(restored.id, entry.id);
      expect(restored.scientificName, entry.scientificName);
    });

    test('handles missing optional fields', () {
      final json = {
        'id': 'minimal',
        'scientificName': 'Minimal species',
        'careMeta': {
          'difficulty': 'easy',
          'lightNeeds': 'low',
          'waterNeeds': 'low',
          'humidityPreference': 'low',
          'soilType': 'Any',
          'repottingIntervalMonths': 12,
          'toxicToHumans': false,
          'toxicToPets': false,
        },
      };

      final entry = SpeciesCatalogEntry.fromJson(json);
      expect(entry.modelIndex, isNull);
      expect(entry.aliases, isEmpty);
    });
  });

  group('SpeciesLocaleData', () {
    test('fromJson works correctly', () {
      final json = {
        'locale': 'monstera_deliciosa',
        'commonName': 'Swiss Cheese Plant',
        'commonNames': ['Swiss Cheese Plant', 'Split-Leaf Philodendron'],
        'description': 'A popular tropical plant.',
        'careSummary': 'Easy to care for.',
      };

      final data = SpeciesLocaleData.fromJson(json);
      expect(data.locale, 'monstera_deliciosa');
      expect(data.commonName, 'Swiss Cheese Plant');
      expect(data.commonNames.length, 2);
      expect(data.description, 'A popular tropical plant.');
    });
  });

  group('ResolvedSpecies', () {
    test('displayName returns commonName from locale data', () {
      const entry = SpeciesCatalogEntry(
        id: 'test',
        scientificName: 'Test species',
        careMeta: SpeciesCareMeta(
          difficulty: 'easy',
          lightNeeds: 'low',
          waterNeeds: 'low',
          humidityPreference: 'low',
          soilType: 'Any',
          repottingIntervalMonths: 12,
          toxicToHumans: false,
          toxicToPets: false,
        ),
      );

      const localeData = SpeciesLocaleData(
        locale: 'test',
        commonName: 'Test Plant',
      );

      const resolved = ResolvedSpecies(catalog: entry, localeData: localeData);
      expect(resolved.displayName, 'Test Plant');
      expect(resolved.scientificName, 'Test species');
      expect(resolved.id, 'test');
    });
  });
}
