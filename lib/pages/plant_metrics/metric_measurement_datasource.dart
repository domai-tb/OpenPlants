import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/local_collection_codec.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';

/// Persistence layer for metric measurements.
///
/// Uses versioned SharedPreferences collection with corruption-safe codec.
class MetricMeasurementDataSource {
  static const String _prefsKey = 'metric_measurements_v1';
  LocalCollectionCodec<MetricMeasurement>? _codec;
  SharedPreferences? _prefs;

  MetricMeasurementDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  Future<LocalCollectionCodec<MetricMeasurement>> _getCodec() async {
    if (_codec != null) return _codec!;
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _codec = LocalCollectionCodec<MetricMeasurement>(
      prefs: prefs,
      key: _prefsKey,
      fromJson: MetricMeasurement.fromJson,
      toJson: (e) => e.toJson(),
      keyExtractor: (e) => e.id,
    );
    return _codec!;
  }

  Future<List<MetricMeasurement>> loadMeasurements() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) throw result.asFailure!;
    return result.asSuccess;
  }

  Future<void> saveMeasurements(List<MetricMeasurement> measurements) async {
    final codec = await _getCodec();
    await codec.save(measurements);
  }

  Future<void> addMeasurement(MetricMeasurement measurement) async {
    final codec = await _getCodec();
    await codec.add(measurement);
  }

  Future<void> updateMeasurement(MetricMeasurement measurement) async {
    final codec = await _getCodec();
    await codec.update(measurement, matchKey: (e) => e.id);
  }

  Future<void> deleteMeasurement(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  Future<void> deleteMeasurementsForMetric(String metricId) async {
    final all = await loadMeasurements();
    final filtered = all.where((m) => m.metricId != metricId).toList();
    await saveMeasurements(filtered);
  }

  Future<void> deleteMeasurementsForPlant(String plantId) async {
    final all = await loadMeasurements();
    final filtered = all.where((m) => m.plantId != plantId).toList();
    await saveMeasurements(filtered);
  }
}
