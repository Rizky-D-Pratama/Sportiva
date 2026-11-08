import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

enum AppBadgeVariant { success, warning, danger, neutral }

/// Badge berbentuk pil: status, fasilitas, atau penanda singkat lainnya.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final String? iconPath;

  const AppBadge({
    super.key,
    required this.label,
    required this.variant,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final (background, foreground) = switch (variant) {
      AppBadgeVariant.success => (colors.successBackground, colors.successForeground),
      AppBadgeVariant.warning => (colors.warningBackground, colors.warningForeground),
      AppBadgeVariant.danger => (colors.dangerBackground, colors.dangerForeground),
      AppBadgeVariant.neutral => (colors.neutralBackground, colors.neutralForeground),
    };

    return Container(
      padding: AppTheme.badgePadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null) ...[
            SvgPicture.asset(
              iconPath!,
              width: AppTheme.iconSizeSmall,
              height: AppTheme.iconSizeSmall,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
            const SizedBox(width: AppTheme.badgeIconGap),
          ],
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}