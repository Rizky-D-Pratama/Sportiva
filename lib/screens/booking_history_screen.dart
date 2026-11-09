import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_header.dart';
import '../widgets/app_star_rating.dart';
import '../widgets/give_rating_bottom_sheet.dart';

/// Screen for Riwayat Booking (Booking History)
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'Semua';
  late List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = List.from(MockData.mockBookings);
    _sortBookings();
  }

  void _sortBookings() {
    // Sort history bookings newest first (descending by playDateTime)
    _bookings.sort((a, b) => b.playDateTime.compareTo(a.playDateTime));
  }

  /// History list contains only finished (selesai) and cancelled (dibatalkan) bookings
  List<Booking> get _historyBookings {
    return _bookings.where((b) {
      return b.status == BookingStatus.selesai ||
          b.status == BookingStatus.dibatalkan;
    }).toList();
  }

  List<Booking> get _displayedBookings {
    final history = _historyBookings;
    if (_selectedFilter == 'Selesai') {
      return history
          .where((b) => b.status == BookingStatus.selesai)
          .toList();
    } else if (_selectedFilter == 'Batal') {
      return history
          .where((b) => b.status == BookingStatus.dibatalkan)
          .toList();
    }
    return history;
  }

  void _updateBookingRating(String bookingId, int rating) {
    setState(() {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(rating: rating);
        // Also update MockData in memory so it persists across screen re-opens
        final mockIndex = MockData.mockBookings.indexWhere((b) => b.id == bookingId);
        if (mockIndex != -1) {
          MockData.mockBookings[mockIndex] =
              MockData.mockBookings[mockIndex].copyWith(rating: rating);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final displayed = _displayedBookings;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppTheme.paddingXLarge,
            12.0,
            AppTheme.paddingXLarge,
            AppTheme.paddingXLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Header with back button and headlineMedium title (fontSize 20.0)
              AppHeader(
                title: 'Riwayat Booking',
                showBackButton: true,
                onBackTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 16.0),

              // 2. Status Filter Chips ("Semua", "Selesai", "Batal")
              Row(
                children: [
                  Expanded(
                    child: AppChip(
                      label: 'Semua',
                      isSelected: _selectedFilter == 'Semua',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Semua';
                        });
                      },
                      size: AppChipSize.compact,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AppChip(
                      label: 'Selesai',
                      isSelected: _selectedFilter == 'Selesai',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Selesai';
                        });
                      },
                      size: AppChipSize.compact,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AppChip(
                      label: 'Batal',
                      isSelected: _selectedFilter == 'Batal',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Batal';
                        });
                      },
                      size: AppChipSize.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 3. History List Cards
              if (displayed.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat booking.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayed.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16.0),
                  itemBuilder: (context, index) {
                    final booking = displayed[index];
                    return _buildHistoryCardItem(context, booking);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCardItem(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isFinished = booking.status == BookingStatus.selesai;
    final isCancelled = booking.status == BookingStatus.dibatalkan;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(32, 40, 32, 0.03),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Booking Code & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingCode,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              AppBadge(
                label: isFinished ? 'Selesai' : 'Dibatalkan',
                variant: isFinished
                    ? AppBadgeVariant.success
                    : AppBadgeVariant.danger,
              ),
            ],
          ),
          const SizedBox(height: 9.0),

          // Row 2: Court Name
          Text(
            booking.courtName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9.0),

          // Row 3: Calendar Icon + Date & Time
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.calendar,
                width: 14.0,
                height: 14.0,
                colorFilter: ColorFilter.mode(
                  colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  '${booking.date} • ${booking.timeRange}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9.0),

          // Row 4: Total Payment & Lihat Detail →
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.formattedTotalPayment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () {
                  // Link yet to be implemented
                },
                child: Text(
                  'Lihat Detail →',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.successForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Rating Section for Finished Bookings
          if (isFinished) ...[
            const SizedBox(height: 9.0),
            Divider(
              color: colors.borderDefault,
              height: 1.0,
            ),
            const SizedBox(height: 12.0),
            if (booking.rating == null) ...[
              // Selesai & Belum dinilai
              Text(
                'Bagaimana pengalaman bermainmu?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),
              AppButton(
                label: 'Beri penilaian',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  showGiveRatingBottomSheet(
                    context: context,
                    booking: booking,
                    onRatingSubmitted: (rating) {
                      _updateBookingRating(booking.id, rating);
                    },
                  );
                },
              ),
            ] else ...[
              // Selesai & Sudah dinilai
              Text(
                'Penilaianmu',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12.0),
              Center(
                child: AppStarRating(
                  rating: booking.rating!,
                  iconSize: 32.0,
                  gap: 12.0,
                ),
              ),
            ],
          ],

          // Cancelled Bookings have NO rating section
          if (isCancelled) const SizedBox.shrink(),
        ],
      ),
    );
  }
}
