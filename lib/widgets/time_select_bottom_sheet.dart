import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';

/// Bottom sheet untuk memilih jam (mulai / selesai).
class TimeSelectBottomSheet extends StatelessWidget {
  final DateTime selectedDate;
  final List<UnavailableTimeSlot> unavailableSlots;
  final ValueChanged<int> onTimeSelected;
  final String title;
  final int minHour;
  final int maxHour;
  final int? restrictAfterHour; // If specified, only hours strictly AFTER this hour can be selected
  final bool allowCurrentHour; // If true (closure mode), current hour is allowed for today

  const TimeSelectBottomSheet({
    super.key,
    required this.selectedDate,
    required this.unavailableSlots,
    required this.onTimeSelected,
    this.title = 'Pilih jam mulai',
    this.minHour = AppConstants.operationalStartHour,
    this.maxHour = AppConstants.operationalEndHour,
    this.restrictAfterHour,
    this.allowCurrentHour = false,
  });

  bool _isHourUnavailable(int hour) {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final todayWib = DateTime(nowWib.year, nowWib.month, nowWib.day);
    final isToday = selectedDate.year == todayWib.year &&
        selectedDate.month == todayWib.month &&
        selectedDate.day == todayWib.day;

    if (restrictAfterHour != null && hour <= restrictAfterHour!) {
      return true;
    }

    if (isToday && restrictAfterHour == null) {
      if (allowCurrentHour) {
        if (hour < nowWib.hour) {
          return true;
        }
      } else {
        final slotStart = DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
        );
        if (slotStart.difference(nowWib).inMinutes < AppConstants.minBookingLeadTimeMinutes) {
          return true;
        }
      }
    }

    for (final slot in unavailableSlots) {
      if (hour >= slot.startHour && hour < slot.endHour) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hours = [
      for (int h = minHour; h <= maxHour; h++) h,
    ];

    return AppBottomSheet(
      title: title,
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
            final hourText = hour < 10 ? '0$hour.00 WIB' : '$hour.00 WIB';
            final isUnavailable = _isHourUnavailable(hour);

            return _TimeSlotRow(
              label: hourText,
              isUnavailable: isUnavailable,
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
