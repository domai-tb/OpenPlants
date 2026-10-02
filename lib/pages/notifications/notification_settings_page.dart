import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/l10n/l10n_x.dart';

/// Notification settings page.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> with WidgetsBindingObserver {
  bool? _permissionGranted;
  bool _permissionBlocked = false;
  bool _requestingPermission = false;
  bool _loadingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadingPermission && _permissionGranted == null) unawaited(_refreshPermission());
  }

  Future<void> _refreshPermission() async {
    _loadingPermission = true;
    final notification = AppScope.of(context).services.notification;
    final granted = await notification.areNotificationsEnabled();
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      if (granted) _permissionBlocked = false;
      _loadingPermission = false;
    });
  }

  Future<void> _requestPermission() async {
    setState(() => _requestingPermission = true);
    final services = AppScope.of(context).services;
    final granted = await services.notification.requestPermissions();
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      _permissionBlocked = !granted;
      _requestingPermission = false;
    });
    if (granted) await services.notificationReconciler.reconcileSafely();
  }

  Future<void> _openSettings() async {
    await AppScope.of(context).services.notification.openNotificationSettings();
  }

  Future<void> _saveSettings(Future<void> Function() save) async {
    try {
      await save();
    } catch (error) {
      debugPrint('Failed to save notification settings: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.unexpectedError)));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final permissionGranted = _permissionGranted;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationsTitle),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(context.l10n.notificationsEnable),
            subtitle: Text(context.l10n.notificationsEnableDescription),
            value: settings.settings.notificationsEnabled,
            onChanged: (value) async {
              await _saveSettings(() => settings.update(settings.settings.copyWith(notificationsEnabled: value)));
            },
          ),
          ListTile(
            leading: Icon(
              permissionGranted == true ? Icons.notifications_active : Icons.notifications_off,
            ),
            title: Text(context.l10n.notificationsPermissionStatus),
            subtitle: Text(
              permissionGranted == true
                  ? context.l10n.notificationsPermissionEnabled
                  : context.l10n.notificationsPermissionDisabled,
            ),
          ),
          if (permissionGranted != true) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.l10n.notificationsPermissionExplanation),
            ),
            if (_permissionBlocked)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(context.l10n.notificationsPermissionBlocked),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _requestingPermission ? null : _requestPermission,
                    icon: _requestingPermission
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.notifications_active),
                    label: Text(context.l10n.notificationsRequestPermission),
                  ),
                  TextButton(
                    onPressed: _openSettings,
                    child: Text(context.l10n.notificationsOpenSettings),
                  ),
                ],
              ),
            ),
          ],
          const Divider(),
          SwitchListTile(
            title: Text(context.l10n.notificationsDueTasks),
            subtitle: Text(context.l10n.notificationsDueTasksDescription),
            value: settings.settings.notifyDueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) async {
                    await _saveSettings(() => settings.update(settings.settings.copyWith(notifyDueTasks: value)));
                  }
                : null,
          ),
          SwitchListTile(
            title: Text(context.l10n.notificationsOverdueTasks),
            subtitle: Text(context.l10n.notificationsOverdueTasksDescription),
            value: settings.settings.notifyOverdueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) async {
                    await _saveSettings(() => settings.update(settings.settings.copyWith(notifyOverdueTasks: value)));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
