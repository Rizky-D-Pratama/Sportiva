import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_format_helper.dart';
import 'app_bottom_sheet.dart';
import 'app_calendar.dart';
import 'sheet_action_buttons.dart';

/// Opens the date range picker bottom sheet for Admin Reports.
Future<void> showReportDateRangeBottomSheet({
  required BuildContext context,
  required DateTimeRange initialRange,
  required ValueChanged<DateTimeRange> onApplied,
}) {
  return showAppBottomSheet(
    context: context,
    builder: (context) => ReportDateRangeBottomSheet(
      initialRange: initialRange,
      onApplied: onApplied,
    ),
  );
}

/// Content for Admin Report Date Range bottom sheet.
class ReportDateRangeBottomSheet extends StatefulWidget {
  final DateTimeRange initialRange;
  final ValueChanged<DateTimeRange> onApplied;

  const ReportDateRangeBottomSheet({
    super.key,
    required this.initialRange,
    required this.onApplied,
  });

  @override
  State<ReportDateRangeBottomSheet> createState() =>
      _ReportDateRangeBottomSheetState();
}

class _ReportDateRangeBottomSheetState
    extends State<ReportDateRangeBottomSheet> {
  late DateTimeRange _tempRange;

  @override
  void initState() {
    super.initState();
    _tempRange = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final rangeText = DateFormatHelper.formatDateRangeInputText(
      _tempRange.start,
      _tempRange.end,
    );

    return AppBottomSheet(
      title: 'Rentang tanggal',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Range Preview Label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceControl,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              border: Border.all(color: colors.borderDefault),
            ),
            child: Text(
              rangeText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Ketuk tanggal awal, lalu tanggal akhir. Untuk satu hari saja, ketuk satu tanggal lalu Terapkan.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0),
          // AppCalendar in Range Mode
          AppCalendar(
            isRangeMode: true,
            selectedRange: _tempRange,
            maxDate: today,
            maxRangeDays: 180,
            onRangeSelected: (newRange) {
              setState(() {
                _tempRange = newRange;
              });
            },
          ),
          const SizedBox(height: 16.0),

          // Action Buttons: Reset & Terapkan
          SheetActionButtons(
            resetLabel: 'Reset',
            applyLabel: 'Terapkan',
            onReset: () {
              setState(() {
                _tempRange = DateTimeRange(
                  start: startOfMonth,
                  end: endOfMonth,
                );
              });
            },
            onApply: () {
              widget.onApplied(_tempRange);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
