import 'package:flutter/foundation.dart';

enum BookingStatus {
  belumBayar,
  sudahBayar,
  selesai,
  dibatalkan,
}

/// Model representing a user Booking (Pesanan)
@immutable
class Booking {
  final String id;
  final String bookingCode;
  final String courtName;
  final String date;
  final String timeRange;
  final int totalPayment;
  final BookingStatus status;
  final String? paymentMethod;
  final String? paymentDeadline;
  final DateTime playDateTime; // Used for sorting by closest play date

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.courtName,
    required this.date,
    required this.timeRange,
    required this.totalPayment,
    required this.status,
    this.paymentMethod,
    this.paymentDeadline,
    required this.playDateTime,
  });

  /// Formatted price helper e.g. "Rp165.000"
  String get formattedTotalPayment {
    final buffer = StringBuffer();
    final priceStr = totalPayment.toString();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  Booking copyWith({
    String? id,
    String? bookingCode,
    String? courtName,
    String? date,
    String? timeRange,
    int? totalPayment,
    BookingStatus? status,
    String? paymentMethod,
    String? paymentDeadline,
    DateTime? playDateTime,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      courtName: courtName ?? this.courtName,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      totalPayment: totalPayment ?? this.totalPayment,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDeadline: paymentDeadline ?? this.paymentDeadline,
      playDateTime: playDateTime ?? this.playDateTime,
    );
  }
}
