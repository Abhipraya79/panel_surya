/// Utility helper for formatting sensor telemetry numbers across the application.
/// Displays up to max 3 decimal places without forcing trailing zeros.
class SensorFormatter {
  SensorFormatter._();

  /// Formats a numerical sensor value to display at most 3 decimal places.
  /// Trailing zeros and redundant decimal points are stripped.
  /// Returns [fallback] (default '--') if [val] is null.
  ///
  /// Examples:
  /// - `0.0012345` -> `'0.001'`
  /// - `0.2189456` -> `'0.218'`
  /// - `31`        -> `'31'`
  /// - `12.5`      -> `'12.5'`
  /// - `15.123987` -> `'15.123'`
  /// - `30.999999` -> `'30.999'`
  /// - `2.000000`  -> `'2'`
  static String format(num? val, {String fallback = '--'}) {
    if (val == null) return fallback;

    String str = val.toString();
    if (str.contains('e') || str.contains('E')) {
      str = val.toDouble().toStringAsFixed(6);
    }

    final int dotIndex = str.indexOf('.');
    if (dotIndex == -1) {
      return str;
    }

    final String intPart = str.substring(0, dotIndex);
    String decPart = str.substring(dotIndex + 1);

    if (decPart.length > 3) {
      decPart = decPart.substring(0, 3);
    }

    while (decPart.endsWith('0')) {
      decPart = decPart.substring(0, decPart.length - 1);
    }

    if (decPart.isEmpty) {
      return intPart;
    }

    return '$intPart.$decPart';
  }
}
