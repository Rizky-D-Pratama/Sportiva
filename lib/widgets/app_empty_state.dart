
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? illustration;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.illustration,
  }) : assert(icon != null || illustration != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ??
                Icon(
                  icon,
                  size: 72,
                  color: colors.textSecondary,
                ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: buttonText!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
