import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Availability Card Widget ("Ketersediaan lapangan")
class AvailabilityCard extends StatelessWidget {
  final bool isActive;
  final bool isEditMode;
  final ValueChanged<bool> onChanged;

  const AvailabilityCard({
    super.key,
    required this.isActive,
    required this.isEditMode,
    required this.onChanged,
  });

  String get _subtext {
    if (isActive) {
      return isEditMode
          ? 'Aktif · dapat dipesan pengguna'
          : 'Aktifkan saat lapangan siap dipesan';
    } else {
      return 'Nonaktif · tidak dapat dipesan pengguna';
    }
  }

  String get _operationalHoursText {
    final start = AppConstants.operationalStartHour.toString().padLeft(2, '0');
    final end = AppConstants.operationalEndHour.toString().padLeft(2, '0');
    return '$start.00 – $end.00';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title & Switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ketersediaan lapangan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _subtext,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.0,
                        color: colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Switch.adaptive(
                value: isActive,
                onChanged: onChanged,
                activeThumbColor: colors.surfaceCard,
                activeTrackColor: colors.brandPrimary,
                inactiveThumbColor: colors.surfaceCard,
                inactiveTrackColor: colors.borderDefault,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // Divider
          Divider(color: colors.borderDefault, height: 1.0, thickness: 1.0),
          const SizedBox(height: AppTheme.paddingMedium),

          // Operational Hours Read-Only Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jam operasional',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                _operationalHoursText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
