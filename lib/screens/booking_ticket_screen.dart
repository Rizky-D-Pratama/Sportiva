import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_icons.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/date_format_helper.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_image.dart';
import '../widgets/app_info_notice.dart';
import '../widgets/app_info_row.dart';
import '../widgets/app_sticky_bottom_bar.dart';

/// Screen for displaying the Booking Ticket with real QR code
class BookingTicketScreen extends StatelessWidget {
  final Booking booking;

  const BookingTicketScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final courtImage = (booking.courtImageUrl != null && booking.courtImageUrl!.isNotEmpty)
        ? booking.courtImageUrl!
        : DateFormatHelper.getCategoryImageUrl('');
    final ticketDateText = (booking.ticketDateText != null && booking.ticketDateText!.isNotEmpty)
        ? booking.ticketDateText!
        : (booking.date.isNotEmpty ? booking.date : '-');
    final userNameText = (booking.userName != null && booking.userName!.isNotEmpty)
        ? booking.userName!
        : '-';
    final venueNameText = booking.venueName.isNotEmpty ? booking.venueName : '-';
    final timeFormatted = '${booking.timeRange} • ${booking.durationHours} jam';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: 12.0,
              ),
              child: AppHeader(
                title: 'Tiket Booking',
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
                    // Ticket Card
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
                          // Court Photography Header
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 135.0,
                              child: AppImage(
                                imagePath: courtImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Court Title & Venue
                          Text(
                            booking.courtName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 22.0,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            venueNameText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Ticket details
                          AppInfoRow(
                            label: 'Nomor booking',
                            value: booking.bookingCode,
                            isBoldValue: true,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Pemesan',
                            value: userNameText,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Tanggal',
                            value: ticketDateText,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Waktu',
                            value: timeFormatted,
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Total dibayar',
                            value: booking.formattedTotalPayment,
                            isBoldValue: true,
                          ),
                          const SizedBox(height: 16.0),

                          // Ticket Perforation (Divider)
                          Divider(color: colors.borderDefault, height: 1.0),
                          const SizedBox(height: 16.0),

                          // QR Code Container (Always black QR on white background for scanner readability)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: QrImageView(
                                data: booking.bookingCode,
                                version: QrVersions.auto,
                                size: 145.0,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Information Notice Box
                    const AppInfoNotice(
                      message:
                          'Tunjukkan tiket kepada petugas. Datang 15 menit sebelum jadwal bermain.',
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),

            // Sticky actions ("Simpan Tiket")
            AppStickyBottomBar(
              child: AppButton(
                label: 'Simpan Tiket',
                variant: AppButtonVariant.secondary,
                leadingIconPath: AppIcons.download,
                onPressed: () {
                  // No-op (read-only UI per instructions)
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
