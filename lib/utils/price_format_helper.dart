/// Helper utilities for price formatting and parsing with thousand separator dots
class PriceFormatHelper {
  /// Format integer to dot-separated string e.g. 150000 -> "150.000"
  static String formatPriceNumber(int? price) {
    if (price == null) return '';
    return formatDigitStringWithDots(price.toString());
  }

  /// Format digit string to dot-separated string e.g. "150000" -> "150.000"
  static String formatDigitStringWithDots(String input) {
    final cleanDigits = input.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i > 0 && (cleanDigits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }
    return buffer.toString();
  }

  /// Parse dot-formatted or raw string into integer e.g. "150.000" -> 150000
  static int? parsePrice(String? formattedText) {
    if (formattedText == null) return null;
    final cleanDigits = formattedText.replaceAll(RegExp(r'\D'), '').trim();
    return int.tryParse(cleanDigits);
  }
}
