import 'package:flutter/material.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/l10n/l10n_x.dart';
import 'package:openplants/widgets/app_segmented_triple_control.dart';

class MoreSettingsPage extends StatelessWidget {
  const MoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = AppScope.of(context).settings;
    final services = AppScope.of(context).services;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([settingsController, services.localeService]),
        builder: (context, _) {
          final settings = settingsController.settings;
          final supportedLocaleCodes = AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toSet();

          // 0 = system, 1 = light, 2 = dark
          final initialSelection = settings.useSystemDarkmode
              ? 0
              : settings.useDarkmode
                  ? 2
                  : 1;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.l10n.themeLabel,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              AppSegmentedTripleControl(
                leftTitle: context.l10n.themeSystem,
                centerTitle: context.l10n.themeLight,
                rightTitle: context.l10n.themeDark,
                initialSelection: initialSelection,
                onChanged: (selected) async {
                  final useSystemDarkmode = selected == 0;
                  final useDarkmode = selected == 2;

                  await _saveSettings(
                    context,
                    () => settingsController.update(
                      settings.copyWith(
                        useSystemDarkmode: useSystemDarkmode,
                        useDarkmode: useDarkmode,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.languageLabel,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: settings.localeCode != null && supportedLocaleCodes.contains(settings.localeCode)
                    ? settings.localeCode
                    : 'system',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(context.l10n.languageSystem),
                  ),
                  ...AppLocalizations.supportedLocales.map(
                    (locale) => DropdownMenuItem(
                      value: locale.languageCode,
                      child: Text(
                        switch (locale.languageCode) {
                          'en' => context.l10n.languageEnglish,
                          'de' => context.l10n.languageGerman,
                          _ => locale.languageCode,
                        },
                      ),
                    ),
                  ),
                ],
                onChanged: (val) async {
                  if (val == null) return;
                  await _saveSettings(
                    context,
                    () => services.localeService.setLocale(val == 'system' ? null : val),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.temperatureUnitLabel,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              SegmentedButton<TemperatureUnit>(
                segments: [
                  ButtonSegment(
                    value: TemperatureUnit.celsius,
                    label: Text(context.l10n.temperatureCelsius),
                  ),
                  ButtonSegment(
                    value: TemperatureUnit.fahrenheit,
                    label: Text(context.l10n.temperatureFahrenheit),
                  ),
                ],
                selected: {settings.temperatureUnit},
                onSelectionChanged: (selected) async {
                  if (selected.isEmpty) return;
                  await _saveSettings(
                    context,
                    () => settingsController.update(
                      settings.copyWith(temperatureUnit: selected.first),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.accessibilityLabel,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.useSystemTextScaling),
                value: settings.useSystemTextScaling,
                onChanged: (val) async {
                  await _saveSettings(
                    context,
                    () => settingsController.update(settings.copyWith(useSystemTextScaling: val)),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _saveSettings(BuildContext context, Future<void> Function() save) async {
  try {
    await save();
  } catch (error) {
    debugPrint('Failed to save app settings: $error');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.unexpectedError)));
  }
}
