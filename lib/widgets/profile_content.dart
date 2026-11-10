import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';
import 'app_avatar.dart';
import 'app_badge.dart';
import 'app_header.dart';
import 'app_menu_tile.dart';
import 'app_modal.dart';

/// Data class defining a menu tile entry for ProfileContentWidget.
class ProfileMenuTileItem {
  final String iconPath;
  final String label;
  final bool isDanger;
  final bool showChevron;
  final VoidCallback onTap;

  const ProfileMenuTileItem({
    required this.iconPath,
    required this.label,
    this.isDanger = false,
    this.showChevron = true,
    required this.onTap,
  });
}

/// Reusable profile screen content component shared between User and Admin profiles.
class ProfileContentWidget extends StatelessWidget {
  final String name;
  final String email;
  final String avatarPath;
  final String badgeLabel;
  final AppBadgeVariant badgeVariant;
  final List<ProfileMenuTileItem> menuItems;
  final VoidCallback? onNotificationBellTap;
  final VoidCallback? onCameraTap;

  const ProfileContentWidget({
    super.key,
    required this.name,
    required this.email,
    required this.avatarPath,
    required this.badgeLabel,
    this.badgeVariant = AppBadgeVariant.success,
    required this.menuItems,
    this.onNotificationBellTap,
    this.onCameraTap,
  });

  /// Static helper for showing standard sign-out confirmation modal
  static void showLogoutModal(BuildContext context) {
    final colors = context.appColors;
    AppModal.show(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: colors.dangerForeground,
      title: 'Keluar dari akun?',
      message:
          'Anda akan keluar dari akun ini. Anda dapat masuk kembali kapan saja.',
      primaryButtonLabel: 'Ya, Keluar',
      onPrimaryPressed: () {
        // TODO: Call server sign-out API.
        Navigator.pop(context); // Close modal first
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingXLarge,
        vertical: AppTheme.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. App Header
          AppHeader(
            title: 'Profil',
            showNotificationBell: true,
          ),
          const SizedBox(height: 16.0),

          // 2. Account Identity Block
          Column(
            children: [
              const SizedBox(height: 8.0),
              AppAvatar(
                size: 88.0,
                imagePath: avatarPath,
                showCameraBadge: true,
                onCameraTap: onCameraTap,
              ),
              const SizedBox(height: 12.0),
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 23.0,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              AppBadge(
                label: badgeLabel,
                variant: badgeVariant,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
          const SizedBox(height: 16.0),

          // 3. Menu Options Card
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: colors.borderDefault, width: 1.0),
            ),
            child: Column(
              children: menuItems.map((item) {
                return AppMenuTile(
                  iconPath: item.iconPath,
                  label: item.label,
                  isDanger: item.isDanger,
                  showChevron: item.showChevron,
                  onTap: item.onTap,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16.0),

          // 4. Footer
          Text(
            AppConstants.appTitleWithVersion,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
