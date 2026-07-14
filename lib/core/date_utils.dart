import 'package:intl/intl.dart';

/// Shared date formatting utilities.
String formatDateShort(DateTime date, {String? locale}) {
  final now = DateTime.now();
  final diff = now.difference(date).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';

  return DateFormat.yMMMd(locale).format(date);
}

/// Format a date as day/month/year using locale conventions.
String formatDateFull(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date);
}
