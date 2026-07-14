import 'package:flutter/material.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/pages/model_info/model_info_item_entity.dart';

/// Read-only page displaying bundled ONNX model metadata.
class ModelInfoPage extends StatefulWidget {
  const ModelInfoPage({super.key});

  @override
  State<ModelInfoPage> createState() => _ModelInfoPageState();
}

class _ModelInfoPageState extends State<ModelInfoPage> {
  late Future<ModelInfoItem> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final useCase = AppScope.of(context).services.modelInfo;
    _future = useCase.getModelInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Model Information'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: FutureBuilder<ModelInfoItem>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load model information.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final info = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Model section
              Text(
                'Model',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                info.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version ${info.version}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'License: ${info.license}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Technical Details section
              Text(
                'Technical Details',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              _InfoTile(
                label: 'Input Dimensions',
                value: '${info.inputSize} pixels',
              ),
              _InfoTile(
                label: 'Label Count',
                value: '${info.labelCount} species',
              ),
              const SizedBox(height: 24),

              // Confidence Behavior section
              Text(
                'Confidence Behavior',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                info.confidenceDescription,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Source section
              Text(
                'Source',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              SelectableText(
                info.url,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
