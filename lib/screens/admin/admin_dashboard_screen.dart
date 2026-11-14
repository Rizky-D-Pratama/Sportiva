import 'package:flutter/material.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_images.dart';
import '../../data/court_repository.dart';
import '../../data/mock_data.dart';
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
  late List<Booking> _recentBookings;
  int _totalCourtsCount = MockData.mockAdminDashboardStats.totalCourtsCount;

  @override
  void initState() {
    super.initState();
    _recentBookings = List.from(MockData.mockAdminRecentBookings);
    _loadCourtCount();
  }

  Future<void> _loadCourtCount() async {
    final courts = await FakeCourtRepository().getAdminCourts();
    if (!mounted) return;
    setState(() {
      _totalCourtsCount = courts.length;
    });
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
        setState(() {
          final index = _recentBookings.indexWhere((b) => b.id == booking.id);
          if (index != -1) {
            _recentBookings[index] = _recentBookings[index].copyWith(
              status: BookingStatus.dibatalkan,
            );
          }
        });
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
      _loadCourtCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final now = DateTime.now();

    final stats = MockData.mockAdminDashboardStats;
    final monthName = DateFormatHelper.getMonthName(now.month);
    final fullDateStr = DateFormatHelper.formatFullDate(now);
    final weekRangeStr = DateFormatHelper.formatWeekRange(now);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                      'Halo, ${MockData.adminName}!',
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

          // 2. Stat Cards (2x2 Grid)
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  value: stats.totalBookingMonth.toString(),
                  label: 'Total Booking $monthName',
                  iconPath: AppIcons.calendarCheck,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: AdminStatCard(
                  value: stats.todayBookingCount.toString(),
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
                  value: _totalCourtsCount.toString(),
                  label: 'Total Lapangan',
                  iconPath: AppIcons.volleyball,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: AdminStatCard(
                  value: stats.formattedRevenueText,
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
            badgeText: '${stats.totalWeeklyBookings} Booking',
            values: stats.weeklyBookingCounts,
            valueLabels: stats.weeklyBookingCounts
                .map((v) => v.round().toString())
                .toList(),
            dayLabels: stats.weekDayLabels,
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
          Column(
            children: _recentBookings.map((booking) {
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
      ),
    );
  }
}
