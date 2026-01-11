import 'package:intl/intl.dart';

class DateFormatter {
  static String friendly(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
