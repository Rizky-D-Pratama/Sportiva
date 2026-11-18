import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_icons.dart';
import '../../data/mock_data.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/user.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/profile_content.dart';
import '../../widgets/theme_select_bottom_sheet.dart';
import '../account_screen.dart';
import '../notification_screen.dart';

/// Admin Profile screen tab for Admin shell
class AdminProfileScreen extends StatelessWidget {
  final AuthRepository authRepository;

  AdminProfileScreen({
    super.key,
    AuthRepository? authRepository,
  }) : authRepository = authRepository ?? AppConfig.authRepository;

  @override
  Widget build(BuildContext context) {
    final adminUser = authRepository.currentUser ??
        User(
          id: '',
          name: 'Admin',
          email: '',
          joinedDate: DateTime.now(),
          role: UserRole.admin,
        );

    return ProfileContentWidget(
      name: adminUser.name,
      email: adminUser.email,
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
                builder: (context) => AccountScreen(
                  user: adminUser,
                  authRepository: authRepository,
                ),
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
            ProfileContentWidget.showLogoutModal(
              context,
              authRepository: authRepository,
            );
          },
        ),
      ],
    );
  }
}
