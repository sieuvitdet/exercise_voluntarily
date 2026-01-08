import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat fullTimeFormat = DateFormat('HH:mm:ss');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat shortDateFormat = DateFormat('dd MMM');
  static final DateFormat dayFormat = DateFormat('d');

  static String formatDate(DateTime date) => dateFormat.format(date);
  static String formatTime(DateTime date) => timeFormat.format(date);
  static String formatFullTime(DateTime date) => fullTimeFormat.format(date);
  static String formatMonthYear(DateTime date) => monthYearFormat.format(date);
  static String formatShortDate(DateTime date) => shortDateFormat.format(date);
  static String formatDay(DateTime date) => dayFormat.format(date);

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return (to.difference(from).inHours / 24).round();
  }

  static List<DateTime> getLast30Days() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return startOfDay(now.subtract(Duration(days: 29 - index)));
    });
  }
}
