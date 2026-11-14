import '../constants/app_constants.dart';

/// Model representing a court or venue closure set by admin
class VenueClosure {
  final String id;
  final String venueId;
  final String? courtId; // null or empty means whole venue
  final DateTime date;
  final int startHour;
  final int endHour;
  final String reason;

  const VenueClosure({
    required this.id,
    required this.venueId,
    this.courtId,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.reason,
  });

  /// Whether this closure applies to the entire venue
  bool get isWholeVenue => courtId == null || courtId!.isEmpty;

  /// Whether this closure covers full operational hours
  bool get isFullDay =>
      startHour <= AppConstants.operationalStartHour &&
      endHour >= AppConstants.operationalEndHour;

  /// Formatted time range text e.g. "08.00 – 24.00"
  String get timeRangeText {
    final startStr = startHour < 10 ? '0$startHour.00' : '$startHour.00';
    final endStr = endHour < 10 ? '0$endHour.00' : '$endHour.00';
    return '$startStr – $endStr';
  }

  VenueClosure copyWith({
    String? id,
    String? venueId,
    String? courtId,
    DateTime? date,
    int? startHour,
    int? endHour,
    String? reason,
  }) {
    return VenueClosure(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      courtId: courtId ?? this.courtId,
      date: date ?? this.date,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      reason: reason ?? this.reason,
    );
  }
}
