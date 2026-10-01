import 'package:flutter/material.dart';

import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_evaluator.dart';
import 'package:openplants/pages/plant_metrics/metric_history_page.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

/// Plant-scoped metric list page.
///
/// Shows all metric definitions for a plant with latest values and alert status.
class MetricListPage extends StatefulWidget {
  final String plantId;
  final String plantName;
  final MetricUsecases usecases;

  const MetricListPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.usecases,
  });

  @override
  State<MetricListPage> createState() => _MetricListPageState();
}

class _MetricListPageState extends State<MetricListPage> {
  List<MetricDefinition> _definitions = [];
  Map<String, MetricEvaluation> _evaluations = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final definitions = await widget.usecases.getDefinitionsForPlant(widget.plantId);
    final evaluations = await widget.usecases.evaluateAllForPlant(widget.plantId);
    setState(() {
      _definitions = definitions;
      _evaluations = evaluations;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plantName} Metrics'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _definitions.isEmpty
              ? _buildEmptyState()
              : _buildMetricList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDefinitionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No metrics yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a metric to track things like soil moisture, temperature, or leaf health.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _definitions.length,
        itemBuilder: (context, index) {
          final def = _definitions[index];
          final evaluation = _evaluations[def.id];
          return _MetricTile(
            definition: def,
            evaluation: evaluation,
            onTap: () => _navigateToMetricDetail(def),
          );
        },
      ),
    );
  }

  void _showAddDefinitionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMetricDefinitionSheet(
        plantId: widget.plantId,
        usecases: widget.usecases,
        onSaved: _loadData,
      ),
    );
  }

  void _navigateToMetricDetail(MetricDefinition definition) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MetricHistoryPage(
          definition: definition,
          usecases: widget.usecases,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final MetricDefinition definition;
  final MetricEvaluation? evaluation;
  final VoidCallback onTap;

  const _MetricTile({
    required this.definition,
    this.evaluation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAlert = evaluation?.state == MetricState.alert;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(definition.name),
        subtitle: _buildSubtitle(),
        trailing: hasAlert ? const Icon(Icons.warning, color: Colors.orange) : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildIcon() {
    switch (definition.valueType) {
      case MetricValueType.numeric:
        return const Icon(Icons.speed);
      case MetricValueType.boolean:
        return const Icon(Icons.check_circle_outline);
      case MetricValueType.categorical:
        return const Icon(Icons.category);
    }
  }

  Widget? _buildSubtitle() {
    if (evaluation == null) return const Text('No data');
    if (evaluation!.state == MetricState.noData) return const Text('No data');

    final last = evaluation!.lastMeasurement;
    if (last == null) return const Text('No data');

    String valueStr;
    switch (definition.valueType) {
      case MetricValueType.numeric:
        final val = (last.value as num).toDouble();
        valueStr = '${val.toStringAsFixed(1)}${definition.unit ?? ''}';
      case MetricValueType.boolean:
        valueStr = last.value == true ? 'Yes' : 'No';
      case MetricValueType.categorical:
        valueStr = last.value.toString();
    }

    return Text(valueStr);
  }
}

class _AddMetricDefinitionSheet extends StatefulWidget {
  final String plantId;
  final MetricUsecases usecases;
  final VoidCallback onSaved;

  const _AddMetricDefinitionSheet({
    required this.plantId,
    required this.usecases,
    required this.onSaved,
  });

  @override
  State<_AddMetricDefinitionSheet> createState() => _AddMetricDefinitionSheetState();
}

class _AddMetricDefinitionSheetState extends State<_AddMetricDefinitionSheet> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _lowerController = TextEditingController();
  final _upperController = TextEditingController();
  final _categoryController = TextEditingController();
  final Set<String> _alertValues = {};
  String? _unitError;
  MetricValueType _valueType = MetricValueType.numeric;
  AlertResponse _alertResponse = AlertResponse.warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Metric', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Soil Moisture',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'Unit',
                hintText: 'e.g., %, °C',
                errorText: _unitError,
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty && _unitError != null) {
                  setState(() => _unitError = null);
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MetricValueType>(
              initialValue: _valueType,
              decoration: const InputDecoration(labelText: 'Value Type'),
              items: MetricValueType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.name));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _valueType = v);
              },
            ),
            const SizedBox(height: 8),
            if (_valueType == MetricValueType.numeric) ...[
              TextField(
                controller: _lowerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Minimum alert value (optional)'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _upperController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'Maximum alert value (optional)'),
                onChanged: (_) => setState(() {}),
              ),
            ] else if (_valueType == MetricValueType.categorical) ...[
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Options',
                  hintText: 'Comma-separated, e.g., Good, Fair, Poor',
                ),
                onChanged: (_) {
                  final options = _categoryOptions.toSet();
                  setState(() => _alertValues.removeWhere((value) => !options.contains(value)));
                },
              ),
              ..._categoryOptions.map(
                (option) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Alert on $option'),
                  value: _alertValues.contains(option),
                  onChanged: (selected) => _setAlertValue(option, selected),
                ),
              ),
            ] else ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alert when Yes'),
                value: _alertValues.contains('true'),
                onChanged: (selected) => _setAlertValue('true', selected),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alert when No'),
                value: _alertValues.contains('false'),
                onChanged: (selected) => _setAlertValue('false', selected),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<AlertResponse>(
              initialValue: _alertResponse,
              decoration: const InputDecoration(labelText: 'Alert response'),
              items: AlertResponse.values
                  .map((response) => DropdownMenuItem(value: response, child: Text(response.name)))
                  .toList(),
              onChanged: (response) {
                if (response != null) setState(() => _alertResponse = response);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<String> get _categoryOptions =>
      _categoryController.text.split(',').map((option) => option.trim()).where((option) => option.isNotEmpty).toList();

  void _setAlertValue(String value, bool? selected) {
    setState(() {
      if (selected == true) {
        _alertValues.add(value);
      } else {
        _alertValues.remove(value);
      }
    });
  }

  Future<void> _save() async {
    if (_unitController.text.trim().isEmpty) {
      setState(() => _unitError = 'Unit is required');
      return;
    }

    final lowerText = _lowerController.text.trim();
    final upperText = _upperController.text.trim();
    final lower = lowerText.isEmpty ? null : double.tryParse(lowerText);
    final upper = upperText.isEmpty ? null : double.tryParse(upperText);
    if ((lowerText.isNotEmpty && lower == null) || (upperText.isNotEmpty && upper == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert thresholds must be numbers')));
      return;
    }

    try {
      await widget.usecases.createDefinition(
        plantId: widget.plantId,
        name: _nameController.text,
        valueType: _valueType,
        unit: _unitController.text.trim(),
        categoryOptions: _valueType == MetricValueType.categorical ? _categoryOptions : const [],
        numericBounds: lower != null || upper != null ? NumericBounds(lower: lower, upper: upper) : null,
        alertValues: _valueType == MetricValueType.numeric ? null : Set.of(_alertValues),
        alertResponse: _alertResponse,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }

    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _lowerController.dispose();
    _upperController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
