import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable information notice box component with green success background styling
class AppInfoNotice extends StatelessWidget {
  final String message;
  final String iconPath;

  const AppInfoNotice({
    super.key,
    required this.message,
    this.iconPath = AppIcons.circleCheck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.successBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 18.0,
            height: 18.0,
            colorFilter: ColorFilter.mode(
              colors.successForeground,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.successForeground,
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
