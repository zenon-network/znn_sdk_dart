import 'package:big_decimal/big_decimal.dart';

class AmountUtils {
  // This methods removes decimals and returns a BigInt
  static BigInt extractDecimals(String amount, int decimals) {
    if (!amount.contains('.')) {
      if (decimals == 0 && amount.isEmpty) {
        return BigInt.zero;
      }
      return BigInt.parse(amount + ''.padRight(decimals, '0'));
    }
    List<String> parts = amount.split('.');

    return BigInt.parse(parts[0] +
        (parts[1].length > decimals
            ? parts[1].substring(0, decimals)
            : parts[1].padRight(decimals, '0')));
  }

  /// Converts an unscaled [BigInt] into a decimal string representation.
  ///
  /// The [number] parameter is treated as an **unscaled integer value** with
  /// [decimals] indicating how many fractional decimal places it represents.
  ///
  /// Trailing zeros in the fractional part are removed where possible, but the
  /// numeric value remains unchanged. The result is returned as a plain
  /// (non-exponential) string.
  ///
  /// This method replicates the behavior of the former
  /// `BigDecimal.createAndStripZerosForScale` utility, which is no longer
  /// publicly available.
  ///
  /// ### Example
  /// ```dart
  /// addDecimals(BigInt.from(1234500), 3); // "1234.5"
  /// addDecimals(BigInt.from(100000), 2);  // "1000"
  /// ```
  ///
  /// ### Parameters
  /// - [number]: The unscaled integer value.
  /// - [decimals]: The number of decimal places the value represents.
  ///
  /// ### Returns
  /// A string containing the decimal representation without trailing zeros.
  static String addDecimals(BigInt number, int decimals) {
    final ten = BigInt.from(10);
    var intVal = number;
    var scale = decimals;

    while (scale > 0 && intVal.remainder(ten) == BigInt.zero) {
      intVal = intVal ~/ ten;
      scale -= 1;
    }

    return BigDecimal(intVal: intVal, scale: scale).toPlainString();
  }
}
