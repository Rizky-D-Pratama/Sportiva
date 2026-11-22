import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

enum AppInfoNoticeVariant {
  success,
  danger,
}

/// Reusable information notice box component with success or danger styling
class AppInfoNotice extends StatelessWidget {
  final String message;
  final String? iconPath;
  final AppInfoNoticeVariant variant;

  const AppInfoNotice({
    super.key,
    required this.message,
    this.iconPath,
    this.variant = AppInfoNoticeVariant.success,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isDanger = variant == AppInfoNoticeVariant.danger;
    final bgColor = isDanger ? colors.dangerBackground : colors.successBackground;
    final fgColor = isDanger ? colors.dangerForeground : colors.successForeground;
    final effectiveIconPath = iconPath ?? (isDanger ? AppIcons.circleAlert : AppIcons.circleCheck);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            effectiveIconPath,
            width: 18.0,
            height: 18.0,
            colorFilter: ColorFilter.mode(
              fgColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: fgColor,
                fontSize: 11.0,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
