import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/app_services.dart';
import 'package:openplants/core/injection.dart' as ic;
import 'package:openplants/core/settings.dart';
import 'package:openplants/core/themes.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/l10n/l10n_x.dart';
import 'package:openplants/pages/home/home_page.dart';
import 'package:openplants/pages/home/onboarding.dart';
import 'package:openplants/pages/notifications/notification_entity.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Disable noisy logs in release.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) => '';

  await ic.init();
  final settings = ic.sl<SettingsController>();
  final services = ic.sl<AppServices>();
  await services.plantDeletion.retryPendingDeletions();

  runApp(
    AppScope(
      settings: settings,
      services: services,
      child: const OpenPlantsApp(),
    ),
  );
}

class OpenPlantsApp extends StatefulWidget {
  const OpenPlantsApp({super.key});

  @override
  State<OpenPlantsApp> createState() => _OpenPlantsAppState();
}

class _OpenPlantsAppState extends State<OpenPlantsApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _mainNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();
  AppServices? _services;
  SettingsController? _settingsController;
  Settings? _previousSettings;
  Locale? _previousLocale;
  StreamSubscription<String>? _timezoneSubscription;
  NotificationPayload? _pendingNotification;
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);

    if (_settingsController != scope.settings) {
      _settingsController?.removeListener(_onSettingsChanged);
      _settingsController = scope.settings..addListener(_onSettingsChanged);
      _previousSettings = scope.settings.settings;
    }
    if (_services != scope.services) {
      _services?.localeService.removeListener(_onLocaleChanged);
      _services = scope.services..localeService.addListener(_onLocaleChanged);
      _previousLocale = scope.services.localeService.activeLocale;
    }

    if (!_notificationsInitialized) {
      _notificationsInitialized = true;
      unawaited(_startNotifications());
    }
  }

  Future<void> _startNotifications() async {
    final services = _services;
    if (services == null) return;

    try {
      final launchPayload = await services.notification.initialize(onNotificationTap: _handleNotificationTap);
      if (launchPayload != null) _handleNotificationTap(launchPayload);
    } catch (error) {
      debugPrint('Failed to initialize local notifications: $error');
    }

    _timezoneSubscription = services.notification.localTimezoneChanges.listen(
      (_) => unawaited(_refreshTimezoneAndReconcile()),
      onError: (Object error) => debugPrint('Failed to receive timezone change: $error'),
    );
    await _refreshTimezoneAndReconcile();
  }

  Future<void> _refreshTimezoneAndReconcile() async {
    final services = _services;
    if (services == null) return;
    if (!await services.notification.refreshLocalTimezone()) {
      debugPrint('Skipping care notification reconciliation because the local timezone is unavailable');
      return;
    }
    await services.notificationReconciler.reconcileSafely();
  }

  void _handleNotificationTap(NotificationPayload payload) {
    _pendingNotification = payload;
    _dispatchPendingNotification();
  }

  void _dispatchPendingNotification() {
    if (_pendingNotification == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = _pendingNotification;
      final home = _homePageKey.currentState;
      if (!mounted || payload == null || home == null) return;
      _pendingNotification = null;
      unawaited(home.openNotification(payload));
    });
  }

  void _onSettingsChanged() {
    final settings = _settingsController?.settings;
    if (settings == null) return;
    final previous = _previousSettings;
    _previousSettings = settings;

    if (previous == null ||
        previous.notificationsEnabled != settings.notificationsEnabled ||
        previous.notifyDueTasks != settings.notifyDueTasks ||
        previous.notifyOverdueTasks != settings.notifyOverdueTasks) {
      final services = _services;
      if (services != null) unawaited(services.notificationReconciler.reconcileSafely());
    }
    if (previous?.didCompleteOnboarding != settings.didCompleteOnboarding) {
      _dispatchPendingNotification();
    }
  }

  void _onLocaleChanged() {
    final locale = _services?.localeService.activeLocale;
    if (locale == null || locale == _previousLocale) return;
    _previousLocale = locale;
    final services = _services;
    if (services != null) unawaited(services.notificationReconciler.reconcileSafely());
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _onLocaleChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshTimezoneAndReconcile());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsController?.removeListener(_onSettingsChanged);
    _services?.localeService.removeListener(_onLocaleChanged);
    _timezoneSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([scope.settings, scope.services.localeService]),
      builder: (context, _) {
        final settings = scope.settings.settings;
        final themeMode =
            settings.useSystemDarkmode ? ThemeMode.system : (settings.useDarkmode ? ThemeMode.dark : ThemeMode.light);
        final locale = scope.services.localeService.activeLocale;

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
                textScaler: settings.useSystemTextScaling ? mq.textScaler : TextScaler.noScaling,
              ),
              child: child,
            );
          },
          home: settings.didCompleteOnboarding
              ? HomePage(key: _homePageKey, mainNavigatorKey: _mainNavigatorKey)
              : const OnboardingPage(),
        );
      },
    );
  }
}
