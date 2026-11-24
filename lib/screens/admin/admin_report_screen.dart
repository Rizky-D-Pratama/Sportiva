import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../constants/app_icons.dart';
import '../../data/booking_repository.dart';
import '../../data/repositories/admin_report_repository.dart';
import '../../models/admin_report.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/admin_stat_card.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_info_row.dart';
import '../../widgets/date_range_bottom_sheet.dart';
import '../../widgets/weekly_bar_chart_card.dart';

/// Admin Report Screen showing date range metrics, statistics, earnings chart, and popular courts.
class AdminReportScreen extends StatefulWidget {
  final AdminReportRepository? repository;

  const AdminReportScreen({
    super.key,
    this.repository,
  });

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  late final AdminReportRepository _repository;
  late DateTimeRange _selectedRange;
  AdminReportSummary? _reportSummary;
  bool _isLoading = true;
  String? _errorMessage;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AppConfig.adminReportRepository;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    _selectedRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    final currentRequestId = ++_requestId;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _repository.getReport(_selectedRange);
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _reportSummary = summary;
        _isLoading = false;
      });
    } on BookingNetworkException {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _errorMessage = 'Gagal memuat laporan. Periksa jaringan internet Anda.';
        _isLoading = false;
      });
    } on BookingNotAdminException {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _errorMessage = 'Akun ini tidak memiliki akses admin.';
        _isLoading = false;
      });
    } on BookingUnauthorizedException {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        _isLoading = false;
      });
    } on ReportInvalidRangeException {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _errorMessage = 'Rentang tanggal tidak valid.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || currentRequestId != _requestId) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        _isLoading = false;
      });
    }
  }

  void _showDateRangeBottomSheet(BuildContext context) {
    showReportDateRangeBottomSheet(
      context: context,
      initialRange: _selectedRange,
      onApplied: (newRange) {
        if (_selectedRange == newRange) return;
        setState(() {
          _selectedRange = newRange;
        });
        _fetchReport();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final now = DateTime.now();
    final todayFormatted =
        '${now.day} ${DateFormatHelper.monthNames[now.month - 1]} ${now.year}';

    final rangeInputText = DateFormatHelper.formatDateRangeInputText(
      _selectedRange.start,
      _selectedRange.end,
    );

    return RefreshIndicator(
      onRefresh: _fetchReport,
      color: colors.brandPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingXLarge,
          vertical: AppTheme.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. App Header with Bell Notification
            const AppHeader(
              title: 'Laporan',
              showNotificationBell: true,
            ),
            const SizedBox(height: 16.0),

            // 2. Date Range Field Trigger
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rentang tanggal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6.0),
                InkWell(
                  onTap: () => _showDateRangeBottomSheet(context),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    height: AppTheme.inputHeight,
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: colors.borderDefault,
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rangeInputText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        SvgPicture.asset(
                          AppIcons.calendar,
                          width: 18.0,
                          height: 18.0,
                          colorFilter: ColorFilter.mode(
                            colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 48.0, bottom: 48.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.brandPrimary,
                  ),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 48.0, bottom: 48.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      AppButton(
                        label: 'Coba Lagi',
                        onPressed: _fetchReport,
                        variant: AppButtonVariant.secondary,
                      ),
                    ],
                  ),
                ),
              )
            else if (_reportSummary != null) ...[
              // 3. Stat Cards (Total booking & Pendapatan lapangan)
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      value: _reportSummary!.totalBooking.toString(),
                      label: 'Total booking',
                      iconPath: AppIcons.calendarCheck,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AdminStatCard(
                      value: _reportSummary!.formattedRevenueText,
                      label: 'Pendapatan lapangan',
                      iconPath: AppIcons.wallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // 4. Status Count Badges (Non-clickable)
              Row(
                children: [
                  AppBadge(
                    label: '${_reportSummary!.dibayarCount} dibayar',
                    variant: AppBadgeVariant.success,
                  ),
                  const SizedBox(width: 8.0),
                  AppBadge(
                    label: '${_reportSummary!.menungguCount} menunggu',
                    variant: AppBadgeVariant.warning,
                  ),
                  const SizedBox(width: 8.0),
                  AppBadge(
                    label: '${_reportSummary!.batalCount} batal',
                    variant: AppBadgeVariant.danger,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 5. Revenue Bar Chart Card
              WeeklyBarChartCard(
                title: _reportSummary!.chartTitle,
                badgeText: _reportSummary!.formattedRevenueText,
                values: _reportSummary!.chartValues,
                valueLabels: _reportSummary!.chartValueLabels,
                dayLabels: _reportSummary!.chartLabels,
                dateRangeText: _reportSummary!.chartDateRangeText,
              ),
              const SizedBox(height: 16.0),

              // 6. Popular Courts Header
              Text(
                'Lapangan paling populer',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),

              // 7. Popular Courts Card List
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  border: Border.all(
                    color: colors.borderDefault,
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(32, 40, 32, 0.03),
                      blurRadius: 16.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: _reportSummary!.popularCourts.isEmpty
                    ? Text(
                        'Belum ada booking dibayar pada rentang ini.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13.0,
                          color: colors.textSecondary,
                        ),
                      )
                    : Column(
                        children: List.generate(
                          _reportSummary!.popularCourts.length,
                          (index) {
                            final item = _reportSummary!.popularCourts[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index <
                                        _reportSummary!.popularCourts.length - 1
                                    ? 14.0
                                    : 0.0,
                              ),
                              child: AppInfoRow(
                                label: item.courtName,
                                value: item.formattedRowText,
                                labelColor: colors.textSecondary,
                                valueColor: colors.textPrimary,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 16.0),

              // 8. Footer Note
              Text(
                'Data per $todayFormatted. Pendapatan hanya dari booking dibayar, tidak termasuk biaya layanan dan booking dibatalkan.',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
