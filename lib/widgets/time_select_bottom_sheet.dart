import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';

/// Bottom sheet untuk memilih jam mulai booking ("Jam mulai").
class TimeSelectBottomSheet extends StatelessWidget {
  final DateTime selectedDate;
  final List<UnavailableTimeSlot> unavailableSlots;
  final ValueChanged<int> onTimeSelected;

  const TimeSelectBottomSheet({
    super.key,
    required this.selectedDate,
    required this.unavailableSlots,
    required this.onTimeSelected,
  });

  // TODO: ketersediaan jam nanti dihitung di server.
  bool _isHourUnavailable(int hour) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    if (isToday && hour <= now.hour) return true;

    for (final slot in unavailableSlots) {
      if (hour >= slot.startHour && hour < slot.endHour) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hours = [
      for (int h = AppConstants.operationalStartHour;
      h < AppConstants.operationalEndHour;
      h++)
        h,
    ];

    return AppBottomSheet(
      title: 'Pilih jam mulai',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: hours.length,
          separatorBuilder: (context, index) =>
          const SizedBox(height: AppTheme.paddingSmall),
          itemBuilder: (context, index) {
            final hour = hours[index];
            return _TimeSlotRow(
              label: '${hour.toString().padLeft(2, '0')}.00 WIB',
              isUnavailable: _isHourUnavailable(hour),
              onTap: () {
                onTimeSelected(hour);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final String label;
  final bool isUnavailable;
  final VoidCallback onTap;

  const _TimeSlotRow({
    required this.label,
    required this.isUnavailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppTheme.borderRadiusExtraSmall);

    return Material(
      color: isUnavailable ? colors.neutralBackground : colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.borderDefault),
      ),
      child: InkWell(
        onTap: isUnavailable ? null : onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTheme.chipHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingLarge,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isUnavailable
                        ? colors.neutralForeground
                        : colors.textPrimary,
                    fontWeight:
                    isUnavailable ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                if (isUnavailable)
                  Text(
                    'Tidak tersedia',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.neutralForeground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}