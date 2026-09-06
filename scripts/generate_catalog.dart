#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// Generates catalog.json and locale JSON files from existing species.json
/// and labels.json.
///
/// Usage: dart scripts/generate_catalog.dart
library;

import 'dart:convert';
import 'dart:io';

void main() {
  final speciesFile = File('assets/species/species.json');
  final labelsFile = File('assets/ml/plant-identification/labels.json');
  final catalogFile = File('assets/species/catalog.json');
  final enLocaleFile = File('assets/species/locales/en.json');

  if (!speciesFile.existsSync()) {
    print('Error: species.json not found');
    exit(1);
  }

  // Load species
  final speciesJson = json.decode(speciesFile.readAsStringSync()) as List<dynamic>;

  // Load labels if available
  Map<int, String> labels = {};
  if (labelsFile.existsSync()) {
    final labelsJson = json.decode(labelsFile.readAsStringSync()) as Map<String, dynamic>;
    labels = labelsJson.map((key, value) => MapEntry(int.parse(key), value as String));
  }

  // Build catalog
  final catalog = <Map<String, dynamic>>[];
  final enLocale = <Map<String, dynamic>>[];

  for (var i = 0; i < speciesJson.length; i++) {
    final species = speciesJson[i] as Map<String, dynamic>;
    final scientificName = species['scientificName'] as String;

    // Generate stable ID from scientific name
    final id = scientificName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');

    // Find model index if labels available
    int? modelIndex;
    if (labels.isNotEmpty) {
      for (final entry in labels.entries) {
        if (entry.value.toLowerCase() == scientificName.toLowerCase()) {
          modelIndex = entry.key;
          break;
        }
      }
    }

    // Build care metadata
    final careMeta = {
      'difficulty': species['difficulty'],
      'lightNeeds': species['lightNeeds'],
      'waterNeeds': species['waterNeeds'],
      'humidityPreference': species['humidityPreference'],
      'soilType': species['soilType'],
      'repottingIntervalMonths': species['repottingIntervalMonths'],
      'toxicToHumans': species['toxicToHumans'],
      'toxicToPets': species['toxicToPets'],
    };

    catalog.add({
      'id': id,
      if (modelIndex != null) 'modelIndex': modelIndex,
      'scientificName': scientificName,
      'aliases': species['commonNames'] ?? [],
      'careMeta': careMeta,
    });

    // Build English locale data
    enLocale.add({
      'locale': id,
      'commonName': (species['commonNames'] as List<dynamic>).firstOrNull ?? scientificName,
      'commonNames': species['commonNames'] ?? [],
      'description': species['description'],
      'careSummary': species['careSummary'],
    });
  }

  // Ensure output directories exist
  Directory('assets/species/locales').createSync(recursive: true);

  // Write catalog
  catalogFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(catalog),
  );
  print('Generated catalog.json with ${catalog.length} species');

  // Write English locale
  enLocaleFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(enLocale),
  );
  print('Generated en.json locale with ${enLocale.length} entries');

  // Validate: check for duplicate IDs
  final ids = catalog.map((e) => e['id'] as String).toList();
  final duplicateIds = ids.where((id) => ids.indexOf(id) != ids.lastIndexOf(id)).toSet();
  if (duplicateIds.isNotEmpty) {
    print('Warning: Duplicate IDs found: $duplicateIds');
  }

  // Validate: check model index coverage
  if (labels.isNotEmpty) {
    final catalogIndices = catalog.where((e) => e.containsKey('modelIndex')).map((e) => e['modelIndex'] as int).toSet();
    final missingIndices = labels.keys.where((i) => !catalogIndices.contains(i)).toSet();
    if (missingIndices.isNotEmpty) {
      print('Warning: ${missingIndices.length} model indices not in catalog');
    }
  }

  print('Done!');
}
