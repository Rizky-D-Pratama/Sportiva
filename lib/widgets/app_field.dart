import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Kolom berlabel: label di atas, kotak berborder di bawah.
/// - Read-only: isi [child] saja.
/// - Bisa diketuk: isi [onTap] dan biasanya [trailingIconPath].
/// - Input: [child] berisi TextField.
/// [enabled] false = tampil nonaktif dan tidak bisa diketuk.
class AppField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? trailingIconPath;
  final VoidCallback? onTap;
  final bool enabled;

  const AppField({
    super.key,
    required this.label,
    required this.child,
    this.trailingIconPath,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppTheme.borderRadiusSmall);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Material(
          color: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: colors.borderDefault),
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppTheme.inputHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: colors.textPrimary,
                        ),
                        child: child,
                      ),
                    ),
                    if (trailingIconPath != null) ...[
                      const SizedBox(width: AppTheme.paddingSmall),
                      SvgPicture.asset(
                        trailingIconPath!,
                        width: AppTheme.iconSizeMedium,
                        height: AppTheme.iconSizeMedium,
                        colorFilter: ColorFilter.mode(
                          enabled
                              ? colors.textSecondary
                              : colors.neutralForeground,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}