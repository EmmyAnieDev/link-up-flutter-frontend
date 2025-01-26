import 'package:intl/intl.dart';

String formatTimestamp(DateTime timestamp) {
  final localTime = timestamp.toLocal(); // Convert timestamp to local time
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDay = DateTime(localTime.year, localTime.month, localTime.day);

  if (messageDay == today) {
    // Message is from today, show time in HH:mm format
    return DateFormat.Hm().format(localTime); // e.g., 08:55
  } else if (messageDay == yesterday) {
    // Message is from yesterday
    return 'Yesterday';
  } else {
    // Message is older, show as day/month/year
    return DateFormat('d/M/yy').format(localTime); // e.g., 1/22/25
  }
}
