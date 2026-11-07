import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Reusable SportChip widget for shortcut categories
class SportChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const SportChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final border = colors.borderDefault;
    final surfaceColor =
        colors.surfaceCard;
    final textPrimary =
        colors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppTheme.shortcutBoxSize,
            height: AppTheme.shortcutBoxSize,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(color: border, width: 1.0),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: AppTheme.iconSizeLarge,
                height: AppTheme.iconSizeLarge,
                colorFilter: ColorFilter.mode(
                  textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall - 1.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
