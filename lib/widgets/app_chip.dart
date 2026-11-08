import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppChipSize { regular, compact }

/// Chip pilihan (terpilih / tidak). Dipakai di sheet filter dan filter daftar.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppChipSize size;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = AppChipSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final compact = size == AppChipSize.compact;
    final radius = BorderRadius.circular(AppTheme.borderRadiusExtraSmall);

    final textColor = isSelected ? colors.successForeground : colors.textPrimary;
    final baseStyle = compact
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.titleSmall;

    return Material(
      color: isSelected ? colors.successBackground : colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isSelected ? colors.brandPrimary : colors.borderDefault,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
            compact ? AppTheme.chipHeightCompact : AppTheme.chipHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
            ),
            child: Center(
              widthFactor: 1.0,
              child: Text(label, style: baseStyle?.copyWith(color: textColor)),
            ),
          ),
        ),
      ),
    );
  }
}