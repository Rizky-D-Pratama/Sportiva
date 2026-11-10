import 'package:flutter/foundation.dart';

/// Typed data model representing Admin Dashboard summary statistics & chart data.
/// TODO: Replace with real server API response.
@immutable
class AdminDashboardStats {
  final int totalBookingMonth;
  final String monthName;
  final int todayBookingCount;
  final int totalCourtsCount;
  final double monthlyRevenueJuta;
  final List<double> weeklyBookingCounts;
  final List<String> weekDayLabels;
  final String weekDateRangeText;

  const AdminDashboardStats({
    required this.totalBookingMonth,
    required this.monthName,
    required this.todayBookingCount,
    required this.totalCourtsCount,
    required this.monthlyRevenueJuta,
    required this.weeklyBookingCounts,
    required this.weekDayLabels,
    required this.weekDateRangeText,
  });

  /// Total count calculated dynamically from weekly array
  int get totalWeeklyBookings {
    return weeklyBookingCounts.fold<int>(
      0,
      (sum, val) => sum + val.round(),
    );
  }

  /// Formatted compact revenue string, e.g. "Rp14,4 jt"
  String get formattedRevenueText {
    final cleanStr = monthlyRevenueJuta % 1 == 0
        ? monthlyRevenueJuta.toInt().toString()
        : monthlyRevenueJuta.toString().replaceAll('.', ',');
    return 'Rp$cleanStr jt';
  }
}
