import 'dart:math' show pow;

class AmountUtils {
  static int extractDecimals(double num, int decimals) =>
      (num * pow(10, decimals)).toInt();

  static num addDecimals(int num, int decimals) {
    var numberWithDecimals = num / pow(10, decimals);
    if (numberWithDecimals == numberWithDecimals.toInt()) {
      return numberWithDecimals.toInt();
    }
    return numberWithDecimals;
  }
}
