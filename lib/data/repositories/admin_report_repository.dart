import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../../models/admin_report.dart';

/// Repository interface for Admin Report metrics.
/// TODO: Replace with real database / SQL aggregation API from backend server.
abstract class AdminReportRepository {
  AdminReportSummary getReport(DateTimeRange range);
}

/// Fake implementation of AdminReportRepository using MockData.
class MockAdminReportRepository implements AdminReportRepository {
  const MockAdminReportRepository();

  @override
  AdminReportSummary getReport(DateTimeRange range) {
    return MockData.getAdminReport(range);
  }
}
