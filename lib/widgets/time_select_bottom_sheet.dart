import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for selecting booking start time ("Jam mulai")
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

  bool _isHourUnavailable(int hour) {
    // 1. Check if past time for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    if (isToday && hour <= now.hour) {
      return true;
    }

    // 2. Check overlap with unavailable time slots
    for (final slot in unavailableSlots) {
      if (hour >= slot.startHour && hour < slot.endHour) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBg = colors.surfaceCard;
    final textPrimary =
        colors.textPrimary;
    final textSecondary =
        colors.textSecondary;
    final borderColor =
        colors.borderDefault;

    final List<int> hours = [];
    for (int h = AppConstants.operationalStartHour;
        h < AppConstants.operationalEndHour;
        h++) {
      hours.add(h);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih jam mulai',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(100.0),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      AppIcons.cross,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: ColorFilter.mode(
                        textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Time Slots List
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: hours.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                itemBuilder: (context, index) {
                  final hour = hours[index];
                  final isUnavailable = _isHourUnavailable(hour);
                  final formattedHour =
                      hour < 10 ? '0$hour.00 WIB' : '$hour.00 WIB';

                  return InkWell(
                    onTap: isUnavailable
                        ? null
                        : () {
                            onTimeSelected(hour);
                            Navigator.of(context).pop();
                          },
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 44.0,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isUnavailable
                            ? borderColor.withValues(alpha: 0.3)
                            : cardBg,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: borderColor,
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedHour,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isUnavailable
                                  ? textSecondary.withValues(alpha: 0.4)
                                  : textPrimary,
                              fontWeight: isUnavailable
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                          ),
                          if (isUnavailable)
                            Text(
                              'Tidak tersedia',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: textSecondary.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
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
