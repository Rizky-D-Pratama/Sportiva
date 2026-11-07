import '../constants/app_icons.dart';
import '../constants/app_images.dart';
import '../models/court.dart';
import '../models/venue.dart';

/// Mock Data source containing sample data for Sportiva app
class MockData {
  static const String userName = 'Arya Ghiffary Habyantara!';
  static const String welcomeGreeting = 'Selamat Datang 👋';
  static const String profilePhotoUrl = AppImages.blankProfile;

  static const String searchPlaceholder =
      'Cari lapangan, lokasi, atau venue...';

  static const String bannerTagline = 'JADWAL MAIN, TANPA RIBET';
  static const String bannerTitle = 'Main Lebih Seru, Booking Lebih Mudah';
  static const String bannerActionText = 'Cari lapangan sekarang →';

  static const Venue sportivaCenter = Venue(
    id: 'venue_1',
    name: 'Sportiva Center',
    location: 'Jl. Ketintang, Surabaya',
  );

  static final List<Court> popularCourts = [
    const Court(
      id: 'court_1',
      name: 'Arena Futsal A',
      category: 'Futsal',
      venue: sportivaCenter,
      pricePerHour: 150000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl: AppImages.soccer,
    ),
    const Court(
      id: 'court_2',
      name: 'Arena Badminton D',
      category: 'Badminton',
      venue: sportivaCenter,
      pricePerHour: 80000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl: AppImages.badminton,
    ),
  ];

  static final List<Map<String, dynamic>> sportCategories = [
    {
      'id': 'futsal',
      'label': 'Futsal',
      'icon': AppIcons.soccerBall,
    },
    {
      'id': 'voli',
      'label': 'Voli',
      'icon': AppIcons.volleyball,
    },
    {
      'id': 'basket',
      'label': 'Basket',
      'icon': AppIcons.basketBall,
    },
    {
      'id': 'badminton',
      'label': 'Badminton',
      'icon': AppIcons.shuttlecock,
    },
    {
      'id': 'jadwal',
      'label': 'Jadwal Lapangan',
      'icon': AppIcons.sportField,
    },
    {
      'id': 'riwayat',
      'label': 'Riwayat',
      'icon': AppIcons.timePast,
    },
  ];
}
