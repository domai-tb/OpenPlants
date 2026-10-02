import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:openplants/core/date_utils.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('formats dates in the requested locale without hardcoded relative labels', () {
    final date = DateTime(2026, 5, 14, 23, 59);

    expect(formatDateShort(date, locale: 'de'), DateFormat.yMMMd('de').format(date));
  });

  test('formats calendar date fields consistently for local and UTC values', () {
    final localDate = DateTime(2026, 5, 14, 23, 59);
    final utcDate = DateTime.utc(2026, 5, 14, 23, 59);

    expect(formatDateShort(localDate, locale: 'en'), DateFormat.yMMMd('en').format(localDate));
    expect(formatDateShort(utcDate, locale: 'en'), DateFormat.yMMMd('en').format(utcDate));
  });
}
