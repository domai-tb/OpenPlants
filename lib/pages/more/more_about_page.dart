import 'package:flutter/material.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/model_info/model_info_page.dart';

class MoreAboutPage extends StatelessWidget {
  const MoreAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(context.l10n.aboutTitle),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.aboutBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Model Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ModelInfoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
