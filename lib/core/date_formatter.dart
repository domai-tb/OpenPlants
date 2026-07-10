import 'package:intl/intl.dart';

import 'package:open_plant/core/locale_service.dart';

/// Provides locale-aware date formatting using the active locale.
class DateFormatter {
  final LocaleService _localeService;

  const DateFormatter(this._localeService);

  /// Formats a [DateTime] using the active locale's short date pattern.
  ///
  /// English: `"Jul 6, 2026"` · German: `"6. Juli 2026"`
  String formatShort(DateTime date) {
    final locale = _localeService.activeLocale;
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  /// Formats a [DateTime] using the active locale's medium date pattern.
  ///
  /// English: `"Jul 6, 2026"` · German: `"6. Jul. 2026"`
  String formatMedium(DateTime date) {
    final locale = _localeService.activeLocale;
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  /// Formats a [DateTime] using the active locale's time pattern.
  ///
  /// English: `"3:04 PM"` · German: `"15:04"`
  String formatTime(DateTime date) {
    final locale = _localeService.activeLocale;
    return DateFormat.Hm(locale.languageCode).format(date);
  }

  /// Formats a [DateTime] using the active locale's full date-time pattern.
  String formatFull(DateTime date) {
    final locale = _localeService.activeLocale;
    return DateFormat.yMMMMd(locale.languageCode).format(date);
  }
}
