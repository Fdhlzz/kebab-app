import 'package:intl/intl.dart';

// This extension allows you to call .toIDR() on any number (int or double)
extension CurrencyFormat on num {
  String toIDR() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}
