import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../constants/app_images.dart';
import '../models/admin_dashboard_stats.dart';
import '../models/admin_report.dart';
import '../models/booking.dart';
import '../models/court.dart';
import '../models/notification_item.dart';
import '../models/unavailable_time_slot.dart';
import '../models/user.dart';
import '../models/venue.dart';
import '../utils/date_format_helper.dart';

import 'repositories/auth_repository_impl.dart';

/// Mock Data source containing sample data for Sportiva app
class MockData {
  static String get userName => FakeAuthRepository.seedUser.name;
  static String get adminName => FakeAuthRepository.seedAdmin.name.split(' ').first;
  static String get adminFullName => FakeAuthRepository.seedAdmin.name;
  static String get adminEmail => FakeAuthRepository.seedAdmin.email;
  static const String welcomeGreeting = 'Selamat Datang 👋';
  static const String profilePhotoUrl = AppImages.blankProfile;
  static String get userPhone => FakeAuthRepository.seedUser.phoneNumber ?? '';

  static User get currentUser => FakeAuthRepository.seedUser;
  static User get adminUser => FakeAuthRepository.seedAdmin;

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
      userId: 'user_1',
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
      userEmail: FakeAuthRepository.seedUser.email,
      venueName: 'Sportiva Center',
      facilitiesText: 'Futsal • Indoor • Sintetis • Toilet',
      courtImageUrl: AppImages.soccer,
      fullDateText: '15 Oktober 2026',
      ticketDateText: 'Kamis, 15 Okt 2026',
    ),
    Booking(
      id: 'booking_2',
      userId: 'user_1',
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
      userEmail: FakeAuthRepository.seedUser.email,
      venueName: 'Sportiva Center',
      facilitiesText: 'Voli • Indoor • Net standar • Toilet',
      courtImageUrl: AppImages.volleyball,
      fullDateText: '16 Oktober 2026',
      ticketDateText: 'Jumat, 16 Okt 2026',
    ),
    Booking(
      id: 'booking_3',
      userId: 'user_1',
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
      userEmail: FakeAuthRepository.seedUser.email,
      venueName: 'Sportiva Center',
      facilitiesText: 'Badminton • Indoor • Karpet • Toilet',
      courtImageUrl: AppImages.badminton,
      fullDateText: '10 Oktober 2026',
      ticketDateText: 'Sabtu, 10 Okt 2026',
    ),
    Booking(
      id: 'booking_4',
      userId: 'user_1',
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
      userEmail: FakeAuthRepository.seedUser.email,
      venueName: 'Sportiva Center',
      facilitiesText: 'Basket • Indoor • Parquet • Toilet',
      courtImageUrl: AppImages.basket,
      fullDateText: '8 Oktober 2026',
      ticketDateText: 'Kamis, 8 Okt 2026',
    ),
    Booking(
      id: 'booking_5',
      userId: 'user_1',
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
      userEmail: FakeAuthRepository.seedUser.email,
      venueName: 'Sportiva Center',
      facilitiesText: 'Futsal • Indoor • Sintetis • Toilet',
      courtImageUrl: AppImages.soccer,
      fullDateText: '5 Oktober 2026',
      ticketDateText: 'Senin, 5 Okt 2026',
    ),
  ];

  /// Helper to format notification DateTime into: "15 Okt 2026, 09.35 WIB"
  static String formatNotificationDateTime(DateTime dt) {
    const shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dt.day;
    final month = shortMonths[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour.$minute WIB';
  }

  /// Sample notifications list as per Figma design
  static final List<NotificationItem> mockNotifications = [
    NotificationItem(
      id: 'notif_1',
      type: NotificationType.pembayaranDikonfirmasi,
      title: 'Pembayaran dikonfirmasi',
      content:
          'AVB-261016-008 · Arena Voli B. Pembayaran diterima, booking terkonfirmasi.',
      timestamp: DateTime(2026, 10, 15, 9, 35),
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_2',
      type: NotificationType.bookingMenungguPembayaran,
      title: 'Booking menunggu pembayaran',
      content:
          'ABD-261016-012 · Arena Badminton D. Status booking: belum bayar.',
      timestamp: DateTime(2026, 10, 15, 9, 20),
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_3',
      type: NotificationType.jamOperasionalBerubah,
      title: 'Jam operasional berubah',
      content:
          'Arena Futsal A buka pukul 10.00 – 21.00 pada 17 Okt 2026 karena perawatan.',
      timestamp: DateTime(2026, 10, 15, 8, 0),
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_4',
      type: NotificationType.pesananOtomatisDibatalkan,
      title: 'Pesanan otomatis dibatalkan',
      content:
          'ABC-261015-006 · Belum dibayar dalam 2 jam sejak pemesanan. Tenggat berakhir; pesanan otomatis batal dan slot dilepas.',
      timestamp: DateTime(2026, 10, 14, 16, 0),
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_5',
      type: NotificationType.informasiLayanan,
      title: 'Informasi layanan',
      content:
          'Layanan bantuan Sportiva tersedia setiap hari pukul 08.00 – 21.00 WIB.',
      timestamp: DateTime(2026, 10, 14, 10, 0),
      isRead: true,
    ),
  ];

  /// Mock statistics data for Admin Dashboard
  /// TODO: Connect to backend API.
  static final AdminDashboardStats mockAdminDashboardStats = AdminDashboardStats(
    totalBookingMonth: 128,
    monthName: 'Oktober',
    todayBookingCount: 4,
    totalCourtsCount: 4,
    monthlyRevenueJuta: 14.4,
    weeklyBookingCounts: const [8.0, 12.0, 10.0, 14.0, 16.0, 18.0, 6.0],
    weekDayLabels: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    weekDateRangeText: '5–11 Oktober 2026',
  );

  // TODO: dua daftar ini sementara (mockBookings & mockAdminBookings), akan disatukan di sesi sinkronisasi.
  static final List<Booking> mockAdminBookings = _initMockAdminBookings();
  static List<Booking> _initMockAdminBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    String yymmdd(DateTime d) {
      final yy = (d.year % 100).toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      return '$yy$mm$dd';
    }

    final todayCode = yymmdd(today);
    final yesterdayCode = yymmdd(yesterday);
    final tomorrowCode = yymmdd(tomorrow);
    final twoDaysAgoCode = yymmdd(twoDaysAgo);

    return [
      // --- HARI INI (4 Booking sesuai desain) ---
      Booking(
        id: 'admin_booking_today_1',
        userId: 'user_1',
        bookingCode: 'AFA-$todayCode-003',
        courtName: 'Arena Futsal A',
        date: DateFormatHelper.formatShortDate(today),
        timeRange: '18.00 – 20.00 WIB',
        totalPayment: 305000,
        status: BookingStatus.belumBayar,
        paymentMethod: 'Transfer Bank',
        paymentDeadline: 'Bayar sebelum ${DateFormatHelper.formatShortDate(today)}, 18.00 WIB',
        playDateTime: DateTime(today.year, today.month, today.day, 18, 0),
        pricePerHour: 150000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 09.30 WIB',
        paymentStatusText: 'Belum bayar',
        userName: 'Arya Ghiffary Habyantara',
        userEmail: FakeAuthRepository.seedUser.email,
        userPhone: '0812 3456 7890',
        venueName: 'Sportiva Center',
        facilitiesText: 'Futsal • Rumput sintetis • Parkir • Toilet',
        courtImageUrl: AppImages.soccer,
        fullDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}',
        ticketDateText: DateFormatHelper.formatFullDate(today),
      ),
      Booking(
        id: 'admin_booking_today_2',
        bookingCode: 'ABDD-$todayCode-002',
        courtName: 'Arena Badminton D',
        date: DateFormatHelper.formatShortDate(today),
        timeRange: '18.00 – 20.00 WIB',
        totalPayment: 165000,
        status: BookingStatus.sudahBayar,
        paymentMethod: 'Transfer BCA',
        paymentDeadline: null,
        playDateTime: DateTime(today.year, today.month, today.day, 18, 0),
        pricePerHour: 80000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 10.00 WIB',
        paymentStatusText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 10.05 WIB',
        userName: 'Sayyidina Dafi',
        userEmail: 'dafi@gmail.com',
        userPhone: '0812 1111 2222',
        venueName: 'Sportiva Center',
        facilitiesText: 'Badminton • Indoor • Matras • Ruang ganti',
        courtImageUrl: AppImages.badminton,
        fullDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}',
        ticketDateText: DateFormatHelper.formatFullDate(today),
      ),
      Booking(
        id: 'admin_booking_today_3',
        bookingCode: 'ABSC-$todayCode-004',
        courtName: 'Arena Basket C',
        date: DateFormatHelper.formatShortDate(today),
        timeRange: '19.00 – 21.00 WIB',
        totalPayment: 245000,
        status: BookingStatus.sudahBayar,
        paymentMethod: 'Transfer BCA',
        paymentDeadline: null,
        playDateTime: DateTime(today.year, today.month, today.day, 19, 0),
        pricePerHour: 120000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 14.00 WIB',
        paymentStatusText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 14.05 WIB',
        userName: 'Shendy',
        userEmail: 'shendy@gmail.com',
        userPhone: '0812 3456 7890',
        venueName: 'Sportiva Center',
        facilitiesText: 'Basket • Indoor • Parquet • Toilet',
        courtImageUrl: AppImages.basket,
        fullDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}',
        ticketDateText: DateFormatHelper.formatFullDate(today),
      ),
      Booking(
        id: 'admin_booking_today_4',
        bookingCode: 'ABDD-$todayCode-001',
        courtName: 'Arena Badminton D',
        date: DateFormatHelper.formatShortDate(today),
        timeRange: '14.00 – 15.00 WIB',
        totalPayment: 85000,
        status: BookingStatus.dibatalkan,
        paymentMethod: 'Transfer Bank',
        paymentDeadline: null,
        playDateTime: DateTime(today.year, today.month, today.day, 14, 0),
        pricePerHour: 80000,
        serviceFee: 5000,
        durationHours: 1,
        createdDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 11.00 WIB',
        paymentStatusText: 'Dibatalkan',
        userName: 'Irsyadul Ibad',
        userEmail: 'irsyad@gmail.com',
        userPhone: '0813 9999 0000',
        venueName: 'Sportiva Center',
        facilitiesText: 'Badminton • Indoor • Matras • Ruang ganti',
        courtImageUrl: AppImages.badminton,
        fullDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}',
        ticketDateText: DateFormatHelper.formatFullDate(today),
      ),

      // --- KEMARIN (Yesterday: Selesai & Sudah bayar) ---
      Booking(
        id: 'admin_booking_yest_1',
        bookingCode: 'AVB-$yesterdayCode-005',
        courtName: 'Arena Voli B',
        date: DateFormatHelper.formatShortDate(yesterday),
        timeRange: '16.00 – 18.00 WIB',
        totalPayment: 205000,
        status: BookingStatus.selesai,
        paymentMethod: 'Transfer Mandiri',
        playDateTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 0),
        pricePerHour: 100000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${yesterday.day} ${DateFormatHelper.monthNames[yesterday.month - 1]} ${yesterday.year}, 08.00 WIB',
        paymentStatusText: '${yesterday.day} ${DateFormatHelper.monthNames[yesterday.month - 1]} ${yesterday.year}, 08.10 WIB',
        userName: 'Rizky Pratama',
        userEmail: 'rizky@gmail.com',
        userPhone: '0812 7777 8888',
        venueName: 'Sportiva Center',
        facilitiesText: 'Voli • Indoor • Net standar • Toilet',
        courtImageUrl: AppImages.volleyball,
        fullDateText: '${yesterday.day} ${DateFormatHelper.monthNames[yesterday.month - 1]} ${yesterday.year}',
        ticketDateText: DateFormatHelper.formatFullDate(yesterday),
      ),

      // --- 2 HARI LALU (Two days ago: Selesai) ---
      Booking(
        id: 'admin_booking_2ago_1',
        bookingCode: 'AFA-$twoDaysAgoCode-001',
        courtName: 'Arena Futsal A',
        date: DateFormatHelper.formatShortDate(twoDaysAgo),
        timeRange: '15.00 – 17.00 WIB',
        totalPayment: 305000,
        status: BookingStatus.selesai,
        paymentMethod: 'Transfer BCA',
        playDateTime: DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 15, 0),
        pricePerHour: 150000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${twoDaysAgo.day} ${DateFormatHelper.monthNames[twoDaysAgo.month - 1]} ${twoDaysAgo.year}, 10.00 WIB',
        paymentStatusText: '${twoDaysAgo.day} ${DateFormatHelper.monthNames[twoDaysAgo.month - 1]} ${twoDaysAgo.year}, 10.05 WIB',
        userName: 'Budi Santoso',
        userEmail: 'budi@gmail.com',
        userPhone: '0815 1234 5678',
        venueName: 'Sportiva Center',
        facilitiesText: 'Futsal • Rumput sintetis • Parkir • Toilet',
        courtImageUrl: AppImages.soccer,
        fullDateText: '${twoDaysAgo.day} ${DateFormatHelper.monthNames[twoDaysAgo.month - 1]} ${twoDaysAgo.year}',
        ticketDateText: DateFormatHelper.formatFullDate(twoDaysAgo),
      ),

      // --- BESOK (Tomorrow: Sudah bayar) ---
      Booking(
        id: 'admin_booking_tom_1',
        bookingCode: 'ABSC-$tomorrowCode-001',
        courtName: 'Arena Basket C',
        date: DateFormatHelper.formatShortDate(tomorrow),
        timeRange: '10.00 – 12.00 WIB',
        totalPayment: 245000,
        status: BookingStatus.sudahBayar,
        paymentMethod: 'Transfer BCA',
        playDateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        pricePerHour: 120000,
        serviceFee: 5000,
        durationHours: 2,
        createdDateText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 15.00 WIB',
        paymentStatusText: '${today.day} ${DateFormatHelper.monthNames[today.month - 1]} ${today.year}, 15.10 WIB',
        userName: 'Eko Wijaya',
        userEmail: 'eko@gmail.com',
        userPhone: '0812 8888 9999',
        venueName: 'Sportiva Center',
        facilitiesText: 'Basket • Indoor • Parquet • Toilet',
        courtImageUrl: AppImages.basket,
        fullDateText: '${tomorrow.day} ${DateFormatHelper.monthNames[tomorrow.month - 1]} ${tomorrow.year}',
        ticketDateText: DateFormatHelper.formatFullDate(tomorrow),
      ),
    ];
  }

  /// Recent bookings list for Admin Dashboard (takes 2 most recently created bookings)
  static List<Booking> get mockAdminRecentBookings => mockAdminBookings.take(2).toList();

  /// Generates deterministic mock report data for any given date range.
  static AdminReportSummary getAdminReport(DateTimeRange range) {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);

    int totalDibayar = 0;
    int totalMenunggu = 0;
    int totalBatal = 0;
    double totalRevenueJuta = 0.0;

    int futsalCount = 0;
    double futsalRev = 0.0;
    int voliCount = 0;
    double voliRev = 0.0;
    int basketCount = 0;
    double basketRev = 0.0;
    int badmintonCount = 0;
    double badmintonRev = 0.0;

    final List<Map<String, dynamic>> dailyEntries = [];

    DateTime curr = start;
    while (!curr.isAfter(end)) {
      final day = curr.day;
      final weekday = curr.weekday;

      final dibayar = 3 + ((day * 7 + weekday * 3) % 3);
      final menunggu = (day % 5 == 0) ? 1 : 0;
      final batal = (day % 15 == 0) ? 1 : 0;

      final dailyRevenue = dibayar * 0.12;

      totalDibayar += dibayar;
      totalMenunggu += menunggu;
      totalBatal += batal;
      totalRevenueJuta += dailyRevenue;

      final fCount = (dibayar * 0.40).round();
      final vCount = (dibayar * 0.25).round();
      final bCount = (dibayar * 0.20).round();
      final dCount = (dibayar - fCount - vCount - bCount).clamp(0, 999);

      futsalCount += fCount;
      futsalRev += fCount * 0.15;

      voliCount += vCount;
      voliRev += vCount * 0.10;

      basketCount += bCount;
      basketRev += bCount * 0.12;

      badmintonCount += dCount;
      badmintonRev += dCount * 0.08;

      dailyEntries.add({
        'date': curr,
        'revenue': dailyRevenue,
        'dibayar': dibayar,
      });

      curr = curr.add(const Duration(days: 1));
    }

    final totalBooking = totalDibayar + totalMenunggu + totalBatal;
    final dayCount = end.difference(start).inDays + 1;

    String chartTitle;
    List<double> chartValues = [];
    List<String> chartValueLabels = [];
    List<String> chartLabels = [];

    if (dayCount <= 7) {
      chartTitle = 'Pendapatan harian';
      for (final entry in dailyEntries) {
        final d = entry['date'] as DateTime;
        final rev = entry['revenue'] as double;
        chartValues.add(rev);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(rev));
        chartLabels.add(DateFormatHelper.dayNames[d.weekday - 1].substring(0, 3));
      }
    } else if (dayCount <= 49) {
      chartTitle = 'Pendapatan mingguan';
      int weekIdx = 1;
      for (int i = 0; i < dailyEntries.length; i += 7) {
        final chunk = dailyEntries.sublist(
          i,
          (i + 7 > dailyEntries.length) ? dailyEntries.length : i + 7,
        );
        final chunkRev = chunk.fold<double>(
          0.0,
          (sum, item) => sum + (item['revenue'] as double),
        );
        chartValues.add(chunkRev);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(chunkRev));
        chartLabels.add('M$weekIdx');
        weekIdx++;
      }
    } else {
      chartTitle = 'Pendapatan bulanan';
      final Map<int, double> monthRevenues = {};
      final Map<int, int> monthNamesMap = {};

      for (final entry in dailyEntries) {
        final d = entry['date'] as DateTime;
        final key = d.year * 100 + d.month;
        monthRevenues[key] = (monthRevenues[key] ?? 0.0) + (entry['revenue'] as double);
        monthNamesMap[key] = d.month;
      }

      monthRevenues.forEach((key, rev) {
        final m = monthNamesMap[key]!;
        chartValues.add(rev);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(rev));
        chartLabels.add(DateFormatHelper.shortMonthNames[m - 1]);
      });
    }

    final rangeStr = DateFormatHelper.formatDateRangeInputText(start, end);
    final chartDateRangeText = '$rangeStr • dalam juta rupiah';

    final popularCourts = [
      PopularCourtEntry(
        courtName: 'Arena Futsal A',
        bookingCount: futsalCount,
        revenueJuta: futsalRev,
      ),
      PopularCourtEntry(
        courtName: 'Arena Voli B',
        bookingCount: voliCount,
        revenueJuta: voliRev,
      ),
      PopularCourtEntry(
        courtName: 'Arena Basket C',
        bookingCount: basketCount,
        revenueJuta: basketRev,
      ),
      PopularCourtEntry(
        courtName: 'Arena Badminton D',
        bookingCount: badmintonCount,
        revenueJuta: badmintonRev,
      ),
    ];

    popularCourts.sort((a, b) {
      final cmp = b.bookingCount.compareTo(a.bookingCount);
      if (cmp != 0) return cmp;
      return b.revenueJuta.compareTo(a.revenueJuta);
    });

    return AdminReportSummary(
      totalBooking: totalBooking,
      totalRevenueJuta: totalRevenueJuta,
      dibayarCount: totalDibayar,
      menungguCount: totalMenunggu,
      batalCount: totalBatal,
      chartTitle: chartTitle,
      chartValues: chartValues,
      chartValueLabels: chartValueLabels,
      chartLabels: chartLabels,
      chartDateRangeText: chartDateRangeText,
      popularCourts: popularCourts,
    );
  }
}


