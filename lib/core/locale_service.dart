import 'package:flutter/material.dart';

import 'package:open_plant/core/settings.dart';
import 'package:open_plant/l10n/l10n.dart';

/// Manages the active locale, resolving the user's preference against the
/// system locale and the set of supported locales.
///
/// Listens to [SettingsController] for preference changes and notifies the
/// widget tree via [ChangeNotifier] so [MaterialApp] can rebuild.
class LocaleService extends ChangeNotifier {
  final SettingsController _settingsController;

  LocaleService(this._settingsController) {
    _settingsController.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    notifyListeners();
  }

  /// Returns the effective locale: explicit override → system → fallback (en).
  Locale get activeLocale {
    final code = _settingsController.settings.localeCode;
    if (code != null && code.isNotEmpty) {
      final candidate = Locale(code);
      if (isSupported(candidate)) return candidate;
    }

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (isSupported(systemLocale)) return systemLocale;

    return const Locale('en');
  }

  /// Updates the locale preference. Pass `null` to revert to system default.
  void setLocale(String? localeCode) {
    _settingsController.update(
      _settingsController.settings.copyWith(
        localeCode: localeCode,
      ),
    );
  }

  /// Whether [locale] is in the list of supported locales.
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  void dispose() {
    _settingsController.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
