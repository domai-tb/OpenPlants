import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/symptom_logger/symptom_logger_datasource.dart';

void main() {
  test('saveDraft reports when SharedPreferences rejects the write', () async {
    final dataSource = SymptomLoggerDataSource(prefs: _FalseWritePreferences());

    await expectLater(
      dataSource.saveDraft('plant-1', {'note': 'progress'}),
      throwsA(isA<StateError>().having((error) => error.message, 'message', contains('symptom_draft_v1'))),
    );
  });
}

class _FalseWritePreferences implements SharedPreferences {
  @override
  String? getString(String key) => null;

  @override
  Future<bool> setString(String key, String value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
