import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsController with ChangeNotifier {
  static const String _prefsKey = 'app_settings_json_v1';

  final SharedPreferences _prefs;
  Settings _settings;

  SettingsController._(this._prefs, this._settings);

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_prefsKey);
    Settings settings = const Settings();

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        settings = Settings.fromJson(Map<String, dynamic>.from(decoded as Map));
      } catch (_) {
        settings = const Settings();
      }
    }

    return SettingsController._(prefs, settings);
  }

  Settings get settings => _settings;

  void update(Settings newSettings) {
    _settings = newSettings;
    notifyListeners();

    final raw = jsonEncode(newSettings.toJson());
    unawaited(_prefs.setString(_prefsKey, raw));
  }
}

class Settings {
  static const Object _noChange = Object();

  final bool useSystemDarkmode;
  final bool useDarkmode;
  final bool useSystemTextScaling;
  final bool didCompleteOnboarding;
  final String? localeCode;
  final TemperatureUnit temperatureUnit;
  final bool notificationsEnabled;
  final bool notifyDueTasks;
  final bool notifyOverdueTasks;

  const Settings({
    this.useSystemDarkmode = true,
    this.useDarkmode = false,
    this.useSystemTextScaling = false,
    this.didCompleteOnboarding = false,
    this.localeCode,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.notificationsEnabled = true,
    this.notifyDueTasks = true,
    this.notifyOverdueTasks = true,
  });

  Settings copyWith({
    bool? useSystemDarkmode,
    bool? useDarkmode,
    bool? useSystemTextScaling,
    bool? didCompleteOnboarding,
    Object? localeCode = _noChange,
    TemperatureUnit? temperatureUnit,
    bool? notificationsEnabled,
    bool? notifyDueTasks,
    bool? notifyOverdueTasks,
  }) {
    return Settings(
      useSystemDarkmode: useSystemDarkmode ?? this.useSystemDarkmode,
      useDarkmode: useDarkmode ?? this.useDarkmode,
      useSystemTextScaling: useSystemTextScaling ?? this.useSystemTextScaling,
      didCompleteOnboarding: didCompleteOnboarding ?? this.didCompleteOnboarding,
      localeCode: identical(localeCode, _noChange) ? this.localeCode : localeCode as String?,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyDueTasks: notifyDueTasks ?? this.notifyDueTasks,
      notifyOverdueTasks: notifyOverdueTasks ?? this.notifyOverdueTasks,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      useSystemDarkmode: json['useSystemDarkmode'] ?? true,
      useDarkmode: json['useDarkmode'] ?? false,
      useSystemTextScaling: json['useSystemTextScaling'] ?? false,
      didCompleteOnboarding: json['didCompleteOnboarding'] ?? false,
      localeCode: json['localeCode'],
      temperatureUnit: json['temperatureUnit'] == 'fahrenheit' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notifyDueTasks: json['notifyDueTasks'] ?? true,
      notifyOverdueTasks: json['notifyOverdueTasks'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'useSystemDarkmode': useSystemDarkmode,
      'useDarkmode': useDarkmode,
      'useSystemTextScaling': useSystemTextScaling,
      'didCompleteOnboarding': didCompleteOnboarding,
      'localeCode': localeCode,
      'temperatureUnit': temperatureUnit == TemperatureUnit.fahrenheit ? 'fahrenheit' : 'celsius',
      'notificationsEnabled': notificationsEnabled,
      'notifyDueTasks': notifyDueTasks,
      'notifyOverdueTasks': notifyOverdueTasks,
    };
  }
}
