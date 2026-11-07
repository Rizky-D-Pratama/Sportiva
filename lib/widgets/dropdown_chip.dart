import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable DropdownChip for filter buttons (Rentang harga, Rating)
class DropdownChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const DropdownChip({
    super.key,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final borderDefault =
        customColors?.borderDefault ?? theme.colorScheme.outline;
    final primaryColor =
        customColors?.activeIndicator ?? theme.colorScheme.secondary;
    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final successBg = customColors?.bannerBackground ??
        theme.colorScheme.primaryContainer;
    final successFg =
        customColors?.successForeground ?? theme.colorScheme.primary;
    final textPrimary =
        customColors?.textPrimary ?? theme.colorScheme.onSurface;

    final bgColor = isActive ? successBg : cardBg;
    final borderColor = isActive ? primaryColor : borderDefault;
    final fgColor = isActive ? successFg : textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4.0),
            SvgPicture.asset(
              AppIcons.chevronDown,
              width: 12.0,
              height: 12.0,
              colorFilter: ColorFilter.mode(
                fgColor,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
