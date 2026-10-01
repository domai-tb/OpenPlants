import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/core/settings.dart';

void main() {
  test('system text scaling is enabled by default', () {
    expect(const Settings().useSystemTextScaling, isTrue);
    expect(Settings.fromJson({}).useSystemTextScaling, isTrue);
    expect(Settings.fromJson({'useSystemTextScaling': false}).useSystemTextScaling, isFalse);
  });
}
