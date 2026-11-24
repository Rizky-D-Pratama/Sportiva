import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin_report.dart';
import '../../utils/date_format_helper.dart';
import '../booking_repository.dart';
import 'admin_report_repository.dart';
import 'supabase_auth_repository.dart';

/// Supabase implementation of AdminReportRepository
class SupabaseAdminReportRepository implements AdminReportRepository {
  /// Helper to log debug messages in kDebugMode only
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  @override
  Future<AdminReportSummary> getReport(DateTimeRange range) async {
    final startStr =
        '${range.start.year}-${range.start.month.toString().padLeft(2, '0')}-${range.start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${range.end.year}-${range.end.month.toString().padLeft(2, '0')}-${range.end.day.toString().padLeft(2, '0')}';

    try {
      final response = await Supabase.instance.client.rpc(
        'get_admin_report',
        params: {
          'p_dari': startStr,
          'p_sampai': endStr,
        },
      );

      _log('SUPABASE get_admin_report response: $response');
      final json = Map<String, dynamic>.from(response as Map<String, dynamic>);
      return _mapJsonToReportSummary(json, range);
    } on PostgrestException catch (e) {
      _log('SUPABASE PostgrestException in getAdminReport: code=${e.code}, message=${e.message}');
      if (e.code == 'BK007') {
        throw const BookingUnauthorizedException();
      }
      if (e.code == 'BK010') {
        throw const BookingNotAdminException();
      }
      if (e.code == 'BK011') {
        throw ReportInvalidRangeException(e.message);
      }
      throw BookingServerException(e.code, e.message);
    } catch (e) {
      _log('SUPABASE Exception in getAdminReport: $e');
      if (isNetworkError(e)) {
        throw const BookingNetworkException();
      }
      if (e is BookingException || e is ReportInvalidRangeException) {
        rethrow;
      }
      throw BookingServerException(null, e.toString());
    }
  }

  AdminReportSummary _mapJsonToReportSummary(
    Map<String, dynamic> json,
    DateTimeRange range,
  ) {
    final totalBooking = (json['total_booking'] as num).toInt();
    final dibayarCount = (json['dibayar'] as num).toInt();
    final menungguCount = (json['menunggu'] as num).toInt();
    final batalCount = (json['batal'] as num).toInt();

    final totalPendapatanRupiah = (json['pendapatan'] as num).toInt();
    final totalRevenueJuta = totalPendapatanRupiah / 1000000.0;

    final harianList = json['harian'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> dailyEntries = [];
    for (final item in harianList) {
      final map = item as Map<String, dynamic>;
      final tanggalStr = map['tanggal'] as String;
      final dateParts = tanggalStr.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      final revRupiah = (map['pendapatan'] as num).toInt();
      dailyEntries.add({
        'date': date,
        'revenueRupiah': revRupiah,
        'revenueJuta': revRupiah / 1000000.0,
      });
    }

    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final dayCount = end.difference(start).inDays + 1;

    String chartTitle;
    final List<double> chartValues = [];
    final List<String> chartValueLabels = [];
    final List<String> chartLabels = [];

    if (dayCount <= 7) {
      chartTitle = 'Pendapatan harian';
      for (final entry in dailyEntries) {
        final d = entry['date'] as DateTime;
        final revJuta = entry['revenueJuta'] as double;
        chartValues.add(revJuta);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(revJuta));
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
        final chunkRevRupiah = chunk.fold<int>(
          0,
          (sum, item) => sum + (item['revenueRupiah'] as int),
        );
        final chunkRevJuta = chunkRevRupiah / 1000000.0;
        chartValues.add(chunkRevJuta);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(chunkRevJuta));
        chartLabels.add('M$weekIdx');
        weekIdx++;
      }
    } else {
      chartTitle = 'Pendapatan bulanan';
      final Map<int, int> monthRevenuesRupiah = {};
      final Map<int, int> monthNamesMap = {};

      for (final entry in dailyEntries) {
        final d = entry['date'] as DateTime;
        final key = d.year * 100 + d.month;
        monthRevenuesRupiah[key] =
            (monthRevenuesRupiah[key] ?? 0) + (entry['revenueRupiah'] as int);
        monthNamesMap[key] = d.month;
      }

      monthRevenuesRupiah.forEach((key, revRupiah) {
        final m = monthNamesMap[key]!;
        final monthRevJuta = revRupiah / 1000000.0;
        chartValues.add(monthRevJuta);
        chartValueLabels.add(DateFormatHelper.formatChartValueLabel(monthRevJuta));
        chartLabels.add(DateFormatHelper.shortMonthNames[m - 1]);
      });
    }

    final rangeStr = DateFormatHelper.formatDateRangeInputText(start, end);
    final chartDateRangeText = '$rangeStr • dalam juta rupiah';

    final populerList = json['lapangan_populer'] as List<dynamic>? ?? [];
    final List<PopularCourtEntry> popularCourts = [];

    for (final item in populerList) {
      final map = item as Map<String, dynamic>;
      final courtName = map['nama_lapangan'] as String? ?? '';
      final bookingCount = (map['booking_dibayar'] as num).toInt();
      final revRupiah = (map['pendapatan'] as num).toInt();
      popularCourts.add(
        PopularCourtEntry(
          courtName: courtName,
          bookingCount: bookingCount,
          revenueJuta: revRupiah / 1000000.0,
        ),
      );
    }

    return AdminReportSummary(
      totalBooking: totalBooking,
      totalRevenueJuta: totalRevenueJuta,
      dibayarCount: dibayarCount,
      menungguCount: menungguCount,
      batalCount: batalCount,
      chartTitle: chartTitle,
      chartValues: chartValues,
      chartValueLabels: chartValueLabels,
      chartLabels: chartLabels,
      chartDateRangeText: chartDateRangeText,
      popularCourts: popularCourts,
    );
  }
}
