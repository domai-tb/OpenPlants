import 'package:flutter/material.dart';

import 'package:open_plants/pages/plant_metrics/metric_definition.dart';
import 'package:open_plants/pages/plant_metrics/metric_measurement.dart';
import 'package:open_plants/pages/plant_metrics/metric_usecases.dart';

/// Metric history page showing measurements and graph.
class MetricHistoryPage extends StatefulWidget {
  final MetricDefinition definition;
  final MetricUsecases usecases;

  const MetricHistoryPage({
    super.key,
    required this.definition,
    required this.usecases,
  });

  @override
  State<MetricHistoryPage> createState() => _MetricHistoryPageState();
}

class _MetricHistoryPageState extends State<MetricHistoryPage> {
  List<MetricMeasurement> _measurements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final measurements = await widget.usecases.getMeasurementsForMetric(
      widget.definition.id,
    );
    setState(() {
      _measurements = measurements;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.definition.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showRecordMeasurementSheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _measurements.isEmpty
              ? _buildEmptyState()
              : _buildHistoryView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No measurements yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showRecordMeasurementSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Record First Measurement'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        if (widget.definition.valueType == MetricValueType.numeric)
          SizedBox(
            height: 200,
            child: _NumericGraph(
              measurements: _measurements,
              bounds: widget.definition.numericBounds,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _measurements.length,
            itemBuilder: (context, index) {
              final measurement = _measurements[_measurements.length - 1 - index];
              return _MeasurementTile(
                measurement: measurement,
                definition: widget.definition,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRecordMeasurementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RecordMeasurementSheet(
        definition: widget.definition,
        usecases: widget.usecases,
        onSaved: _loadData,
      ),
    );
  }
}

/// Simple numeric graph using CustomPaint.
class _NumericGraph extends StatelessWidget {
  final List<MetricMeasurement> measurements;
  final NumericBounds? bounds;

  const _NumericGraph({
    required this.measurements,
    this.bounds,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        size: Size.infinite,
        painter: _NumericGraphPainter(
          measurements: measurements,
          bounds: bounds,
        ),
      ),
    );
  }
}

class _NumericGraphPainter extends CustomPainter {
  final List<MetricMeasurement> measurements;
  final NumericBounds? bounds;

  _NumericGraphPainter({
    required this.measurements,
    this.bounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.isEmpty) return;

    final values = measurements.map((m) => (m.value as num).toDouble()).toList();
    final minY = bounds?.lower ?? (values.reduce((a, b) => a < b ? a : b) - 5);
    final maxY = bounds?.upper ?? (values.reduce((a, b) => a > b ? a : b) + 5);
    final range = maxY - minY;
    if (range == 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minY) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw bounds as dashed lines
    if (bounds?.lower != null) {
      final lowerY = size.height - ((bounds!.lower! - minY) / range) * size.height;
      _drawDashedLine(canvas, lowerY, size.width, Colors.orange);
    }
    if (bounds?.upper != null) {
      final upperY = size.height - ((bounds!.upper! - minY) / range) * size.height;
      _drawDashedLine(canvas, upperY, size.width, Colors.orange);
    }
  }

  void _drawDashedLine(Canvas canvas, double y, double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var x = 0.0;
    while (x < width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dashWidth, y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _NumericGraphPainter oldDelegate) {
    return measurements != oldDelegate.measurements || bounds != oldDelegate.bounds;
  }
}

class _MeasurementTile extends StatelessWidget {
  final MetricMeasurement measurement;
  final MetricDefinition definition;

  const _MeasurementTile({
    required this.measurement,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_formatValue()),
      subtitle: Text(_formatDate(measurement.measuredAt)),
      trailing: measurement.notes != null ? const Icon(Icons.note, size: 16) : null,
    );
  }

  String _formatValue() {
    switch (definition.valueType) {
      case MetricValueType.numeric:
        final val = (measurement.value as num).toDouble();
        return '${val.toStringAsFixed(1)}${definition.unit ?? ''}';
      case MetricValueType.boolean:
        return measurement.value == true ? 'Yes' : 'No';
      case MetricValueType.categorical:
        return measurement.value.toString();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _RecordMeasurementSheet extends StatefulWidget {
  final MetricDefinition definition;
  final MetricUsecases usecases;
  final VoidCallback onSaved;

  const _RecordMeasurementSheet({
    required this.definition,
    required this.usecases,
    required this.onSaved,
  });

  @override
  State<_RecordMeasurementSheet> createState() => _RecordMeasurementSheetState();
}

class _RecordMeasurementSheetState extends State<_RecordMeasurementSheet> {
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record ${widget.definition.name}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _buildValueInput(),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildValueInput() {
    switch (widget.definition.valueType) {
      case MetricValueType.numeric:
        return TextField(
          controller: _valueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Value',
            hintText:
                widget.definition.unit != null ? 'Enter value in ${widget.definition.unit}' : 'Enter numeric value',
          ),
        );
      case MetricValueType.boolean:
        return Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Yes'),
                leading: Radio<bool>(
                  value: true,
                  groupValue: _valueController.text == 'true' ? true : null,
                  onChanged: (v) => setState(() => _valueController.text = 'true'),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('No'),
                leading: Radio<bool>(
                  value: false,
                  groupValue: _valueController.text == 'false' ? false : null,
                  onChanged: (v) => setState(() => _valueController.text = 'false'),
                ),
              ),
            ),
          ],
        );
      case MetricValueType.categorical:
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Value'),
          items: widget.definition.categoryOptions.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
        );
    }
  }

  Future<void> _save() async {
    dynamic value;
    switch (widget.definition.valueType) {
      case MetricValueType.numeric:
        final parsed = double.tryParse(_valueController.text);
        if (parsed == null) return;
        value = parsed;
      case MetricValueType.boolean:
        value = _valueController.text == 'true';
      case MetricValueType.categorical:
        if (_selectedCategory == null) return;
        value = _selectedCategory;
    }

    await widget.usecases.recordMeasurement(
      metricId: widget.definition.id,
      plantId: widget.definition.plantId,
      value: value,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
