import '../constants/app_icons.dart';
import '../constants/app_images.dart';
import '../models/booking.dart';
import '../models/court.dart';
import '../models/unavailable_time_slot.dart';
import '../models/user.dart';
import '../models/venue.dart';

/// Mock Data source containing sample data for Sportiva app
class MockData {
  static const String userName = 'Arya Ghiffary Habyantara';
  static const String welcomeGreeting = 'Selamat Datang 👋';
  static const String profilePhotoUrl = AppImages.blankProfile;
  static const String userPhone = '0812 3456 7890';

  static final User currentUser = User(
    id: 'user_1',
    name: 'Arya Ghiffary Habyantara',
    email: 'habygantenk@gmail.com',
    profilePhotoUrl: AppImages.blankProfile,
    phoneNumber: '0812 3456 7890',
    joinedDate: DateTime(2026, 10, 1),
  );

  /// Helper to format user joined date into Indonesian text: "Sobat Sport sejak {Bulan} {Tahun}"
  static String formatJoinedDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final monthName = months[date.month - 1];
    return 'Sobat Sport sejak $monthName ${date.year}';
  }

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

  static final List<UnavailableTimeSlot> defaultUnavailableSlots = [
    const UnavailableTimeSlot(
      startHour: 19,
      endHour: 20,
      statusLabel: 'Dipesan',
      note: 'Tidak dapat dibooking',
      statusType: SlotStatusType.booked,
    ),
    const UnavailableTimeSlot(
      startHour: 12,
      endHour: 13,
      statusLabel: 'Ditahan Sementara',
      note: 'Menunggu pembayaran - tidak dapat dipesan',
      statusType: SlotStatusType.onHold,
    ),
    const UnavailableTimeSlot(
      startHour: 13,
      endHour: 14,
      statusLabel: 'Ditutup',
      note: 'Perawatan',
      statusType: SlotStatusType.closed,
    ),
  ];

  static final List<Court> allCourts = [
    Court(
      id: 'court_1',
      name: 'Arena Futsal A',
      category: 'Futsal',
      venue: sportivaCenter,
      pricePerHour: 150000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl: AppImages.soccer,
      facilities: const ['Indoor', 'Parkir', 'Toilet', 'Ruang ganti'],
      description:
          'Rumput sintetis premium, pencahayaan terang, dan ruang ganti bersih. Cocok untuk latihan maupun pertandingan tim.',
      unavailableTimeSlots: defaultUnavailableSlots,
    ),
    Court(
      id: 'court_2',
      name: 'Arena Voli B',
      category: 'Voli',
      venue: sportivaCenter,
      pricePerHour: 100000,
      rating: 4.8,
      reviewCount: 128,
      imageUrl: AppImages.volleyball,
      isFullToday: true,
      facilities: const ['Indoor', 'Parkir', 'Toilet', 'Ruang ganti'],
      description:
          'Lapangan voli vinyl berstandar nasional dengan sirkulasi udara yang baik dan tribun penonton.',
      unavailableTimeSlots: defaultUnavailableSlots,
    ),
    Court(
      id: 'court_3',
      name: 'Arena Basket C',
      category: 'Basket',
      venue: sportivaCenter,
      pricePerHour: 120000,
      rating: 4.8,
      reviewCount: 128,
      imageUrl: AppImages.basket,
      facilities: const ['Indoor', 'Parkir', 'Toilet', 'Ruang ganti'],
      description:
          'Lantai kayu parquet interlock profesional dengan papan pantul tempered glass.',
      unavailableTimeSlots: defaultUnavailableSlots,
    ),
    Court(
      id: 'court_4',
      name: 'Arena Badminton D',
      category: 'Badminton',
      venue: sportivaCenter,
      pricePerHour: 80000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl: AppImages.badminton,
      facilities: const ['Indoor', 'Parkir', 'Toilet', 'Ruang ganti'],
      description:
          'Karpet lapangan badminton berkualitas tinggi dengan pencahayaan anti-silau.',
      unavailableTimeSlots: defaultUnavailableSlots,
    ),
  ];

  static final List<Court> popularCourts = [
    allCourts[0],
    allCourts[3],
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

  static final List<Booking> mockBookings = [
    Booking(
      id: 'booking_1',
      bookingCode: 'AFA-261015-003',
      courtName: 'Arena Futsal A',
      date: '15 Okt 2026',
      timeRange: '18.00 – 20.00 WIB',
      totalPayment: 165000,
      status: BookingStatus.belumBayar,
      paymentMethod: 'Transfer bank',
      paymentDeadline: 'Bayar sebelum 15 Okt 2026, 18.00 WIB',
      playDateTime: DateTime(2026, 10, 15, 18, 0),
      pricePerHour: 150000,
      serviceFee: 5000,
      durationHours: 1,
      createdDateText: '13 Oktober 2026, 09.30 WIB',
      paymentStatusText: 'Belum bayar',
      userName: userName,
      userPhone: userPhone,
      venueName: 'Sportiva Center',
      facilitiesText: 'Futsal • Indoor • Sintetis • Toilet',
      courtImageUrl: AppImages.soccer,
      fullDateText: '15 Oktober 2026',
      ticketDateText: 'Kamis, 15 Okt 2026',
    ),
    Booking(
      id: 'booking_2',
      bookingCode: 'AVB-261016-008',
      courtName: 'Arena Voli B',
      date: '16 Okt 2026',
      timeRange: '16.00 – 17.00 WIB',
      totalPayment: 105000,
      status: BookingStatus.sudahBayar,
      paymentMethod: 'Transfer BCA',
      paymentDeadline: null,
      playDateTime: DateTime(2026, 10, 16, 16, 0),
      pricePerHour: 100000,
      serviceFee: 5000,
      durationHours: 1,
      createdDateText: '13 Oktober 2026, 09.30 WIB',
      paymentStatusText: '13 Oktober 2026, 09.35 WIB',
      userName: userName,
      userPhone: userPhone,
      venueName: 'Sportiva Center',
      facilitiesText: 'Voli • Indoor • Net standar • Toilet',
      courtImageUrl: AppImages.volleyball,
      fullDateText: '16 Oktober 2026',
      ticketDateText: 'Jumat, 16 Okt 2026',
    ),
    Booking(
      id: 'booking_3',
      bookingCode: 'ABDD-261010-001',
      courtName: 'Arena Badminton D',
      date: '10 Okt 2026',
      timeRange: '10.00 – 12.00 WIB',
      totalPayment: 165000,
      status: BookingStatus.selesai,
      rating: null,
      paymentMethod: 'Transfer BCA',
      playDateTime: DateTime(2026, 10, 10, 10, 0),
      pricePerHour: 80000,
      serviceFee: 5000,
      durationHours: 2,
      createdDateText: '9 Oktober 2026, 14.00 WIB',
      paymentStatusText: '9 Oktober 2026, 14.05 WIB',
      userName: userName,
      userPhone: userPhone,
      venueName: 'Sportiva Center',
      facilitiesText: 'Badminton • Indoor • Karpet • Toilet',
      courtImageUrl: AppImages.badminton,
      fullDateText: '10 Oktober 2026',
      ticketDateText: 'Sabtu, 10 Okt 2026',
    ),
    Booking(
      id: 'booking_4',
      bookingCode: 'ABSC-261008-012',
      courtName: 'Arena Basket C',
      date: '8 Okt 2026',
      timeRange: '16.00 – 18.00 WIB',
      totalPayment: 245000,
      status: BookingStatus.dibatalkan,
      rating: null,
      paymentMethod: 'Transfer BCA',
      playDateTime: DateTime(2026, 10, 8, 16, 0),
      pricePerHour: 120000,
      serviceFee: 5000,
      durationHours: 2,
      createdDateText: '7 Oktober 2026, 10.00 WIB',
      paymentStatusText: 'Dibatalkan',
      userName: userName,
      userPhone: userPhone,
      venueName: 'Sportiva Center',
      facilitiesText: 'Basket • Indoor • Parquet • Toilet',
      courtImageUrl: AppImages.basket,
      fullDateText: '8 Oktober 2026',
      ticketDateText: 'Kamis, 8 Okt 2026',
    ),
    Booking(
      id: 'booking_5',
      bookingCode: 'AFAB-261005-005',
      courtName: 'Arena Futsal A',
      date: '5 Okt 2026',
      timeRange: '14.00 – 16.00 WIB',
      totalPayment: 300000,
      status: BookingStatus.selesai,
      rating: 4,
      paymentMethod: 'Transfer BCA',
      playDateTime: DateTime(2026, 10, 5, 14, 0),
      pricePerHour: 147500,
      serviceFee: 5000,
      durationHours: 2,
      createdDateText: '4 Oktober 2026, 11.20 WIB',
      paymentStatusText: '4 Oktober 2026, 11.25 WIB',
      userName: userName,
      userPhone: userPhone,
      venueName: 'Sportiva Center',
      facilitiesText: 'Futsal • Indoor • Sintetis • Toilet',
      courtImageUrl: AppImages.soccer,
      fullDateText: '5 Oktober 2026',
      ticketDateText: 'Senin, 5 Okt 2026',
    ),
  ];
}
