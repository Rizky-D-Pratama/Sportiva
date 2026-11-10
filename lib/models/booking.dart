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
  final int? rating; // 1 to 5 rating if finished and rated, null otherwise

  // Extended fields for Detail & Ticket views
  final int pricePerHour;
  final int serviceFee;
  final int durationHours;
  final String? createdDateText;
  final String? paymentStatusText;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String venueName;
  final String? facilitiesText;
  final String? courtImageUrl;
  final String? fullDateText;
  final String? ticketDateText;

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
    this.rating,
    this.pricePerHour = 100000,
    this.serviceFee = 5000,
    this.durationHours = 1,
    this.createdDateText,
    this.paymentStatusText,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.venueName = 'Sportiva Center',
    this.facilitiesText,
    this.courtImageUrl,
    this.fullDateText,
    this.ticketDateText,
  });

  /// Formatted price helper e.g. "Rp165.000"
  String get formattedTotalPayment => formatPrice(totalPayment);

  /// Helper to format arbitrary integer to "RpXXX.XXX"
  static String formatPrice(int amount) {
    final buffer = StringBuffer();
    final priceStr = amount.toString();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  int get subtotal => pricePerHour * durationHours;

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
    int? rating,
    int? pricePerHour,
    int? serviceFee,
    int? durationHours,
    String? createdDateText,
    String? paymentStatusText,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? venueName,
    String? facilitiesText,
    String? courtImageUrl,
    String? fullDateText,
    String? ticketDateText,
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
      rating: rating ?? this.rating,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      serviceFee: serviceFee ?? this.serviceFee,
      durationHours: durationHours ?? this.durationHours,
      createdDateText: createdDateText ?? this.createdDateText,
      paymentStatusText: paymentStatusText ?? this.paymentStatusText,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      venueName: venueName ?? this.venueName,
      facilitiesText: facilitiesText ?? this.facilitiesText,
      courtImageUrl: courtImageUrl ?? this.courtImageUrl,
      fullDateText: fullDateText ?? this.fullDateText,
      ticketDateText: ticketDateText ?? this.ticketDateText,
    );
  }
}
