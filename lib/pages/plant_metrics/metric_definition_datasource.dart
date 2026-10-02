import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/local_collection_codec.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';

/// Persistence layer for metric definitions.
///
/// Uses versioned SharedPreferences collection with corruption-safe codec.
class MetricDefinitionDataSource {
  static const String _prefsKey = 'metric_definitions_v1';
  LocalCollectionCodec<MetricDefinition>? _codec;
  SharedPreferences? _prefs;

  MetricDefinitionDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  Future<LocalCollectionCodec<MetricDefinition>> _getCodec() async {
    if (_codec != null) return _codec!;
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _codec = LocalCollectionCodec<MetricDefinition>(
      prefs: prefs,
      key: _prefsKey,
      fromJson: MetricDefinition.fromJson,
      toJson: (e) => e.toJson(),
      keyExtractor: (e) => e.id,
    );
    return _codec!;
  }

  Future<List<MetricDefinition>> loadDefinitions() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) throw result.asFailure!;
    return result.asSuccess;
  }

  Future<void> saveDefinitions(List<MetricDefinition> definitions) async {
    final codec = await _getCodec();
    await codec.save(definitions);
  }

  Future<void> addDefinition(MetricDefinition definition) async {
    final codec = await _getCodec();
    await codec.add(definition);
  }

  Future<void> updateDefinition(MetricDefinition definition) async {
    final codec = await _getCodec();
    await codec.update(definition, matchKey: (e) => e.id);
  }

  Future<void> deleteDefinition(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  Future<void> deleteDefinitionsForPlant(String plantId) async {
    final all = await loadDefinitions();
    final filtered = all.where((d) => d.plantId != plantId).toList();
    await saveDefinitions(filtered);
  }
}
