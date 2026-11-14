import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Kolom berlabel: label di atas, kotak berborder di bawah.
/// - Read-only / Custom child: isi [child] saja.
/// - Bisa diketuk: isi [onTap] dan biasanya [trailingIconPath].
/// - Input Teks: isi [controller], [hintText], [keyboardType], dll. (tanpa [child]).
/// [enabled] false = tampil nonaktif dan tidak bisa diketuk.
class AppField extends StatelessWidget {
  final String label;
  final Widget? child;
  final String? trailingIconPath;
  final VoidCallback? onTap;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final Widget? trailingWidget;
  final VoidCallback? onTrailingTap;

  // Text input properties (when child is omitted)
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const AppField({
    super.key,
    required this.label,
    this.child,
    this.trailingIconPath,
    this.onTap,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.trailingWidget,
    this.onTrailingTap,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.readOnly = false,
    this.onChanged,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppTheme.borderRadiusSmall);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError
        ? colors.dangerForeground
        : (enabled ? colors.borderDefault : colors.neutralBackground);

    final Widget contentWidget = child ??
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            counterText: '',
          ),
        );

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
            side: BorderSide(
              color: borderColor,
              width: hasError ? 1.5 : 1.0,
            ),
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
                        child: contentWidget,
                      ),
                    ),
                    if (trailingWidget != null) ...[
                      const SizedBox(width: AppTheme.paddingSmall),
                      trailingWidget!,
                    ] else if (trailingIconPath != null) ...[
                      const SizedBox(width: AppTheme.paddingSmall),
                      InkWell(
                        onTap: onTrailingTap ?? (enabled ? onTap : null),
                        borderRadius: BorderRadius.circular(100.0),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SvgPicture.asset(
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
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4.0),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.dangerForeground,
              fontSize: 10.0,
            ),
          ),
        ] else if (helperText != null && helperText!.isNotEmpty) ...[
          const SizedBox(height: 4.0),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 10.0,
            ),
          ),
        ],
      ],
    );
  }
}
