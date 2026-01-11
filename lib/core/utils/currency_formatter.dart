import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(num value, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(name: currency, symbol: '');
    return '${formatter.format(value)} $currency';
  }
}
