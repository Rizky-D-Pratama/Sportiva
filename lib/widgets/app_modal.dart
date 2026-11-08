import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Reusable modal / dialog component matching Sportiva design system (Figma 151:632)
class AppModal extends StatelessWidget {
  final String? iconPath;
  final Color? iconColor;
  final String title;
  final String message;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  const AppModal({
    super.key,
    this.iconPath,
    this.iconColor,
    required this.title,
    required this.message,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  /// Static helper to display the modal dialog
  static Future<T?> show<T>({
    required BuildContext context,
    String? iconPath,
    Color? iconColor,
    required String title,
    required String message,
    required String primaryButtonLabel,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppModal(
        iconPath: iconPath,
        iconColor: iconColor,
        title: title,
        message: message,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final effectiveIconColor = iconColor ?? colors.dangerForeground;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: colors.borderDefault, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(32, 40, 32, 0.03),
              blurRadius: 16.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              SvgPicture.asset(
                iconPath!,
                width: 32.0,
                height: 32.0,
                colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 12.0),
            ],
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.0,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            AppButton(
              label: primaryButtonLabel,
              onPressed: onPrimaryPressed,
            ),
            if (secondaryButtonLabel != null) ...[
              const SizedBox(height: 8.0),
              AppButton(
                label: secondaryButtonLabel!,
                variant: AppButtonVariant.secondary,
                onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
