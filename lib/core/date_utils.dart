import 'package:intl/intl.dart';

/// Shared date formatting utilities.
String formatDateShort(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date);
}

/// Format a date as day/month/year using locale conventions.
String formatDateFull(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date);
}
