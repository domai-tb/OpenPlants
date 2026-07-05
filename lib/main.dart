import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/app_services.dart';
import 'package:open_plant/core/injection.dart' as ic;
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/core/themes.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/home_page.dart';
import 'package:open_plant/pages/home/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable noisy logs in release.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) => '';

  await ic.init();
  final settings = ic.sl<SettingsController>();
  final services = ic.sl<AppServices>();

  runApp(
    AppScope(
      settings: settings,
      services: services,
      child: const OpenPlantApp(),
    ),
  );
}

class OpenPlantApp extends StatefulWidget {
  const OpenPlantApp({super.key});

  @override
  State<OpenPlantApp> createState() => _OpenPlantAppState();
}

class _OpenPlantAppState extends State<OpenPlantApp> {
  final GlobalKey<NavigatorState> _mainNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return AnimatedBuilder(
      animation: scope.settings,
      builder: (context, _) {
        final settings = scope.settings.settings;
        final themeMode = settings.useSystemDarkmode
            ? ThemeMode.system
            : (settings.useDarkmode ? ThemeMode.dark : ThemeMode.light);
        final locale =
            settings.localeCode == null ? null : Locale(settings.localeCode!);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: settings.useSystemTextScaling
                    ? mq.textScaler
                    : TextScaler.noScaling,
              ),
              child: child,
            );
          },
          home: settings.didCompleteOnboarding
              ? HomePage(mainNavigatorKey: _mainNavigatorKey)
              : OnboardingPage(mainNavigatorKey: _mainNavigatorKey),
        );
      },
    );
  }
}
