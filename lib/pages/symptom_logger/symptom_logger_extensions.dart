import 'package:flutter/material.dart';

import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

// ---------------------------------------------------------------------------
// PlantSymptom (unified enum)
// ---------------------------------------------------------------------------

/// UI helpers for [PlantSymptom].
extension PlantSymptomX on PlantSymptom {
  IconData get icon {
    switch (this) {
      case PlantSymptom.yellowingLeaves:
        return Icons.eco;
      case PlantSymptom.brownTips:
        return Icons.local_fire_department;
      case PlantSymptom.droopingWilt:
        return Icons.arrow_downward;
      case PlantSymptom.visibleInsects:
        return Icons.bug_report;
      case PlantSymptom.moldOnSoil:
        return Icons.blur_on;
      case PlantSymptom.softStems:
        return Icons.gesture;
      case PlantSymptom.drySoil:
        return Icons.water_drop_outlined;
      case PlantSymptom.wetSoil:
        return Icons.water_drop;
      case PlantSymptom.leafSpots:
        return Icons.circle_outlined;
      case PlantSymptom.brownPatches:
        return Icons.local_fire_department;
      case PlantSymptom.paleLeaves:
        return Icons.eco;
      case PlantSymptom.leggyGrowth:
        return Icons.trending_up;
      case PlantSymptom.stickyResidue:
        return Icons.water_drop;
      case PlantSymptom.foulSmell:
        return Icons.warning;
      case PlantSymptom.stuntedGrowth:
        return Icons.trending_down;
      case PlantSymptom.leafCurling:
        return Icons.autorenew;
      case PlantSymptom.leafDrop:
        return Icons.eco;
    }
  }

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case PlantSymptom.yellowingLeaves:
        return l10n.symptomTypeYellowLeaves;
      case PlantSymptom.brownTips:
        return l10n.symptomTypeBrownTips;
      case PlantSymptom.droopingWilt:
        return l10n.symptomTypeDrooping;
      case PlantSymptom.visibleInsects:
        return l10n.symptomTypePests;
      case PlantSymptom.moldOnSoil:
        return l10n.symptomTypeMold;
      case PlantSymptom.softStems:
        return l10n.symptomTypeSoftStems;
      case PlantSymptom.drySoil:
        return l10n.symptomTypeDrySoil;
      case PlantSymptom.wetSoil:
        return l10n.symptomTypeWetSoil;
      case PlantSymptom.leafSpots:
        return l10n.symptomTypeLeafSpots;
      case PlantSymptom.brownPatches:
        return 'Brown Patches';
      case PlantSymptom.paleLeaves:
        return 'Pale Leaves';
      case PlantSymptom.leggyGrowth:
        return 'Leggy Growth';
      case PlantSymptom.stickyResidue:
        return 'Sticky Residue';
      case PlantSymptom.foulSmell:
        return 'Foul Smell';
      case PlantSymptom.stuntedGrowth:
        return 'Stunted Growth';
      case PlantSymptom.leafCurling:
        return 'Leaf Curling';
      case PlantSymptom.leafDrop:
        return 'Leaf Drop';
    }
  }
}

// ---------------------------------------------------------------------------
// Severity
// ---------------------------------------------------------------------------

/// UI helpers for [Severity].
extension SeverityX on Severity {
  IconData get icon {
    switch (this) {
      case Severity.mild:
        return Icons.sentiment_satisfied;
      case Severity.moderate:
        return Icons.sentiment_neutral;
      case Severity.severe:
        return Icons.sentiment_dissatisfied;
    }
  }

  Color get color {
    switch (this) {
      case Severity.mild:
        return Colors.green;
      case Severity.moderate:
        return Colors.orange;
      case Severity.severe:
        return Colors.red;
    }
  }

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case Severity.mild:
        return l10n.symptomSeverityMild;
      case Severity.moderate:
        return l10n.symptomSeverityModerate;
      case Severity.severe:
        return l10n.symptomSeveritySevere;
    }
  }

  String description(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case Severity.mild:
        return l10n.symptomSeverityMildDesc;
      case Severity.moderate:
        return l10n.symptomSeverityModerateDesc;
      case Severity.severe:
        return l10n.symptomSeveritySevereDesc;
    }
  }
}

// ---------------------------------------------------------------------------
// AffectedPart
// ---------------------------------------------------------------------------

/// UI helpers for [AffectedPart].
extension AffectedPartX on AffectedPart {
  IconData get icon {
    switch (this) {
      case AffectedPart.leaves:
        return Icons.eco;
      case AffectedPart.stems:
        return Icons.gesture;
      case AffectedPart.roots:
        return Icons.line_style;
      case AffectedPart.soil:
        return Icons.landscape;
      case AffectedPart.flowers:
        return Icons.local_florist;
      case AffectedPart.multipleAreas:
        return Icons.select_all;
    }
  }

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case AffectedPart.leaves:
        return l10n.symptomPartLeaves;
      case AffectedPart.stems:
        return l10n.symptomPartStems;
      case AffectedPart.roots:
        return l10n.symptomPartRoots;
      case AffectedPart.soil:
        return l10n.symptomPartSoil;
      case AffectedPart.flowers:
        return l10n.symptomPartFlowers;
      case AffectedPart.multipleAreas:
        return l10n.symptomPartMultiple;
    }
  }
}

// ---------------------------------------------------------------------------
// OnsetTiming
// ---------------------------------------------------------------------------

/// UI helpers for [OnsetTiming].
extension OnsetTimingX on OnsetTiming {
  IconData get icon {
    switch (this) {
      case OnsetTiming.today:
        return Icons.today;
      case OnsetTiming.fewDaysAgo:
        return Icons.date_range;
      case OnsetTiming.aboutAWeekAgo:
        return Icons.calendar_view_week;
      case OnsetTiming.moreThanAWeekAgo:
        return Icons.calendar_today;
    }
  }

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case OnsetTiming.today:
        return l10n.symptomOnsetToday;
      case OnsetTiming.fewDaysAgo:
        return l10n.symptomOnsetFewDays;
      case OnsetTiming.aboutAWeekAgo:
        return l10n.symptomOnsetAboutWeek;
      case OnsetTiming.moreThanAWeekAgo:
        return l10n.symptomOnsetMoreThanWeek;
    }
  }
}

// ---------------------------------------------------------------------------
// SoilMoisture
// ---------------------------------------------------------------------------

/// UI helpers for [SoilMoisture].
extension SoilMoistureX on SoilMoisture {
  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case SoilMoisture.dry:
        return l10n.symptomSoilDry;
      case SoilMoisture.moist:
        return l10n.symptomSoilMoist;
      case SoilMoisture.wet:
        return l10n.symptomSoilWet;
      case SoilMoisture.soggy:
        return l10n.symptomSoilSoggy;
    }
  }
}

// ---------------------------------------------------------------------------
// LightCondition
// ---------------------------------------------------------------------------

/// UI helpers for [LightCondition].
extension LightConditionX on LightCondition {
  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case LightCondition.fullSun:
        return l10n.symptomLightFullSun;
      case LightCondition.partialShade:
        return l10n.symptomLightPartialShade;
      case LightCondition.lowLight:
        return l10n.symptomLightLowLight;
      case LightCondition.unknown:
        return l10n.symptomLightUnknown;
    }
  }
}
