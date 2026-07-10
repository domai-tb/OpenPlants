import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';

/// Minimal page for the plant names feature module.
///
/// This module primarily provides data-layer services (getDisplayName)
/// consumed by other pages. This page exists to satisfy the 5-file pattern
/// and can serve as a future navigation target if needed.
class PlantNamesPage extends StatelessWidget {
  const PlantNamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.plantNamesTitle),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Text(context.l10n.plantNamesDescription),
      ),
    );
  }
}
