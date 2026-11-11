import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

/// Reusable SearchBarWidget based on Sportiva Search Bar component
class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBg = colors.surfaceCard;
    final borderColor =
        colors.borderDefault;
    final textSecondary =
        colors.textSecondary;
    final textPrimary =
        colors.textPrimary;

    return Container(
      height: 42.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: borderColor, width: 0.87),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.search,
            width: 18.0,
            height: 18.0,
            colorFilter: ColorFilter.mode(
              textSecondary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? MockData.searchPlaceholder,
                hintStyle: theme.textTheme.labelMedium?.copyWith(
                  color: textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
