import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import 'app_badge.dart';

/// Reusable Admin Booking Card widget for Dashboard and Booking Management screens.
class AdminBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetail;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const AdminBookingCard({
    super.key,
    required this.booking,
    required this.onViewDetail,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

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

    final isBelumBayar = booking.status == BookingStatus.belumBayar;
    final isSudahBayar = booking.status == BookingStatus.sudahBayar;

    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Booking Code & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                booking.bookingCode,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 10.0,
                  color: colors.textSecondary,
                ),
              ),
              AppBadge(
                label: badgeLabel,
                variant: badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Court Name
          Text(
            booking.courtName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),

          // Customer Name (1 line with ellipsis)
          Text(
            booking.userName ?? 'Pemesan',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.0,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),

          // Date & Time Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    fontSize: 11.0,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Bottom Row: Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Total Payment
              Text(
                booking.formattedTotalPayment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBelumBayar && onCancel != null) ...[
                    InkWell(
                      onTap: onCancel,
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text(
                          'Batalkan',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: colors.successForeground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  if (isSudahBayar && onReschedule != null) ...[
                    InkWell(
                      onTap: onReschedule,
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text(
                          'Ubah Jadwal',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  InkWell(
                    onTap: onViewDetail,
                    borderRadius: BorderRadius.circular(4.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Text(
                        'Lihat Detail →',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: colors.successForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
