import 'package:flutter/material.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/l10n/l10n_x.dart';

/// Notification settings page.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;

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
            onChanged: (value) {
              settings.update(
                settings.settings.copyWith(
                  notificationsEnabled: value,
                ),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(context.l10n.notificationsDueTasks),
            subtitle: Text(context.l10n.notificationsDueTasksDescription),
            value: settings.settings.notifyDueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) {
                    settings.update(
                      settings.settings.copyWith(
                        notifyDueTasks: value,
                      ),
                    );
                  }
                : null,
          ),
          SwitchListTile(
            title: Text(context.l10n.notificationsOverdueTasks),
            subtitle: Text(context.l10n.notificationsOverdueTasksDescription),
            value: settings.settings.notifyOverdueTasks,
            onChanged: settings.settings.notificationsEnabled
                ? (value) {
                    settings.update(
                      settings.settings.copyWith(
                        notifyOverdueTasks: value,
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
