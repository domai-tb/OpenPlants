import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';

/// Extension on JournalEntryType for UI helpers.
extension JournalEntryTypeUI on JournalEntryType {
  /// Returns the localized label for this entry type.
  String label(BuildContext context) {
    switch (this) {
      case JournalEntryType.text:
        return context.l10n.journalTypeText;
      case JournalEntryType.photo:
        return context.l10n.journalTypePhoto;
      case JournalEntryType.task:
        return context.l10n.journalTypeTask;
      case JournalEntryType.growth:
        return context.l10n.journalTypeGrowth;
      case JournalEntryType.repotting:
        return context.l10n.journalTypeRepotting;
      case JournalEntryType.pest:
        return context.l10n.journalTypePest;
      case JournalEntryType.diagnosis:
        return context.l10n.journalTypeDiagnosis;
    }
  }

  /// Returns the icon for this entry type.
  IconData get icon {
    switch (this) {
      case JournalEntryType.text:
        return Icons.notes;
      case JournalEntryType.photo:
        return Icons.photo_camera;
      case JournalEntryType.task:
        return Icons.check_circle_outline;
      case JournalEntryType.growth:
        return Icons.trending_up;
      case JournalEntryType.repotting:
        return Icons.transfer_within_a_station;
      case JournalEntryType.pest:
        return Icons.bug_report;
      case JournalEntryType.diagnosis:
        return Icons.medical_services;
    }
  }
}

/// Locale-aware date formatting.
String formatJournalDate(DateTime date, BuildContext context) {
  return DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date);
}
