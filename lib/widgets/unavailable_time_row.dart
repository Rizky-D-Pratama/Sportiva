import 'package:flutter/material.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';
import 'app_badge.dart';

/// Reusable Widget for an unavailable time slot or closure row
class UnavailableTimeRow extends StatelessWidget {
  final String timeRangeText;
  final String statusLabel;
  final String note;
  final SlotStatusType statusType;
  final VoidCallback? onReopenTap;

  const UnavailableTimeRow({
    super.key,
    required this.timeRangeText,
    required this.statusLabel,
    required this.note,
    required this.statusType,
    this.onReopenTap,
  });

  factory UnavailableTimeRow.fromSlot({
    required UnavailableTimeSlot slot,
    VoidCallback? onReopenTap,
  }) {
    return UnavailableTimeRow(
      timeRangeText: slot.timeRangeShortText,
      statusLabel: slot.statusLabel,
      note: slot.note,
      statusType: slot.statusType,
      onReopenTap: onReopenTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    AppBadgeVariant badgeVariant;
    switch (statusType) {
      case SlotStatusType.booked:
        badgeVariant = AppBadgeVariant.danger;
        break;
      case SlotStatusType.onHold:
        badgeVariant = AppBadgeVariant.warning;
        break;
      case SlotStatusType.closed:
        badgeVariant = AppBadgeVariant.neutral;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Time Range & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                timeRangeText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              AppBadge(
                label: statusLabel,
                variant: badgeVariant,
              ),
            ],
          ),
          const SizedBox(height: 6.0),

          // Subtitle / Note Text
          Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 11.0,
            ),
          ),

          // Optional "Buka kembali" Secondary Button inside row
          if (onReopenTap != null) ...[
            const SizedBox(height: 10.0),
            InkWell(
              onTap: onReopenTap,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Container(
                width: double.infinity,
                height: 44.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  border: Border.all(color: colors.borderDefault, width: 1.0),
                ),
                child: Text(
                  'Buka kembali',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
