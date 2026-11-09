import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu_tile.dart';
import '../widgets/app_modal.dart';
import '../widgets/theme_select_bottom_sheet.dart';

import 'account_screen.dart';
import 'booking_history_screen.dart';

/// Screen for User Profile tab
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final user = MockData.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingXLarge,
        vertical: AppTheme.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. App Header
          const AppHeader(
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
                imagePath: user.profilePhotoUrl,
                showCameraBadge: true,
                onCameraTap: () {},
              ),
              const SizedBox(height: 12.0),
              Text(
                user.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 23.0,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              AppBadge(
                label: MockData.formatJoinedDate(user.joinedDate),
                variant: AppBadgeVariant.success,
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
              children: [
                AppMenuTile(
                  iconPath: AppIcons.account,
                  label: 'Akun',
                  showChevron: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountScreen(),
                      ),
                    );
                  },
                ),
                AppMenuTile(
                  iconPath: AppIcons.timePast,
                  label: 'Riwayat Booking',
                  showChevron: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingHistoryScreen(),
                      ),
                    );
                  },
                ),
                AppMenuTile(
                  iconPath: AppIcons.moon,
                  label: 'Tampilan',
                  showChevron: true,
                  onTap: () {
                    showThemeSelectBottomSheet(context);
                  },
                ),
                AppMenuTile(
                  iconPath: AppIcons.questionMark,
                  label: 'Bantuan',
                  showChevron: true,
                  onTap: () {},
                ),
                AppMenuTile(
                  iconPath: AppIcons.logout,
                  label: 'Keluar',
                  isDanger: true,
                  showChevron: true,
                  onTap: () {
                    AppModal.show(
                      context: context,
                      iconPath: AppIcons.circleAlert,
                      iconColor: colors.dangerForeground,
                      title: 'Keluar dari akun?',
                      message:
                          'Anda akan keluar dari akun ini. Anda dapat masuk kembali kapan saja.',
                      primaryButtonLabel: 'Ya, Keluar',
                      onPrimaryPressed: () {},
                      secondaryButtonLabel: 'Kembali',
                      onSecondaryPressed: () => Navigator.pop(context),
                    );
                  },
                ),
              ],
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
