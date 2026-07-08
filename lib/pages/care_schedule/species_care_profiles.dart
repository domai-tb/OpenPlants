import 'package:open_plant/pages/care_schedule/species_care_profile.dart';

/// Hardcoded species care profiles for common houseplants.
class SpeciesCareProfiles {
  SpeciesCareProfiles._();

  static final Map<String, SpeciesCareProfile> profiles = {
    'pothos': _pothos,
    'snake_plant': _snakePlant,
    'monstera': _monstera,
    'succulent': _succulent,
    'fern': _fern,
    'cactus': _cactus,
    'peace_lily': _peaceLily,
    'rubber_plant': _rubberPlant,
    'spider_plant': _spiderPlant,
    'aloe_vera': _aloeVera,
    'fiddle_leaf_fig': _fiddleLeafFig,
    'boston_fern': _bostonFern,
  };

  /// The general fallback profile with conservative defaults.
  static const SpeciesCareProfile general = SpeciesCareProfile(
    id: 'general',
    name: 'General',
    defaultIntervals: {
      'watering': 7,
      'fertilizing': 30,
      'misting': 7,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
  );

  /// Get a profile by ID, falling back to general if not found.
  /// Normalizes free-text input (lowercase, spaces → underscores).
  static SpeciesCareProfile getProfile(String? speciesId) {
    if (speciesId == null || speciesId.trim().isEmpty) return general;
    final normalized =
        speciesId.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    return profiles[normalized] ?? general;
  }

  static const _pothos = SpeciesCareProfile(
    id: 'pothos',
    name: 'Pothos',
    defaultIntervals: {
      'watering': 7,
      'fertilizing': 30,
      'misting': 0,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.2, 1.2, 1.0, 1.0, 0.8, 0.8, 0.8, 0.8, 1.0, 1.0, 1.2, 1.3],
      'fertilizing': [1.3, 1.3, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.3],
    },
  );

  static const _snakePlant = SpeciesCareProfile(
    id: 'snake_plant',
    name: 'Snake Plant',
    defaultIntervals: {
      'watering': 14,
      'fertilizing': 60,
      'misting': 0,
      'pruning': 90,
      'rotating': 30,
      'repotting': 730,
      'leafCleaning': 30,
      'pestInspection': 30,
    },
    seasonalModifiers: {
      'watering': [1.5, 1.5, 1.2, 1.0, 0.8, 0.8, 0.8, 0.8, 1.0, 1.2, 1.5, 1.5],
    },
  );

  static const _monstera = SpeciesCareProfile(
    id: 'monstera',
    name: 'Monstera',
    defaultIntervals: {
      'watering': 7,
      'fertilizing': 21,
      'misting': 3,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
      'fertilizing': [1.3, 1.3, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.3],
    },
  );

  static const _succulent = SpeciesCareProfile(
    id: 'succulent',
    name: 'Succulent',
    defaultIntervals: {
      'watering': 14,
      'fertilizing': 60,
      'misting': 0,
      'pruning': 90,
      'rotating': 30,
      'repotting': 730,
      'leafCleaning': 30,
      'pestInspection': 30,
    },
    seasonalModifiers: {
      'watering': [1.5, 1.5, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.5],
    },
  );

  static const _fern = SpeciesCareProfile(
    id: 'fern',
    name: 'Fern',
    defaultIntervals: {
      'watering': 3,
      'fertilizing': 30,
      'misting': 2,
      'pruning': 30,
      'rotating': 7,
      'repotting': 365,
      'leafCleaning': 7,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
      'misting': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
    },
  );

  static const _cactus = SpeciesCareProfile(
    id: 'cactus',
    name: 'Cactus',
    defaultIntervals: {
      'watering': 21,
      'fertilizing': 60,
      'misting': 0,
      'pruning': 90,
      'rotating': 30,
      'repotting': 730,
      'leafCleaning': 30,
      'pestInspection': 30,
    },
    seasonalModifiers: {
      'watering': [1.5, 1.5, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.5],
    },
  );

  static const _peaceLily = SpeciesCareProfile(
    id: 'peace_lily',
    name: 'Peace Lily',
    defaultIntervals: {
      'watering': 5,
      'fertilizing': 30,
      'misting': 3,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.2, 1.2, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.2],
    },
  );

  static const _rubberPlant = SpeciesCareProfile(
    id: 'rubber_plant',
    name: 'Rubber Plant',
    defaultIntervals: {
      'watering': 10,
      'fertilizing': 30,
      'misting': 7,
      'pruning': 60,
      'rotating': 14,
      'repotting': 730,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
    },
  );

  static const _spiderPlant = SpeciesCareProfile(
    id: 'spider_plant',
    name: 'Spider Plant',
    defaultIntervals: {
      'watering': 7,
      'fertilizing': 30,
      'misting': 7,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.2, 1.2, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.2],
    },
  );

  static const _aloeVera = SpeciesCareProfile(
    id: 'aloe_vera',
    name: 'Aloe Vera',
    defaultIntervals: {
      'watering': 14,
      'fertilizing': 60,
      'misting': 0,
      'pruning': 90,
      'rotating': 30,
      'repotting': 730,
      'leafCleaning': 30,
      'pestInspection': 30,
    },
    seasonalModifiers: {
      'watering': [1.5, 1.5, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.5],
    },
  );

  static const _fiddleLeafFig = SpeciesCareProfile(
    id: 'fiddle_leaf_fig',
    name: 'Fiddle Leaf Fig',
    defaultIntervals: {
      'watering': 7,
      'fertilizing': 30,
      'misting': 3,
      'pruning': 60,
      'rotating': 14,
      'repotting': 365,
      'leafCleaning': 14,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
      'fertilizing': [1.3, 1.3, 1.0, 0.8, 0.7, 0.7, 0.7, 0.7, 0.8, 1.0, 1.3, 1.3],
    },
  );

  static const _bostonFern = SpeciesCareProfile(
    id: 'boston_fern',
    name: 'Boston Fern',
    defaultIntervals: {
      'watering': 3,
      'fertilizing': 21,
      'misting': 2,
      'pruning': 30,
      'rotating': 7,
      'repotting': 365,
      'leafCleaning': 7,
      'pestInspection': 14,
    },
    seasonalModifiers: {
      'watering': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
      'misting': [1.3, 1.3, 1.0, 0.9, 0.8, 0.8, 0.8, 0.8, 0.9, 1.0, 1.2, 1.3],
    },
  );
}
