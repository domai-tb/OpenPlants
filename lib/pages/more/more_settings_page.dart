import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/page_navigator.dart';
import 'package:open_plant/pages/home/widgets/nav_bar_preferences_editor.dart';
import 'package:open_plant/widgets/app_segmented_triple_control.dart';

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
          final orderedItems = orderedPageItemsFromSettings(settings.navBarItemOrder);
          final hiddenItems = hiddenPageItemsFromSettings(settings.hiddenNavBarItems);

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
                leftTitle: 'System',
                centerTitle: 'Light',
                rightTitle: 'Dark',
                initialSelection: initialSelection,
                onChanged: (selected) {
                  final useSystemDarkmode = selected == 0;
                  final useDarkmode = selected == 2;

                  settingsController.update(
                    settings.copyWith(
                      useSystemDarkmode: useSystemDarkmode,
                      useDarkmode: useDarkmode,
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
                initialValue: settings.localeCode ?? 'system',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(context.l10n.languageSystem),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(context.l10n.languageEnglish),
                  ),
                  DropdownMenuItem(
                    value: 'de',
                    child: Text(context.l10n.languageGerman),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  services.localeService.setLocale(val == 'system' ? null : val);
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
                onSelectionChanged: (selected) {
                  if (selected.isEmpty) return;
                  settingsController.update(
                    settings.copyWith(temperatureUnit: selected.first),
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
                onChanged: (val) {
                  settingsController.update(settings.copyWith(useSystemTextScaling: val));
                },
              ),
              const SizedBox(height: 24),
              NavBarPreferencesEditor(
                orderedItems: orderedItems,
                hiddenItems: hiddenItems,
                onOrderChanged: (items) {
                  settingsController.update(
                    settings.copyWith(navBarItemOrder: pageItemIds(items)),
                  );
                },
                onHiddenItemsChanged: (items) {
                  settingsController.update(
                    settings.copyWith(hiddenNavBarItems: pageItemIds(items)),
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
