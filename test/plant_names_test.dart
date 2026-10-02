import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/locale_service.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/pages/plant_names/plant_names_datasource.dart';
import 'package:openplants/pages/plant_names/plant_names_repository.dart';
import 'package:openplants/pages/plant_names/plant_names_usecases.dart';

void main() {
  test('resolves localized names and falls back to scientific name', () async {
    final usecases = PlantNamesUsecases(
      repository: PlantNamesRepository(
        datasource: PlantNamesDatasource(
          bundle: _TestAssetBundle(
            content:
                '{"monstera_deliciosa":{"en":"Swiss Cheese Plant","de":"Monstera"},"rare_species_2024":{"en":"Rare Plant"}}',
          ),
        ),
      ),
    );

    expect(await usecases.getDisplayName('monstera_deliciosa', localeCode: 'de_DE'), 'Monstera');
    expect(await usecases.getDisplayName('monstera_deliciosa', localeCode: 'en'), 'Swiss Cheese Plant');
    expect(
      await usecases.getDisplayName(
        'rare_species_2024',
        localeCode: 'de',
        scientificName: 'Rare Species 2024',
      ),
      'Rare Species 2024',
    );
  });

  test('uses the active app locale when no locale is provided', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await SettingsController.load();
    await settings.update(const Settings(localeCode: 'de'));
    final localeService = LocaleService(settings);
    addTearDown(localeService.dispose);
    final usecases = PlantNamesUsecases(
      repository: PlantNamesRepository(
        datasource: PlantNamesDatasource(
          bundle: _TestAssetBundle(
            content: '{"monstera_deliciosa":{"en":"Swiss Cheese Plant","de":"Monstera"}}',
          ),
        ),
      ),
      localeService: localeService,
    );

    expect(await usecases.getDisplayName('monstera_deliciosa'), 'Monstera');
  });

  test('missing or malformed asset falls back without throwing', () async {
    for (final bundle in [
      _TestAssetBundle(error: StateError('asset missing')),
      _TestAssetBundle(content: '{not valid json'),
    ]) {
      final usecases = PlantNamesUsecases(
        repository: PlantNamesRepository(
          datasource: PlantNamesDatasource(bundle: bundle),
        ),
      );

      expect(
        await usecases.getDisplayName(
          'monstera_deliciosa',
          localeCode: 'de',
          scientificName: 'Monstera deliciosa',
        ),
        'Monstera deliciosa',
      );
    }
  });
}

class _TestAssetBundle extends AssetBundle {
  final String? _content;
  final Error? _error;

  _TestAssetBundle({String? content, Error? error})
      : _content = content,
        _error = error;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final error = _error;
    if (error != null) throw error;
    final content = _content;
    if (content != null) return content;
    throw StateError('No test asset content');
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
