import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../widgets/profile_content.dart';
import '../widgets/theme_select_bottom_sheet.dart';
import 'account_screen.dart';
import 'booking_history_screen.dart';

/// Screen for User Profile tab
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

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
                builder: (context) => const AccountScreen(),
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
            ProfileContentWidget.showLogoutModal(context);
          },
        ),
      ],
    );
  }
}
