import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable AppCalendar widget for selecting a booking date
class AppCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const AppCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _displayedMonth;

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _dayHeaders = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final borderColor =
        customColors?.borderDefault ?? theme.colorScheme.outline;
    final textPrimary =
        customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary =
        customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;
    final primaryColor = theme.colorScheme.secondary;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(
      const Duration(days: AppConstants.maxAdvanceBookingDays),
    );

    final monthTitle =
        '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

    // Calendar grid calculations
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: borderColor, width: 0.88),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(32, 40, 32, 0.03),
            blurRadius: 14.0,
            offset: Offset(0, 3.5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Chevron Left, Month Year, Chevron Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _previousMonth,
                borderRadius: BorderRadius.circular(100.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    AppIcons.chevronLeft,
                    width: 14.0,
                    height: 14.0,
                    colorFilter: ColorFilter.mode(
                      textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Text(
                monthTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: _nextMonth,
                borderRadius: BorderRadius.circular(100.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    AppIcons.chevronRight,
                    width: 14.0,
                    height: 14.0,
                    colorFilter: ColorFilter.mode(
                      textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Day headers row
          Row(
            children: _dayHeaders.map((day) {
              return Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textSecondary,
                    fontSize: 8.0,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6.0),

          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startingWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox();
              }
              final dayNumber = index - startingWeekday + 1;
              final cellDate = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              final isSelectable =
                  !cellDate.isBefore(today) && !cellDate.isAfter(maxDate);
              final isSelected = _isSameDay(cellDate, widget.selectedDate);

              Color cellBg = Colors.transparent;
              Color textCol = textSecondary;

              if (isSelected) {
                cellBg = primaryColor;
                textCol = textPrimary;
              } else if (isSelectable) {
                textCol = textPrimary;
              } else {
                textCol = textSecondary.withValues(alpha: 0.35);
              }

              return InkWell(
                onTap: isSelectable
                    ? () {
                        widget.onDateSelected(cellDate);
                      }
                    : null,
                borderRadius: BorderRadius.circular(7.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cellBg,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textCol,
                      fontSize: 10.0,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
