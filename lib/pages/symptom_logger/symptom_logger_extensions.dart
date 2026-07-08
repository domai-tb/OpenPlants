import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

// ---------------------------------------------------------------------------
// SymptomType
// ---------------------------------------------------------------------------

/// UI helpers for [SymptomType].
extension SymptomTypeX on SymptomType {
  IconData get icon {
    switch (this) {
      case SymptomType.yellowLeaves:
        return Icons.eco;
      case SymptomType.brownTips:
        return Icons.local_fire_department;
      case SymptomType.drooping:
        return Icons.arrow_downward;
      case SymptomType.pests:
        return Icons.bug_report;
      case SymptomType.mold:
        return Icons.blur_on;
      case SymptomType.softStems:
        return Icons.gesture;
      case SymptomType.drySoil:
        return Icons.water_drop_outlined;
      case SymptomType.wetSoil:
        return Icons.water_drop;
      case SymptomType.leafSpots:
        return Icons.circle_outlined;
    }
  }

  String label(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case SymptomType.yellowLeaves:
        return l10n.symptomTypeYellowLeaves;
      case SymptomType.brownTips:
        return l10n.symptomTypeBrownTips;
      case SymptomType.drooping:
        return l10n.symptomTypeDrooping;
      case SymptomType.pests:
        return l10n.symptomTypePests;
      case SymptomType.mold:
        return l10n.symptomTypeMold;
      case SymptomType.softStems:
        return l10n.symptomTypeSoftStems;
      case SymptomType.drySoil:
        return l10n.symptomTypeDrySoil;
      case SymptomType.wetSoil:
        return l10n.symptomTypeWetSoil;
      case SymptomType.leafSpots:
        return l10n.symptomTypeLeafSpots;
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
