import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable AppCalendar widget supporting single date selection and range date selection.
class AppCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  final bool isRangeMode;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange>? onRangeSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int maxRangeDays;

  const AppCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.isRangeMode = false,
    this.selectedRange,
    this.onRangeSelected,
    this.minDate,
    this.maxDate,
    this.maxRangeDays = 180,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _displayedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

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
    final initialRefDate = widget.isRangeMode
        ? (widget.selectedRange?.start ?? DateTime.now())
        : (widget.selectedDate ?? DateTime.now());

    _displayedMonth = DateTime(
      initialRefDate.year,
      initialRefDate.month,
      1,
    );

    if (widget.isRangeMode && widget.selectedRange != null) {
      _rangeStart = widget.selectedRange!.start;
      _rangeEnd = widget.selectedRange!.end;
    }
  }

  @override
  void didUpdateWidget(covariant AppCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRangeMode && widget.selectedRange != oldWidget.selectedRange) {
      final newStart = widget.selectedRange?.start;
      final newEnd = widget.selectedRange?.end;
      if (_rangeEnd == null && newStart == _rangeStart && newEnd == newStart) {
        // Preserve active start-date selection state while waiting for end-date tap
      } else {
        setState(() {
          _rangeStart = newStart;
          _rangeEnd = newEnd;
        });
      }
    }
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

  void _handleDateTap(DateTime cellDate) {
    if (!widget.isRangeMode) {
      widget.onDateSelected?.call(cellDate);
      return;
    }

    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = cellDate;
        _rangeEnd = null;
        widget.onRangeSelected?.call(DateTimeRange(start: cellDate, end: cellDate));
      } else {
        if (cellDate.isBefore(_rangeStart!)) {
          _rangeStart = cellDate;
          _rangeEnd = null;
          widget.onRangeSelected?.call(DateTimeRange(start: cellDate, end: cellDate));
        } else {
          DateTime endToSet = cellDate;
          final daysDiff = cellDate.difference(_rangeStart!).inDays + 1;
          if (daysDiff > widget.maxRangeDays) {
            endToSet = _rangeStart!.add(Duration(days: widget.maxRangeDays - 1));
          }
          _rangeEnd = endToSet;
          widget.onRangeSelected?.call(DateTimeRange(start: _rangeStart!, end: endToSet));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBg = colors.surfaceCard;
    final borderColor = colors.borderDefault;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final primaryColor = theme.colorScheme.primary;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final effectiveMinDate = widget.minDate ??
        (widget.isRangeMode
            ? null
            : today);
    final effectiveMaxDate = widget.maxDate ??
        (widget.isRangeMode
            ? today
            : today.add(const Duration(days: AppConstants.maxAdvanceBookingDays)));

    final monthTitle =
        '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

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

              final isBeforeMin = effectiveMinDate != null && cellDate.isBefore(effectiveMinDate);
              final isAfterMax = cellDate.isAfter(effectiveMaxDate);
              final isSelectable = !isBeforeMin && !isAfterMax;

              Color cellBg = Colors.transparent;
              Color textCol = textSecondary;
              FontWeight fontWeight = FontWeight.w400;

              if (widget.isRangeMode) {
                final isStart = _rangeStart != null && _isSameDay(cellDate, _rangeStart!);
                final isEnd = _rangeEnd != null && _isSameDay(cellDate, _rangeEnd!);
                final isInRange = _rangeStart != null &&
                    _rangeEnd != null &&
                    cellDate.isAfter(_rangeStart!) &&
                    cellDate.isBefore(_rangeEnd!);

                if (isStart || isEnd) {
                  cellBg = primaryColor;
                  textCol = textPrimary;
                  fontWeight = FontWeight.w600;
                } else if (isInRange) {
                  cellBg = colors.successBackground;
                  textCol = colors.successForeground;
                  fontWeight = FontWeight.w500;
                } else if (isSelectable) {
                  textCol = textPrimary;
                } else {
                  textCol = textSecondary.withValues(alpha: 0.35);
                }
              } else {
                final isSelected = widget.selectedDate != null &&
                    _isSameDay(cellDate, widget.selectedDate!);

                if (isSelected) {
                  cellBg = primaryColor;
                  textCol = textPrimary;
                  fontWeight = FontWeight.w600;
                } else if (isSelectable) {
                  textCol = textPrimary;
                } else {
                  textCol = textSecondary.withValues(alpha: 0.35);
                }
              }

              return InkWell(
                onTap: isSelectable ? () => _handleDateTap(cellDate) : null,
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
                      fontWeight: fontWeight,
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
