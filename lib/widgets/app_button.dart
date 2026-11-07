import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null = nonaktif
  final AppButtonVariant variant;
  final String? trailingIconPath;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.trailingIconPath,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final isPrimary = variant == AppButtonVariant.primary;

    final Color bg = isPrimary ? colors.brandPrimary : colors.surfaceControl;
    final Color fg = isPrimary ? colors.textOnPrimary : colors.textPrimary;
    final Color shownFg = enabled ? fg : colors.neutralForeground;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTheme.buttonHeight),
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: colors.neutralBackground,
        disabledForegroundColor: colors.neutralForeground,
        side: (!isPrimary && enabled)
            ? BorderSide(color: colors.borderDefault)
            : BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        textStyle: theme.textTheme.titleSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (trailingIconPath != null) ...[
            const SizedBox(width: AppTheme.paddingSmall),
            SvgPicture.asset(
              trailingIconPath!,
              width: AppTheme.iconSizeMedium,
              height: AppTheme.iconSizeMedium,
              colorFilter: ColorFilter.mode(shownFg, BlendMode.srcIn),
            ),
          ],
        ],
      ),
    );
  }
}