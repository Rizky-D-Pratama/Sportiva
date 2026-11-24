import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_images.dart';
import '../../data/booking_repository.dart';
import '../../data/mock_data.dart';
import '../../models/admin_dashboard_data.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/admin_booking_card.dart';
import '../../widgets/admin_stat_card.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_notification_bell.dart';
import '../../widgets/weekly_bar_chart_card.dart';
import '../booking_detail_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_court_form_screen.dart';
import 'admin_schedule_screen.dart';

/// Admin Dashboard Screen displaying greeting header, summary stat cards,
/// weekly booking chart, quick actions, and recent bookings.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminDashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AppConfig.bookingRepository.getAdminDashboard();
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } on BookingNetworkException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Koneksi terputus. Periksa jaringan internet Anda.';
        _isLoading = false;
      });
    } on BookingNotAdminException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Akun ini tidak memiliki akses admin.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        _isLoading = false;
      });
    }
  }

  void _showCancelConfirmationModal(Booking booking) {
    AppModal.show(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: context.appColors.dangerForeground,
      title: 'Batalkan Booking?',
      message: 'Booking pelanggan akan dibatalkan. Anda tidak dapat mengembalikannya.',
      primaryButtonLabel: 'Ya, Batalkan',
      onPrimaryPressed: () {
        Navigator.pop(context);
        // Tombol tetap tidak melakukan apa-apa (di luar lingkup 4a)
      },
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> _openAddCourtForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCourtFormScreen(),
      ),
    );

    if (result == true && mounted) {
      _fetchDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final now = DateTime.now();

    final monthName = DateFormatHelper.getMonthName(now.month);
    final fullDateStr = DateFormatHelper.formatFullDate(now);
    final weekRangeStr = DateFormatHelper.formatWeekRange(now);

    final data = _dashboardData;

    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      color: colors.successForeground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingXLarge,
          vertical: AppTheme.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Header (Greeting + Date + Bell)
            Row(
              children: [
                // Profile photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.0),
                  child: const SizedBox(
                    width: 44.0,
                    height: 44.0,
                    child: AppImage(
                      imagePath: MockData.profilePhotoUrl,
                      fit: BoxFit.cover,
                      defaultFallback: AppImages.blankProfile,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Greeting & Today's Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${(AppConfig.authRepository.currentUser?.name ?? 'Admin').split(' ').first}!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        fullDateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.0,
                          color: colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bell Notification Icon
                const AppNotificationBell(),
              ],
            ),
            const SizedBox(height: 16.0),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              )
            else if (data != null) ...[
              // 2. Stat Cards (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      value: data.totalBookingMonth.toString(),
                      label: 'Total Booking $monthName',
                      iconPath: AppIcons.calendarCheck,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AdminStatCard(
                      value: data.todayBookingCount.toString(),
                      label: 'Booking Hari Ini',
                      iconPath: AppIcons.calendar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: AdminStatCard(
                      value: data.totalCourtsCount.toString(),
                      label: 'Total Lapangan',
                      iconPath: AppIcons.volleyball,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AdminStatCard(
                      value: data.formattedRevenueText,
                      label: 'Pendapatan $monthName',
                      iconPath: AppIcons.wallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 3. Weekly Bar Chart Card
              WeeklyBarChartCard(
                title: 'Booking minggu ini',
                badgeText: '${data.totalWeeklyBookings} Booking',
                values: data.weeklyBookingCounts.map((v) => v.toDouble()).toList(),
                valueLabels: data.weeklyBookingCounts
                    .map((v) => v.toString())
                    .toList(),
                dayLabels: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
                dateRangeText: weekRangeStr,
              ),
              const SizedBox(height: 16.0),

              // 4. Quick Actions (Akses Cepat)
              Text(
                'Akses cepat',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  // Pill "+ Lapangan"
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openAddCourtForm,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
                      child: const AppBadge(
                        label: 'Lapangan',
                        iconPath: AppIcons.plus,
                        variant: AppBadgeVariant.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Pill "Atur jadwal"
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminScheduleScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
                      child: const AppBadge(
                        label: 'Atur jadwal',
                        variant: AppBadgeVariant.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 5. Recent Bookings Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Booking Terbaru',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminBookingsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Semua',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: colors.successForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // 6. Recent Bookings List
              if (data.recentBookings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Tidak ada booking',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: data.recentBookings.map((booking) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AdminBookingCard(
                        booking: booking,
                        onViewDetail: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailScreen(
                                booking: booking,
                                isAdminView: true,
                              ),
                            ),
                          );
                        },
                        onCancel: booking.status == BookingStatus.belumBayar
                            ? () => _showCancelConfirmationModal(booking)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
