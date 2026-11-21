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
import 'booking_detail_screen.dart';
import 'booking_history_screen.dart';
import 'booking_ticket_screen.dart';

/// Screen for Pesanan (Order) & Riwayat (History) tab
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  String _selectedFilter = 'Semua';
  List<Booking> _bookings = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  /// Public method to trigger reloading from MainShell
  Future<void> reloadBookings() async {
    return _fetchBookings();
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
    // Sort active bookings by closest play date/time (ascending)
    _bookings.sort((a, b) => a.playDateTime.compareTo(b.playDateTime));
  }

  List<Booking> get _displayedBookings {
    if (_selectedFilter == 'Belum bayar') {
      return _bookings
          .where((b) => b.status == BookingStatus.belumBayar)
          .toList();
    } else if (_selectedFilter == 'Sudah bayar') {
      return _bookings
          .where((b) => b.status == BookingStatus.sudahBayar)
          .toList();
    }
    // 'Semua' - shows active bookings (belumBayar and sudahBayar)
    return _bookings
        .where((b) =>
            b.status == BookingStatus.belumBayar ||
            b.status == BookingStatus.sudahBayar)
        .toList();
  }

  void _cancelBooking(Booking booking) {
    // TODO: irisan 6
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

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingXLarge,
          vertical: AppTheme.paddingSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            const AppHeader(
              title: 'Pesanan',
              showNotificationBell: true,
            ),
            const SizedBox(height: 16.0),

            // Filter pembayaran chips
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
                const SizedBox(width: 6.0),
                Expanded(
                  child: AppChip(
                    label: 'Belum bayar',
                    isSelected: _selectedFilter == 'Belum bayar',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Belum bayar';
                      });
                    },
                    size: AppChipSize.compact,
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: AppChip(
                    label: 'Sudah bayar',
                    isSelected: _selectedFilter == 'Sudah bayar',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Sudah bayar';
                      });
                    },
                    size: AppChipSize.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan aktif',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${displayed.length} pesanan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Booking List / Loading / Error / Empty Content
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
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'Belum ada pesanan aktif.',
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
                  return _buildBookingCard(context, booking);
                },
              ),
            const SizedBox(height: 16.0),

            // Booking History Card ("Riwayat Booking")
            _buildHistoryCard(context),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isUnpaid = booking.status == BookingStatus.belumBayar;

    return GestureDetector(
      onTap: !isUnpaid
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetailScreen(booking: booking),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: colors.borderDefault, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(32, 40, 32, 0.03),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan booking (Top Section)
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: Kode booking & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.bookingCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10.0,
                        ),
                      ),
                      AppBadge(
                        label: isUnpaid ? 'Belum Bayar' : 'Sudah Bayar',
                        variant: isUnpaid
                            ? AppBadgeVariant.warning
                            : AppBadgeVariant.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9.0),

                  // Nama lapangan
                  Text(
                    booking.courtName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 9.0),

                  // Tanggal dan jam
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
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9.0),

                  // Total & Label / Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.formattedTotalPayment,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isUnpaid)
                        Text(
                          'Total pembayaran',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.0,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingTicketScreen(booking: booking),
                              ),
                            );
                          },
                          child: Text(
                            'Lihat tiket →',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.successForeground,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Informasi pembayaran (Bottom Section)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.paddingLarge,
                0,
                AppTheme.paddingLarge,
                AppTheme.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: colors.borderDefault,
                    height: 1.0,
                  ),
                  const SizedBox(height: 12.0),
                  if (isUnpaid) ...[
                    // Row metode pembayaran
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.wallet,
                          width: 18.0,
                          height: 18.0,
                          colorFilter: ColorFilter.mode(
                            colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.paymentMethod ??
                                    'Belum memilih metode pembayaran',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textPrimary,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (booking.paymentDeadline != null) ...[
                                const SizedBox(height: 3.0),
                                Text(
                                  booking.paymentDeadline!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.warningForeground,
                                    fontSize: 10.0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // Action buttons for Belum Bayar
                    Column(
                      children: [
                        AppButton(
                          label: 'Lihat detail pembayaran',
                          onPressed: () {
                            // TODO: Lihat detail pembayaran / Snap (belum ada layar)
                          },
                          trailingIconPath: AppIcons.arrowRight,
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 44.0,
                          child: OutlinedButton(
                            onPressed: () => _cancelBooking(booking),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: colors.surfaceCard,
                              foregroundColor: colors.dangerForeground,
                              side: BorderSide(
                                color: colors.dangerForeground,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall,
                                ),
                              ),
                              textStyle: theme.textTheme.titleSmall?.copyWith(
                                color: colors.dangerForeground,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Row konfirmasi pembayaran (Sudah Bayar)
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.circleCheck,
                          width: 15.0,
                          height: 15.0,
                          colorFilter: ColorFilter.mode(
                            colors.successForeground,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Pembayaran diterima. Siap bermain!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.successForeground,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Material(
      color: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        side: BorderSide(color: colors.borderDefault, width: 1.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookingHistoryScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SvgPicture.asset(
                AppIcons.timePast,
                width: 20.0,
                height: 20.0,
                colorFilter: ColorFilter.mode(
                  colors.successForeground,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Booking',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.successForeground,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Lihat booking selesai atau dibatalkan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                AppIcons.chevronRight,
                width: 18.0,
                height: 18.0,
                colorFilter: ColorFilter.mode(
                  colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
