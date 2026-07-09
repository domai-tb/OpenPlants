import 'package:flutter/material.dart';

import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Data model representing a light level option for the UI selector.
class LightAssessmentItem {
  final LightLevel level;
  final String label;
  final String description;
  final IconData icon;

  const LightAssessmentItem({
    required this.level,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// All available light level options.
  static const List<LightAssessmentItem> options = [
    LightAssessmentItem(
      level: LightLevel.low,
      label: 'Low',
      description: 'Dark corners, north-facing windows, interior rooms',
      icon: Icons.dark_mode,
    ),
    LightAssessmentItem(
      level: LightLevel.medium,
      label: 'Medium',
      description: 'East-facing windows, indirect light most of the day',
      icon: Icons.wb_sunny_outlined,
    ),
    LightAssessmentItem(
      level: LightLevel.brightIndirect,
      label: 'Bright Indirect',
      description: 'Near south/west windows but not in direct rays',
      icon: Icons.wb_sunny,
    ),
    LightAssessmentItem(
      level: LightLevel.direct,
      label: 'Direct',
      description: 'Direct sun rays hitting the plant for 4+ hours',
      icon: Icons.local_fire_department,
    ),
  ];

  /// Find the option matching a [LightLevel].
  static LightAssessmentItem? findByLevel(LightLevel level) {
    return options.where((o) => o.level == level).firstOrNull;
  }
}
