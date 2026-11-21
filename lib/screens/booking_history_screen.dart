import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import '../constants/app_icons.dart';
import '../data/booking_repository.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_header.dart';
import '../widgets/app_star_rating.dart';
import 'booking_detail_screen.dart';

/// Screen for Riwayat Booking (Booking History)
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'Semua';
  List<Booking> _bookings = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await AppConfig.bookingRepository.getMyBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _sortBookings();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
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

  String get _errorMessage {
    if (_error is BookingNetworkException) {
      return 'Gagal memuat pesanan. Periksa jaringan internet Anda.';
    }
    return 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final displayed = _displayedBookings;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBookings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppTheme.paddingXLarge,
              12.0,
              AppTheme.paddingXLarge,
              AppTheme.paddingXLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Header with back button
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

                // 3. History List / Loading / Error / Empty Content
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (displayed.isEmpty)
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(booking: booking),
                    ),
                  );
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
                  // TODO: irisan penilaian
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
