import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_format_helper.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_image.dart';
import '../widgets/app_info_row.dart';
import '../widgets/app_sticky_bottom_bar.dart';
import 'booking_ticket_screen.dart';

/// Read-only Booking Detail Screen
class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  final bool isAdminView;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isSudahBayar = booking.status == BookingStatus.sudahBayar;

    final badgeLabel = switch (booking.status) {
      BookingStatus.sudahBayar => 'Sudah bayar',
      BookingStatus.selesai => 'Selesai',
      BookingStatus.dibatalkan => 'Dibatalkan',
      BookingStatus.belumBayar => 'Belum bayar',
    };

    final badgeVariant = switch (booking.status) {
      BookingStatus.sudahBayar || BookingStatus.selesai => AppBadgeVariant.success,
      BookingStatus.dibatalkan => AppBadgeVariant.danger,
      BookingStatus.belumBayar => AppBadgeVariant.warning,
    };

    final courtImage = (booking.courtImageUrl != null && booking.courtImageUrl!.isNotEmpty)
        ? booking.courtImageUrl!
        : DateFormatHelper.getCategoryImageUrl('');
    final facilitiesText = (booking.facilitiesText != null && booking.facilitiesText!.isNotEmpty)
        ? booking.facilitiesText!
        : '-';
    final fullDateText = (booking.fullDateText != null && booking.fullDateText!.isNotEmpty)
        ? booking.fullDateText!
        : (booking.date.isNotEmpty ? booking.date : '-');
    final createdDateText = (booking.createdDateText != null && booking.createdDateText!.isNotEmpty)
        ? booking.createdDateText!
        : '-';
    final userNameText = (booking.userName != null && booking.userName!.isNotEmpty)
        ? booking.userName!
        : '-';
    final userPhoneText = (booking.userPhone != null && booking.userPhone!.isNotEmpty)
        ? booking.userPhone!
        : '-';
    final userEmailText = (booking.userEmail != null && booking.userEmail!.isNotEmpty)
        ? booking.userEmail!
        : '-';
    final paymentMethodText = (booking.paymentMethod != null && booking.paymentMethod!.isNotEmpty)
        ? booking.paymentMethod!
        : 'Belum memilih metode pembayaran';

    final paidDateText = booking.paidAt != null
        ? DateFormatHelper.formatShortDateWithTime(booking.paidAt!)
        : '-';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingXLarge, vertical: 12.0),
              child: AppHeader(
                title: 'Detail Booking',
                showBackButton: true,
                onBackTap: () => Navigator.maybePop(context),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingXLarge,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Booking Info Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBadge(
                            label: badgeLabel,
                            variant: badgeVariant,
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            booking.bookingCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          AppInfoRow(
                            label: 'Dibuat',
                            value: createdDateText,
                          ),
                          const SizedBox(height: 4.0),
                          AppInfoRow(
                            label: 'Dibayar',
                            value: paidDateText,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Lapangan Info Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: SizedBox(
                              width: 76.0,
                              height: 80.0,
                              child: AppImage(
                                imagePath: courtImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.courtName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  facilitiesText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 10.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${Booking.formatPrice(booking.pricePerHour)}/jam',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 3. Jadwal & pemesan Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal & pemesan',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Tanggal',
                            value: fullDateText,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Waktu',
                            value: booking.timeRange,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Durasi',
                            value: '${booking.durationHours} jam',
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Nama pemesan',
                            value: userNameText,
                          ),
                          if (isAdminView) ...[
                            const SizedBox(height: 12.0),
                            AppInfoRow(
                              label: 'Email',
                              value: userEmailText,
                            ),
                          ],
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Nomor telepon',
                            value: userPhoneText,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 4. Rincian biaya Card
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian biaya',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Metode pembayaran',
                            value: paymentMethodText,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Harga per jam',
                            value: Booking.formatPrice(booking.pricePerHour),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Durasi',
                            value: '${booking.durationHours} jam × ${Booking.formatPrice(booking.pricePerHour)}',
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Subtotal',
                            value: Booking.formatPrice(booking.subtotal),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Biaya layanan',
                            value: Booking.formatPrice(booking.serviceFee),
                          ),
                          const SizedBox(height: 12.0),
                          Divider(color: colors.borderDefault, height: 1.0),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Total pembayaran',
                            value: booking.formattedTotalPayment,
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky actions for Sudah Bayar status ONLY in User View
            if (isSudahBayar && !isAdminView)
              AppStickyBottomBar(
                child: AppButton(
                  label: 'Lihat Tiket Booking',
                  leadingIconPath: AppIcons.ticket,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingTicketScreen(booking: booking),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
