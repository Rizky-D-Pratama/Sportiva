import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable menu item tile matching Figma component "Sportiva / Menu Item" (518:2011)
class AppMenuTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isDanger;
  final bool showChevron;
  final VoidCallback onTap;

  const AppMenuTile({
    super.key,
    required this.iconPath,
    required this.label,
    this.isDanger = false,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final foregroundColor =
        isDanger ? colors.dangerForeground : colors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        height: 56.0,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: AppTheme.iconSizeMedium,
              height: AppTheme.iconSizeMedium,
              colorFilter: ColorFilter.mode(
                foregroundColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showChevron)
              SvgPicture.asset(
                AppIcons.chevronRight,
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
