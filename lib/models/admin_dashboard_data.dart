import 'package:flutter/foundation.dart';
import '../utils/date_format_helper.dart';
import 'booking.dart';

/// Typed data model representing Admin Dashboard summary metrics and recent bookings.
@immutable
class AdminDashboardData {
  final int totalBookingMonth;
  final int todayBookingCount;
  final int totalCourtsCount;
  final int monthlyRevenueRupiah;
  final List<int> weeklyBookingCounts;
  final List<Booking> recentBookings;

  const AdminDashboardData({
    required this.totalBookingMonth,
    required this.todayBookingCount,
    required this.totalCourtsCount,
    required this.monthlyRevenueRupiah,
    required this.weeklyBookingCounts,
    required this.recentBookings,
  });

  /// Total count calculated dynamically from weekly array
  int get totalWeeklyBookings {
    return weeklyBookingCounts.fold<int>(
      0,
      (sum, val) => sum + val,
    );
  }

  /// Formatted revenue text e.g. "Rp14,4 jt" or "Rp250.000"
  String get formattedRevenueText {
    return DateFormatHelper.formatCompactRupiah(monthlyRevenueRupiah / 1000000.0);
  }
}
