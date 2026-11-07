import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Reusable CategoryFilterChip widget for sport category filters on CourtScreen
class CategoryFilterChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final borderDefault =
        colors.borderDefault;
    final primaryColor =
        colors.brandPrimary;
    final cardBg = colors.surfaceCard;
    final successBg = colors.successBackground;
    final successFg =
        colors.successForeground;
    final textPrimary =
        colors.textPrimary;

    final bgColor = isSelected ? successBg : cardBg;
    final borderColor = isSelected ? primaryColor : borderDefault;
    final fgColor = isSelected ? successFg : textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        height: 72.0,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: AppTheme.iconSizeLarge,
              height: AppTheme.iconSizeLarge,
              colorFilter: ColorFilter.mode(
                fgColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 7.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
