import 'package:intl/intl.dart';

String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays == 0) {
    // Same day, show time in HH:mm format
    return DateFormat.Hm().format(timestamp); // e.g., 08:55
  } else if (difference.inDays == 1) {
    // Yesterday
    return 'Yesterday';
  } else {
    // Older dates, show as day/month/year (short year format)
    return DateFormat('d/M/yy').format(timestamp); // e.g., 1/22/25
  }
}
