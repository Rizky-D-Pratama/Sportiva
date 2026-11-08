import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable App Header matching Figma component "Sportiva / App Header" (520:2597)
class AppHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Widget? action;

  const AppHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return SizedBox(
      height: 56.0,
      child: Row(
        children: [
          if (showBackButton) ...[
            InkWell(
              onTap: onBackTap ?? () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(100.0),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                child: SvgPicture.asset(
                  AppIcons.arrowLeft,
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    colors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...[action!],
        ],
      ),
    );
  }
}
