import 'package:intl/intl.dart';

// This extension adds the .toIDR() method to any number
extension CurrencyFormat on num {
  String toIDR() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}
