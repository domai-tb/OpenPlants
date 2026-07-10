import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:open_plant/core/settings.dart';

/// Formats temperature values according to the user's unit preference
/// and the active locale's number conventions.
class TemperatureFormatter {
  final SettingsController _settingsController;

  const TemperatureFormatter(this._settingsController);

  /// Formats a raw Celsius value into a locale-aware display string.
  ///
  /// Returns `"25°C"` or `"77°F"` (with locale-appropriate number formatting).
  String format(double celsius, {Locale? locale}) {
    final unit = _settingsController.settings.temperatureUnit;
    final value = unit == TemperatureUnit.fahrenheit ? celsius * 9 / 5 + 32 : celsius;
    final symbol = unit == TemperatureUnit.fahrenheit ? '°F' : '°C';

    final formatter = NumberFormat('#,##0.#', locale?.languageCode);
    return '${formatter.format(value)}$symbol';
  }
}
