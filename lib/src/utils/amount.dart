class AmountUtils {
  // This methods removes decimals and returns a BigInt
  static BigInt extractDecimals(num num, int decimals) =>
      BigInt.parse(num.toStringAsFixed(decimals).replaceAll('.', ''));

  // This methods adds decimals for displaying purposes
  static num addDecimals(BigInt num, int decimals) {
    return getValueInUnit(num, decimals);
  }

  static double getValueInUnit(BigInt amount, int decimals) {
    final factor = BigInt.from(10).pow(decimals);
    final value = amount ~/ factor;
    final remainder = amount.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }
}
