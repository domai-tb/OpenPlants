import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';
import 'package:openplants/pages/species_library/species_library_item_entity.dart';

/// Maps species characteristics to default care rule templates.
///
/// Returns one [CustomCareRuleEntity] per built-in task type with a non-zero
/// interval. Low-humidity species omit the misting rule.
List<CustomCareRuleEntity> speciesCarePresets(
  SpeciesEntity species, {
  required String plantId,
}) {
  final now = DateTime.now();
  final rules = <CustomCareRuleEntity>[];

  int idCounter = 0;
  String nextId() => '${plantId}_preset_${idCounter++}';

  // Watering: frequent→5d, moderate→7d, low→10d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.watering.name,
      intervalDays: _wateringInterval(species.waterNeeds),
      createdAt: now,
    ),
  );

  // Fertilizing: frequent→14d, moderate→21d, low→30d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.fertilizing.name,
      intervalDays: _fertilizingInterval(species.waterNeeds),
      createdAt: now,
    ),
  );

  // Misting: high→3d, moderate→5d, low→skip (omitted)
  final mistingDays = _mistingInterval(species.humidityPreference);
  if (mistingDays > 0) {
    rules.add(
      CustomCareRuleEntity(
        id: nextId(),
        plantId: plantId,
        taskType: BuiltInTaskType.misting.name,
        intervalDays: mistingDays,
        createdAt: now,
      ),
    );
  }

  // Pruning: fixed 30d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.pruning.name,
      intervalDays: 30,
      createdAt: now,
    ),
  );

  // Rotating: fixed 14d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.rotating.name,
      intervalDays: 14,
      createdAt: now,
    ),
  );

  // Repotting: months × 30
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.repotting.name,
      intervalDays: species.repottingIntervalMonths * 30,
      createdAt: now,
    ),
  );

  // Leaf cleaning: fixed 14d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.leafCleaning.name,
      intervalDays: 14,
      createdAt: now,
    ),
  );

  // Pest inspection: fixed 21d
  rules.add(
    CustomCareRuleEntity(
      id: nextId(),
      plantId: plantId,
      taskType: BuiltInTaskType.pestInspection.name,
      intervalDays: 21,
      createdAt: now,
    ),
  );

  return rules;
}

int _wateringInterval(WaterNeeds needs) {
  switch (needs) {
    case WaterNeeds.frequent:
      return 5;
    case WaterNeeds.moderate:
      return 7;
    case WaterNeeds.low:
      return 10;
  }
}

int _fertilizingInterval(WaterNeeds needs) {
  switch (needs) {
    case WaterNeeds.frequent:
      return 14;
    case WaterNeeds.moderate:
      return 21;
    case WaterNeeds.low:
      return 30;
  }
}

int _mistingInterval(HumidityPreference pref) {
  switch (pref) {
    case HumidityPreference.high:
      return 3;
    case HumidityPreference.moderate:
      return 5;
    case HumidityPreference.low:
      return 0;
  }
}
