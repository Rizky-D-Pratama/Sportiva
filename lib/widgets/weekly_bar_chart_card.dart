import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_badge.dart';

/// Reusable weekly bar chart card component for Dashboard and Reports.
class WeeklyBarChartCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final List<double> values;
  final List<String> valueLabels;
  final List<String> dayLabels;
  final String dateRangeText;
  final double maxBarHeight;

  const WeeklyBarChartCard({
    super.key,
    required this.title,
    required this.badgeText,
    required this.values,
    required this.valueLabels,
    this.dayLabels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    required this.dateRangeText,
    this.maxBarHeight = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final maxValue = values.isEmpty ? 0.0 : values.reduce(max);

    return Container(
      padding: const EdgeInsets.all(12.0),
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
          // Header Row: Title & Summary Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              AppBadge(
                label: badgeText,
                variant: AppBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 7 Weekly Bars Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              min(7, values.length),
              (index) {
                final val = values[index];
                final valLabel = index < valueLabels.length ? valueLabels[index] : val.toInt().toString();
                final dayLabel = index < dayLabels.length ? dayLabels[index] : '';
                final isHighest = maxValue > 0 && val == maxValue;

                // Calculate bar height proportionally
                final double barHeight = maxValue > 0
                    ? max(4.0, (val / maxValue) * maxBarHeight)
                    : 4.0;

                final barColor = isHighest
                    ? colors.brandPrimary
                    : colors.successBackground;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Value label above bar
                      Text(
                        valLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),

                      // Bar container
                      Container(
                        width: 22.0,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      const SizedBox(height: 4.0),

                      // Day label below bar
                      Text(
                        dayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),

          // Date range caption at the bottom
          Text(
            dateRangeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
