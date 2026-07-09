/// Shared date formatting utilities.
String formatDateShort(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';

  return '${date.day}/${date.month}/${date.year}';
}

/// Format a date as day/month/year.
String formatDateFull(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
