import 'venue.dart';

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

  const Court({
    required this.id,
    required this.name,
    required this.category,
    required this.venue,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
  });

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
}
