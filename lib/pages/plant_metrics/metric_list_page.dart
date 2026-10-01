import 'package:flutter/material.dart';

import 'package:openplants/l10n/l10n_x.dart';
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
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }
    try {
      final definitions = await widget.usecases.getDefinitionsForPlant(widget.plantId);
      final evaluations = await widget.usecases.evaluateAllForPlant(widget.plantId);
      if (!mounted) return;
      setState(() {
        _definitions = definitions;
        _evaluations = evaluations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plantName} ${context.l10n.metricsTitle}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
              ? _buildLoadError(context)
              : _definitions.isEmpty
                  ? _buildEmptyState()
                  : _buildMetricList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDefinitionSheet(context),
        tooltip: context.l10n.metricsAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.generalFailureMessage),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
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
            context.l10n.metricsEmpty,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.metricsEmptyDescription,
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
            onEdit: () => _showDefinitionSheet(context, definition: def),
            onToggleEnabled: () => _toggleDefinition(def),
            onDelete: () => _confirmDelete(def),
          );
        },
      ),
    );
  }

  Future<void> _showDefinitionSheet(BuildContext context, {MetricDefinition? definition}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMetricDefinitionSheet(
        plantId: widget.plantId,
        usecases: widget.usecases,
        definition: definition,
        onSaved: _loadData,
      ),
    );
  }

  Future<void> _toggleDefinition(MetricDefinition definition) async {
    try {
      await widget.usecases.toggleDefinition(definition.id);
      await _loadData();
    } catch (_) {
      if (mounted) _showActionFailure();
    }
  }

  Future<void> _confirmDelete(MetricDefinition definition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.metricsDeleteTitle(definition.name)),
        content: Text(context.l10n.metricsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await widget.usecases.deleteDefinition(definition.id);
      await _loadData();
    } catch (_) {
      if (mounted) _showActionFailure();
    }
  }

  void _showActionFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generalFailureMessage)),
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

enum _MetricAction { edit, toggleEnabled, delete }

class _MetricTile extends StatelessWidget {
  final MetricDefinition definition;
  final MetricEvaluation? evaluation;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleEnabled;
  final VoidCallback onDelete;

  const _MetricTile({
    required this.definition,
    this.evaluation,
    required this.onTap,
    required this.onEdit,
    required this.onToggleEnabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAlert = evaluation?.state == MetricState.alert;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(definition.name),
        subtitle: _buildSubtitle(context),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAlert) const Icon(Icons.warning, color: Colors.orange),
            PopupMenuButton<_MetricAction>(
              tooltip: context.l10n.metricsActions,
              onSelected: (action) {
                switch (action) {
                  case _MetricAction.edit:
                    onEdit();
                  case _MetricAction.toggleEnabled:
                    onToggleEnabled();
                  case _MetricAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: _MetricAction.edit, child: Text(context.l10n.metricsEdit)),
                PopupMenuItem(
                  value: _MetricAction.toggleEnabled,
                  child: Text(definition.isEnabled ? context.l10n.metricsDisable : context.l10n.metricsEnable),
                ),
                PopupMenuItem(value: _MetricAction.delete, child: Text(context.l10n.metricsDelete)),
              ],
            ),
          ],
        ),
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

  Widget? _buildSubtitle(BuildContext context) {
    if (evaluation == null) return Text(context.l10n.metricsNoData);
    if (evaluation!.state == MetricState.noData) return Text(context.l10n.metricsNoData);

    final last = evaluation!.lastMeasurement;
    if (last == null) return Text(context.l10n.metricsNoData);
    if (last.validate(definition) != null) return Text(context.l10n.metricsInvalidMeasurement);

    String valueStr;
    switch (definition.valueType) {
      case MetricValueType.numeric:
        final val = (last.value as num).toDouble();
        valueStr = '${val.toStringAsFixed(1)}${definition.unit ?? ''}';
      case MetricValueType.boolean:
        valueStr = last.value == true ? context.l10n.metricsYes : context.l10n.metricsNo;
      case MetricValueType.categorical:
        valueStr = last.value.toString();
    }

    return Text(valueStr);
  }
}

class _AddMetricDefinitionSheet extends StatefulWidget {
  final String plantId;
  final MetricUsecases usecases;
  final MetricDefinition? definition;
  final Future<void> Function() onSaved;

  const _AddMetricDefinitionSheet({
    required this.plantId,
    required this.usecases,
    this.definition,
    required this.onSaved,
  });

  @override
  State<_AddMetricDefinitionSheet> createState() => _AddMetricDefinitionSheetState();
}

class _AddMetricDefinitionSheetState extends State<_AddMetricDefinitionSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _unitController;
  late final TextEditingController _lowerController;
  late final TextEditingController _upperController;
  late final TextEditingController _categoryController;
  late final Set<String> _alertValues;
  String? _nameError;
  String? _unitError;
  String? _lowerError;
  String? _upperError;
  String? _categoryError;
  late MetricValueType _valueType;
  late AlertResponse _alertResponse;

  @override
  void initState() {
    super.initState();
    final definition = widget.definition;
    _nameController = TextEditingController(text: definition?.name ?? '');
    _unitController = TextEditingController(text: definition?.unit ?? '');
    _lowerController = TextEditingController(text: definition?.numericBounds?.lower?.toString() ?? '');
    _upperController = TextEditingController(text: definition?.numericBounds?.upper?.toString() ?? '');
    _categoryController = TextEditingController(text: definition?.categoryOptions.join(', ') ?? '');
    _alertValues = {...?definition?.alertValues};
    _valueType = definition?.valueType ?? MetricValueType.numeric;
    _alertResponse = definition?.alertResponse ?? AlertResponse.warning;
  }

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
            Text(
              widget.definition == null ? context.l10n.metricsAdd : context.l10n.metricsEdit,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.metricsName,
                hintText: context.l10n.metricsNameHint,
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: context.l10n.metricsUnit,
                hintText: context.l10n.metricsUnitHint,
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
              decoration: InputDecoration(labelText: context.l10n.metricsValueType),
              items: MetricValueType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(_valueTypeLabel(context, t)));
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
                decoration: InputDecoration(
                  labelText: context.l10n.metricsMinimumAlert,
                  errorText: _lowerError,
                ),
                onChanged: (_) => setState(() => _lowerError = null),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _upperController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: context.l10n.metricsMaximumAlert,
                  errorText: _upperError,
                ),
                onChanged: (_) => setState(() => _upperError = null),
              ),
            ] else if (_valueType == MetricValueType.categorical) ...[
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: context.l10n.metricsOptions,
                  hintText: context.l10n.metricsOptionsHint,
                  errorText: _categoryError,
                ),
                onChanged: (_) {
                  final options = _categoryOptions.toSet();
                  setState(() {
                    _categoryError = null;
                    _alertValues.removeWhere((value) => !options.contains(value));
                  });
                },
              ),
              ..._categoryOptions.map(
                (option) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.metricsAlertOn(option)),
                  value: _alertValues.contains(option),
                  onChanged: (selected) => _setAlertValue(option, selected),
                ),
              ),
            ] else ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.metricsAlertWhenYes),
                value: _alertValues.contains('true'),
                onChanged: (selected) => _setAlertValue('true', selected),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.metricsAlertWhenNo),
                value: _alertValues.contains('false'),
                onChanged: (selected) => _setAlertValue('false', selected),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<AlertResponse>(
              initialValue: _alertResponse,
              decoration: InputDecoration(labelText: context.l10n.metricsAlertResponse),
              items: AlertResponse.values
                  .map(
                    (response) => DropdownMenuItem(
                      value: response,
                      child: Text(_alertResponseLabel(context, response)),
                    ),
                  )
                  .toList(),
              onChanged: (response) {
                if (response != null) setState(() => _alertResponse = response);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text(context.l10n.metricsSave),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<String> get _categoryOptions =>
      _categoryController.text.split(',').map((option) => option.trim()).where((option) => option.isNotEmpty).toList();

  String _valueTypeLabel(BuildContext context, MetricValueType valueType) {
    switch (valueType) {
      case MetricValueType.numeric:
        return context.l10n.metricsValueTypeNumeric;
      case MetricValueType.boolean:
        return context.l10n.metricsValueTypeBoolean;
      case MetricValueType.categorical:
        return context.l10n.metricsValueTypeCategorical;
    }
  }

  String _alertResponseLabel(BuildContext context, AlertResponse response) {
    return switch (response) {
      AlertResponse.warning => context.l10n.metricsAlertResponseWarning,
      AlertResponse.careTask => context.l10n.metricsAlertResponseCareTask,
    };
  }

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
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final categoryOptions = _categoryOptions;
    final hasDuplicateCategory =
        categoryOptions.map((option) => option.toLowerCase()).toSet().length != categoryOptions.length;
    setState(() {
      _nameError = name.isEmpty ? context.l10n.metricsNameRequired : null;
      _unitError = unit.isEmpty ? context.l10n.metricsUnitRequired : null;
      _categoryError = _valueType == MetricValueType.categorical
          ? categoryOptions.isEmpty
              ? context.l10n.metricsCategoryOptionsRequired
              : hasDuplicateCategory
                  ? context.l10n.metricsCategoryOptionsUnique
                  : null
          : null;
    });
    if (_nameError != null || _unitError != null || _categoryError != null) {
      return;
    }

    final lowerText = _valueType == MetricValueType.numeric ? _lowerController.text.trim() : '';
    final upperText = _valueType == MetricValueType.numeric ? _upperController.text.trim() : '';
    final lower = lowerText.isEmpty ? null : double.tryParse(lowerText);
    final upper = upperText.isEmpty ? null : double.tryParse(upperText);
    final lowerInvalid = lowerText.isNotEmpty && (lower == null || !lower.isFinite);
    final upperInvalid = upperText.isNotEmpty && (upper == null || !upper.isFinite);
    final boundsInvalid = lower != null && upper != null && lower > upper;
    setState(() {
      _lowerError = lowerInvalid
          ? context.l10n.metricsMinimumMustBeFinite
          : boundsInvalid
              ? context.l10n.metricsMinimumCannotExceedMaximum
              : null;
      _upperError = upperInvalid ? context.l10n.metricsMaximumMustBeFinite : null;
    });
    if (_lowerError != null || _upperError != null) {
      return;
    }

    final numericBounds = _valueType == MetricValueType.numeric && (lower != null || upper != null)
        ? NumericBounds(lower: lower, upper: upper)
        : null;

    try {
      final definition = widget.definition;
      if (definition == null) {
        await widget.usecases.createDefinition(
          plantId: widget.plantId,
          name: name,
          valueType: _valueType,
          unit: unit,
          categoryOptions: _valueType == MetricValueType.categorical ? categoryOptions : const [],
          numericBounds: numericBounds,
          alertValues: _valueType == MetricValueType.numeric ? null : Set.of(_alertValues),
          alertResponse: _alertResponse,
        );
      } else {
        await widget.usecases.updateDefinition(
          definition.copyWith(
            name: name,
            valueType: _valueType,
            unit: unit,
            categoryOptions: _valueType == MetricValueType.categorical ? categoryOptions : const [],
            numericBounds: numericBounds,
            clearNumericBounds: numericBounds == null,
            alertValues: _valueType == MetricValueType.numeric ? null : Set.of(_alertValues),
            clearAlertValues: _valueType == MetricValueType.numeric,
            alertResponse: _alertResponse,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.generalFailureMessage)));
      }
      return;
    }

    await widget.onSaved();
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
