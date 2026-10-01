import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:openplants/pages/care_schedule/schedule_config.dart';

void main() {
  test('care schedule reports when SharedPreferences rejects a config write', () async {
    final dataSource = CareScheduleDataSource(prefs: _RejectingPreferences());

    await expectLater(
      dataSource.saveScheduleConfig('plant-1', const ScheduleConfig()),
      throwsA(isA<StateError>()),
    );
  });
}

class _RejectingPreferences implements SharedPreferences {
  @override
  String? getString(String key) => null;

  @override
  Future<bool> setString(String key, String value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
