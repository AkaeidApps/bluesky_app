import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats relative time matching Bluesky style ('now', '45s', '12m', '3h', '5d', 'Oct 24')
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative || difference.inSeconds < 30) {
      return 'just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (now.year == date.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  /// Formats post detail timestamp (e.g., '10:45 AM · Nov 23, 2026')
  static String formatDetail(DateTime date) {
    return DateFormat('h:mm a · MMM d, y').format(date);
  }

  /// Formats join date (e.g. 'Joined November 2026')
  static String formatJoinDate(DateTime date) {
    return 'Joined ${DateFormat('MMMM y').format(date)}';
  }
}
