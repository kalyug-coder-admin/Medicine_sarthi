import 'package:intl/intl.dart';

class DateTimeHelper {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Format date with day name
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  // Get today's date string (YYYY-MM-DD)
  static String getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Parse date string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past
      final absDifference = difference.abs();
      if (absDifference.inDays > 365) {
        final years = (absDifference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (absDifference.inDays > 30) {
        final months = (absDifference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (absDifference.inDays > 0) {
        return '${absDifference.inDays} ${absDifference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} ${absDifference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} ${absDifference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } else {
      // Future
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else if (difference.inDays > 0) {
        return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
      } else if (difference.inHours > 0) {
        return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
      } else if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'Now';
      }
    }
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Check if time is between two times
  static bool isTimeBetween(
      DateTime time,
      DateTime start,
      DateTime end,
      ) {
    return time.isAfter(start) && time.isBefore(end);
  }

  // Get readable appointment time
  static String getAppointmentTimeDisplay(DateTime appointmentDate) {
    if (isToday(appointmentDate)) {
      return 'Today at ${formatTime(appointmentDate)}';
    } else if (isTomorrow(appointmentDate)) {
      return 'Tomorrow at ${formatTime(appointmentDate)}';
    } else {
      return formatDateTime(appointmentDate);
    }
  }
}