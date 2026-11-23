import 'package:flutter/material.dart';
import '../data/booking_repository.dart';
import '../widgets/app_modal.dart';
import 'payment_error_handler.dart';

/// Helper to display booking cancellation error modal dialogs matching Sportiva design system
class BookingErrorHandler {
  static Future<void> showErrorDialog(BuildContext context, Object exception) {
    final (title, message) = switch (exception) {
      BookingNotCancellableException() => (
          'Pesanan Tidak Dapat Dibatalkan',
          'Pesanan ini sudah dibayar sehingga tidak dapat dibatalkan.',
        ),
      BookingNotFoundException(:final message) => (
          PaymentErrorHandler.serverErrorTitle,
          (message != null && message.isNotEmpty)
              ? message
              : PaymentErrorHandler.serverErrorMessage,
        ),
      BookingUnauthorizedException() => (
          PaymentErrorHandler.sessionExpiredTitle,
          PaymentErrorHandler.sessionExpiredMessage,
        ),
      BookingNetworkException() => (
          PaymentErrorHandler.networkErrorTitle,
          PaymentErrorHandler.networkErrorMessage,
        ),
      BookingServerException(:final message) => (
          PaymentErrorHandler.serverErrorTitle,
          (message != null && message.isNotEmpty)
              ? message
              : PaymentErrorHandler.serverErrorMessage,
        ),
      _ => (
          PaymentErrorHandler.serverErrorTitle,
          PaymentErrorHandler.serverErrorMessage,
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
