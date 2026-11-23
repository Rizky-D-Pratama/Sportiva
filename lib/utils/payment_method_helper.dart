/// Pure helper function to map raw Midtrans payment_type and detail_metode to Indonesian UI label.
class PaymentMethodHelper {
  static String? getLabel(String? paymentType, String? detailMetode) {
    if (paymentType == null || paymentType.isEmpty) {
      return null;
    }

    final typeLower = paymentType.toLowerCase().trim();
    final detailTrimmed = detailMetode?.trim() ?? '';

    switch (typeLower) {
      case 'bank_transfer':
        if (detailTrimmed.isEmpty) {
          return 'Virtual Account';
        }
        if (detailTrimmed.toLowerCase() == 'bca') {
          return 'Virtual Account BCA';
        }
        return 'Virtual Account ${detailTrimmed.toUpperCase()}';

      case 'gopay':
        return 'GoPay';

      case 'qris':
        return 'QRIS';

      case 'credit_card':
      case 'cctor':
        return 'Kartu Kredit/Debit';

      default:
        return 'Metode pembayaran lain';
    }
  }
}
