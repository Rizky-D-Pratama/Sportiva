import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../../models/admin_report.dart';

/// Exception thrown when date range parameter is invalid (BK011)
class ReportInvalidRangeException implements Exception {
  final String? message;
  const ReportInvalidRangeException([this.message]);
}

/// Repository interface for Admin Report metrics.
abstract class AdminReportRepository {
  Future<AdminReportSummary> getReport(DateTimeRange range);
}

/// Fake implementation of AdminReportRepository using MockData.
class MockAdminReportRepository implements AdminReportRepository {
  const MockAdminReportRepository();

  @override
  Future<AdminReportSummary> getReport(DateTimeRange range) {
    return Future.value(MockData.getAdminReport(range));
  }
}
