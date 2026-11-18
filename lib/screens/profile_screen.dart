import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user.dart';
import '../widgets/profile_content.dart';
import '../widgets/theme_select_bottom_sheet.dart';
import 'account_screen.dart';
import 'booking_history_screen.dart';

/// Screen for User Profile tab
class ProfileScreen extends StatelessWidget {
  final AuthRepository authRepository;

  ProfileScreen({
    super.key,
    AuthRepository? authRepository,
  }) : authRepository = authRepository ?? AppConfig.authRepository;

  @override
  Widget build(BuildContext context) {
    final user = authRepository.currentUser ??
        User(
          id: '',
          name: 'Pengguna',
          email: '',
          joinedDate: DateTime.now(),
        );

    return ProfileContentWidget(
      name: user.name,
      email: user.email,
      avatarPath: MockData.profilePhotoUrl,
      badgeLabel: MockData.formatJoinedDate(user.joinedDate),
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
                  user: user,
                  authRepository: authRepository,
                ),
              ),
            );
          },
        ),
        ProfileMenuTileItem(
          iconPath: AppIcons.timePast,
          label: 'Riwayat Booking',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryScreen(),
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
