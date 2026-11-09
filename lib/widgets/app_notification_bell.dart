import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../screens/notification_screen.dart';
import '../theme/app_theme.dart';

/// Reusable notification bell widget. Depends on [NotificationScreen].
class AppNotificationBell extends StatelessWidget {
  const AppNotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(100.0),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: SvgPicture.asset(
          AppIcons.bell,
          width: AppTheme.iconSizeMedium,
          height: AppTheme.iconSizeMedium,
          colorFilter: ColorFilter.mode(
            colors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
