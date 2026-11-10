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

/// Mock Data source containing sample data for Sportiva app
class MockData {
  static const String userName = 'Arya Ghiffary Habyantara';
  static const String adminName = 'Rizky';
  static const String adminFullName = 'Rizky Doni Pratama';
  static const String adminEmail = 'zydon@sportiva.id';
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

  static final User adminUser = User(
    id: 'admin_1',
    name: adminFullName,
    email: adminEmail,
    profilePhotoUrl: AppImages.blankProfile,
    phoneNumber: '0812 9999 8888',
    joinedDate: DateTime(2026, 1, 1),
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

  /// Mock recent bookings list for Admin Dashboard
  /// TODO: Connect to backend API.
  static final List<Booking> mockAdminRecentBookings = [
    Booking(
      id: 'admin_booking_1',
      bookingCode: 'ABSC-261015-004',
      courtName: 'Arena Basket C',
      date: '15 Okt 2026',
      timeRange: '19.00 – 21.00 WIB',
      totalPayment: 245000,
      status: BookingStatus.sudahBayar,
      paymentMethod: 'Transfer BCA',
      paymentDeadline: null,
      playDateTime: DateTime(2026, 10, 15, 19, 0),
      pricePerHour: 120000,
      serviceFee: 5000,
      durationHours: 2,
      createdDateText: '15 Oktober 2026, 14.00 WIB',
      paymentStatusText: '15 Oktober 2026, 14.05 WIB',
      userName: 'Shendy',
      userEmail: 'shendy@gmail.com',
      userPhone: '0812 3456 7890',
      venueName: 'Sportiva Center',
      facilitiesText: 'Basket • Indoor • Parquet • Toilet',
      courtImageUrl: AppImages.basket,
      fullDateText: '15 Oktober 2026',
      ticketDateText: 'Kamis, 15 Okt 2026',
    ),
    Booking(
      id: 'admin_booking_2',
      bookingCode: 'AVB-261015-003',
      courtName: 'Arena Voli B',
      date: '15 Okt 2026',
      timeRange: '18.00 – 20.00 WIB',
      totalPayment: 305000,
      status: BookingStatus.belumBayar,
      paymentMethod: 'Transfer Bank',
      paymentDeadline: 'Bayar sebelum 15 Okt 2026, 18.00 WIB',
      playDateTime: DateTime(2026, 10, 15, 18, 0),
      pricePerHour: 150000,
      serviceFee: 5000,
      durationHours: 2,
      createdDateText: '15 Oktober 2026, 13.00 WIB',
      paymentStatusText: 'Belum bayar',
      userName: 'Arya Ghiffary Habyantara',
      userEmail: 'habygantenk@gmail.com',
      userPhone: '0812 3456 7890',
      venueName: 'Sportiva Center',
      facilitiesText: 'Voli • Indoor • Net standar • Toilet',
      courtImageUrl: AppImages.volleyball,
      fullDateText: '15 Oktober 2026',
      ticketDateText: 'Kamis, 15 Okt 2026',
    ),
  ];

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


