import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/light_assessment/light_assessment_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  late LightAssessmentDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = LightAssessmentDataSource(
      plantDataSource: PlantCollectionDataSource(prefs: prefs),
    );
  });

  test('setting a light level for a deleted plant reports failure', () async {
    await expectLater(
      dataSource.saveLightLevel('missing-plant', LightLevel.medium),
      throwsA(isA<StateError>()),
    );
  });

  test('clearing a light level for a deleted plant reports failure', () async {
    await expectLater(
      dataSource.clearLightLevel('missing-plant'),
      throwsA(isA<StateError>()),
    );
  });
}
