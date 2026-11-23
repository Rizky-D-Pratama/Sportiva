import 'package:flutter/material.dart';
import '../data/booking_repository.dart';
import '../widgets/app_modal.dart';

/// Helper to display payment error modal dialogs matching Sportiva design system
class PaymentErrorHandler {
  static const networkErrorTitle = 'Terjadi Kesalahan';
  static const networkErrorMessage = 'Koneksi terputus. Periksa jaringan internet Anda.';
  static const serverErrorTitle = 'Terjadi Kesalahan';
  static const serverErrorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
  static const sessionExpiredTitle = 'Sesi Berakhir';
  static const sessionExpiredMessage = 'Sesi Anda telah berakhir. Silakan masuk kembali.';

  static Future<void> showErrorDialog(BuildContext context, PaymentException exception) {
    final (title, message) = switch (exception) {
      PaymentExpiredException() => (
          'Waktu Pembayaran Habis',
          'Batas waktu pembayaran pesanan ini sudah habis atau hampir habis. Silakan buat pesanan baru.',
        ),
      PaymentNotPayableException() => (
          'Pesanan Tidak Dapat Dibayar',
          'Pesanan ini sudah dibayar atau dibatalkan.',
        ),
      PaymentUnauthorizedException() => (
          sessionExpiredTitle,
          sessionExpiredMessage,
        ),
      PaymentNetworkException() => (
          networkErrorTitle,
          networkErrorMessage,
        ),
      PaymentServerException() => (
          serverErrorTitle,
          serverErrorMessage,
        ),
    };

    return AppModal.show(
      context: context,
      title: title,
      message: message,
      primaryButtonLabel: 'Tutup',
      onPrimaryPressed: () => Navigator.pop(context),
    );
  }
}
