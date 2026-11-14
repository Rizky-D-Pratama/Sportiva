/// Status type for unavailable time slots
enum SlotStatusType {
  booked, // Dipesan
  onHold, // Ditahan Sementara
  closed, // Ditutup
}

/// Origin mark for closure slots
enum SlotSourceMark {
  court,
  venue,
}

/// Model representing an unavailable time slot for a court
class UnavailableTimeSlot {
  final int startHour;
  final int endHour;
  final String statusLabel; // e.g. "Dipesan", "Ditahan Sementara", "Ditutup"
  final String note; // e.g. "Tidak dapat dibooking", "Perawatan"
  final SlotStatusType statusType;
  final String? closureId;
  final SlotSourceMark sourceMark;

  const UnavailableTimeSlot({
    required this.startHour,
    required this.endHour,
    required this.statusLabel,
    required this.note,
    required this.statusType,
    this.closureId,
    this.sourceMark = SlotSourceMark.court,
  });

  /// Formatted time range e.g. "19.00 – 20.00 WIB"
  String get timeRangeText {
    final startStr = startHour < 10 ? '0$startHour.00' : '$startHour.00';
    final endStr = endHour < 10 ? '0$endHour.00' : '$endHour.00';
    return '$startStr – $endStr WIB';
  }

  /// Formatted time range without WIB suffix e.g. "19.00 – 20.00"
  String get timeRangeShortText {
    final startStr = startHour < 10 ? '0$startHour.00' : '$startHour.00';
    final endStr = endHour < 10 ? '0$endHour.00' : '$endHour.00';
    return '$startStr – $endStr';
  }
}
