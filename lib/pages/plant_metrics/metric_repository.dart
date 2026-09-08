import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';

/// Repository for metric definitions and measurements.
///
/// Manages per-plant queries, CRUD operations, and data integrity.
class MetricRepository {
  final MetricDefinitionDataSource definitionDataSource;
  final MetricMeasurementDataSource measurementDataSource;

  const MetricRepository({
    required this.definitionDataSource,
    required this.measurementDataSource,
  });

  // --- Definitions ---

  Future<List<MetricDefinition>> loadDefinitions() => definitionDataSource.loadDefinitions();

  Future<List<MetricDefinition>> getDefinitionsForPlant(String plantId) async {
    final all = await definitionDataSource.loadDefinitions();
    return all.where((d) => d.plantId == plantId).toList();
  }

  Future<MetricDefinition?> getDefinitionById(String id) async {
    final all = await definitionDataSource.loadDefinitions();
    return all.where((d) => d.id == id).firstOrNull;
  }

  Future<void> saveDefinition(MetricDefinition definition) async {
    final all = await definitionDataSource.loadDefinitions();
    final index = all.indexWhere((d) => d.id == definition.id);
    if (index >= 0) {
      all[index] = definition;
    } else {
      all.add(definition);
    }
    await definitionDataSource.saveDefinitions(all);
  }

  Future<void> deleteDefinition(String id) async {
    final all = await definitionDataSource.loadDefinitions();
    all.removeWhere((d) => d.id == id);
    await definitionDataSource.saveDefinitions(all);
    // Cascade: delete measurements for this metric
    await measurementDataSource.deleteMeasurementsForMetric(id);
  }

  Future<void> deleteDefinitionsForPlant(String plantId) async {
    final all = await definitionDataSource.loadDefinitions();
    all.removeWhere((d) => d.plantId == plantId);
    await definitionDataSource.saveDefinitions(all);
    // Cascade: delete measurements for this plant
    await measurementDataSource.deleteMeasurementsForPlant(plantId);
  }

  // --- Measurements ---

  Future<List<MetricMeasurement>> loadMeasurements() => measurementDataSource.loadMeasurements();

  Future<List<MetricMeasurement>> getMeasurementsForMetric(String metricId) async {
    final all = await measurementDataSource.loadMeasurements();
    return all.where((m) => m.metricId == metricId).toList()..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  Future<List<MetricMeasurement>> getMeasurementsForPlant(String plantId) async {
    final all = await measurementDataSource.loadMeasurements();
    return all.where((m) => m.plantId == plantId).toList()..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  Future<List<MetricMeasurement>> getMeasurementsForMetricPaged(
    String metricId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final all = await getMeasurementsForMetric(metricId);
    if (offset >= all.length) return [];
    final end = (offset + limit).clamp(0, all.length);
    return all.sublist(offset, end);
  }

  Future<MetricMeasurement?> getLatestMeasurement(String metricId) async {
    final measurements = await getMeasurementsForMetric(metricId);
    return measurements.isNotEmpty ? measurements.last : null;
  }

  Future<void> saveMeasurement(MetricMeasurement measurement) async {
    final all = await measurementDataSource.loadMeasurements();
    final index = all.indexWhere((m) => m.id == measurement.id);
    if (index >= 0) {
      all[index] = measurement;
    } else {
      all.add(measurement);
    }
    await measurementDataSource.saveMeasurements(all);
  }

  Future<void> deleteMeasurement(String id) async {
    final all = await measurementDataSource.loadMeasurements();
    all.removeWhere((m) => m.id == id);
    await measurementDataSource.saveMeasurements(all);
  }
}
