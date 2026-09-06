import 'package:flutter/material.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/settings.dart';

/// Notification settings page.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Master switch for all notifications'),
            value: settings.settings.notificationsEnabled,
            onChanged: (value) {
              settings.update(settings.settings.copyWith(
                notificationsEnabled: value,
              ));
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Due Task Reminders'),
            subtitle: const Text('Notify when care tasks are due'),
            value: settings.settings.notifyDueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) {
                    settings.update(settings.settings.copyWith(
                      notifyDueTasks: value,
                    ));
                  }
                : null,
          ),
          SwitchListTile(
            title: const Text('Overdue Task Alerts'),
            subtitle: const Text('Alert when care tasks are overdue'),
            value: settings.settings.notifyOverdueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) {
                    settings.update(settings.settings.copyWith(
                      notifyOverdueTasks: value,
                    ));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
