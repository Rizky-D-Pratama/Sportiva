import 'package:flutter/foundation.dart';
import '../utils/date_format_helper.dart';

/// Single item entry for popular court list in Admin Report.
@immutable
class PopularCourtEntry {
  final String courtName;
  final int bookingCount;
  final double revenueJuta;

  const PopularCourtEntry({
    required this.courtName,
    required this.bookingCount,
    required this.revenueJuta,
  });

  String get formattedRevenueText =>
      DateFormatHelper.formatCompactRupiah(revenueJuta);

  String get formattedRowText => '$bookingCount booking · $formattedRevenueText';
}

/// Typed data model representing Admin Report summary and chart metrics for a given date range.
/// TODO: Replace with real aggregation response from server.
@immutable
class AdminReportSummary {
  final int totalBooking;
  final double totalRevenueJuta;
  final int dibayarCount;
  final int menungguCount;
  final int batalCount;
  final String chartTitle;
  final List<double> chartValues;
  final List<String> chartValueLabels;
  final List<String> chartLabels;
  final String chartDateRangeText;
  final List<PopularCourtEntry> popularCourts;

  const AdminReportSummary({
    required this.totalBooking,
    required this.totalRevenueJuta,
    required this.dibayarCount,
    required this.menungguCount,
    required this.batalCount,
    required this.chartTitle,
    required this.chartValues,
    required this.chartValueLabels,
    required this.chartLabels,
    required this.chartDateRangeText,
    required this.popularCourts,
  });

  String get formattedRevenueText =>
      DateFormatHelper.formatCompactRupiah(totalRevenueJuta);
}
