import 'package:flutter/services.dart';
import 'price_format_helper.dart';

/// Custom TextInputFormatter for automatically inserting thousand separator dots while typing
class PriceInputFormatter extends TextInputFormatter {
  final int maxDigits;

  PriceInputFormatter({this.maxDigits = 7});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip non-digits
    String cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit maximum digits if set
    if (cleanDigits.length > maxDigits) {
      cleanDigits = cleanDigits.substring(0, maxDigits);
    }

    final formatted = PriceFormatHelper.formatDigitStringWithDots(cleanDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
