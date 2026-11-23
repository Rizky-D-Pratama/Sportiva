import 'package:flutter/material.dart';
import '../data/booking_repository.dart';
import '../widgets/app_modal.dart';

/// Helper to display payment error modal dialogs matching Sportiva design system
class PaymentErrorHandler {
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
          'Sesi Berakhir',
          'Sesi Anda telah berakhir. Silakan masuk kembali.',
        ),
      PaymentNetworkException() => (
          'Terjadi Kesalahan',
          'Koneksi terputus. Periksa jaringan internet Anda.',
        ),
      PaymentServerException() => (
          'Terjadi Kesalahan',
          'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.',
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
