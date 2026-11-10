import 'package:flutter/material.dart';
import '../../constants/app_icons.dart';
import '../../data/mock_data.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/profile_content.dart';
import '../../widgets/theme_select_bottom_sheet.dart';
import '../account_screen.dart';
import '../notification_screen.dart';

/// Admin Profile screen tab for Admin shell
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUser = MockData.adminUser;

    return ProfileContentWidget(
      name: MockData.adminFullName,
      email: MockData.adminEmail,
      avatarPath: MockData.profilePhotoUrl,
      badgeLabel: 'Admin',
      badgeVariant: AppBadgeVariant.success,
      onNotificationBellTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationScreen(),
          ),
        );
      },
      onCameraTap: () {},
      menuItems: [
        ProfileMenuTileItem(
          iconPath: AppIcons.account,
          label: 'Akun',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountScreen(user: adminUser),
              ),
            );
          },
        ),
        ProfileMenuTileItem(
          iconPath: AppIcons.moon,
          label: 'Tampilan',
          onTap: () {
            showThemeSelectBottomSheet(context);
          },
        ),
        ProfileMenuTileItem(
          iconPath: AppIcons.questionMark,
          label: 'Bantuan',
          onTap: () {},
        ),
        ProfileMenuTileItem(
          iconPath: AppIcons.logout,
          label: 'Keluar',
          isDanger: true,
          onTap: () {
            ProfileContentWidget.showLogoutModal(context);
          },
        ),
      ],
    );
  }
}
