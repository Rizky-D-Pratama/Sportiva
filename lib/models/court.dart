import 'unavailable_time_slot.dart';
import 'venue.dart';

/// Day status for a Court today
enum CourtDayStatus {
  none,
  full,
  closed,
}

/// Model representing a Court (Lapangan)
class Court {
  final String id;
  final String name;
  final String category; // e.g. Futsal, Badminton, Voli, Basket
  final Venue venue;
  final int pricePerHour;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final CourtDayStatus dayStatus;
  final bool isActive;
  final List<String> facilities;
  final String description;
  final List<UnavailableTimeSlot> unavailableTimeSlots;

  const Court({
    required this.id,
    required this.name,
    required this.category,
    required this.venue,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.dayStatus = CourtDayStatus.none,
    this.isActive = true,
    this.facilities = const ['Indoor', 'Parkir', 'Toilet', 'Ruang ganti'],
    this.description =
        'Rumput sintetis premium, pencahayaan terang, dan ruang ganti bersih. Cocok untuk latihan maupun pertandingan tim.',
    this.unavailableTimeSlots = const [],
  });

  bool get isFullToday => dayStatus == CourtDayStatus.full;
  bool get isClosedToday => dayStatus == CourtDayStatus.closed;

  /// Formatted price helper e.g. "Rp150.000 / jam"
  String get formattedPrice {
    final buffer = StringBuffer();
    final priceStr = pricePerHour.toString();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return 'Rp${buffer.toString()} / jam';
  }

  /// Formatted rating helper e.g. "★ 4,9 (128)"
  String get formattedRating {
    final ratingStr = rating.toString().replaceAll('.', ',');
    return '★ $ratingStr ($reviewCount)';
  }

  Court copyWith({
    String? id,
    String? name,
    String? category,
    Venue? venue,
    int? pricePerHour,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    CourtDayStatus? dayStatus,
    bool? isActive,
    List<String>? facilities,
    String? description,
    List<UnavailableTimeSlot>? unavailableTimeSlots,
  }) {
    return Court(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      venue: venue ?? this.venue,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      dayStatus: dayStatus ?? this.dayStatus,
      isActive: isActive ?? this.isActive,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      unavailableTimeSlots: unavailableTimeSlots ?? this.unavailableTimeSlots,
    );
  }
}
