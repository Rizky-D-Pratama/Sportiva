import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable row component for displaying key-value pairs (e.g. Tanggal, Waktu, Subtotal)
class AppInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final Color? labelColor;
  final Color? valueColor;

  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final effectiveLabelColor = labelColor ?? colors.textSecondary;
    final effectiveValueColor = valueColor ?? colors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: effectiveLabelColor,
              fontSize: 12.0,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: effectiveValueColor,
            fontSize: 12.0,
            fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
