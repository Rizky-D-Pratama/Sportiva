import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/app_menu_tile.dart';

/// Screen for Account Info & Security ("Akun")
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final user = MockData.currentUser;
    final phoneText = (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
        ? user.phoneNumber!
        : 'Belum ditambahkan';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppTheme.paddingXLarge,
            12.0,
            AppTheme.paddingXLarge,
            32.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Header
              const AppHeader(
                title: 'Akun',
                showBackButton: true,
              ),
              const SizedBox(height: 24.0),

              // 2. Informasi pribadi Section
              Text(
                'Informasi pribadi',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                  border: Border.all(color: colors.borderDefault, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(32, 40, 32, 0.03),
                      blurRadius: 16.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AppMenuTile(
                      iconPath: AppIcons.account,
                      caption: 'Nama',
                      label: user.name,
                      valueFontWeight: FontWeight.w500,
                      showChevron: true,
                      onTap: () {
                        // Belum ada layar edit nama
                      },
                    ),
                    AppMenuTile(
                      iconPath: AppIcons.phone,
                      caption: 'Nomor telepon',
                      label: phoneText,
                      valueFontWeight: FontWeight.w500,
                      showChevron: true,
                      onTap: () {
                        // Belum ada layar edit telepon
                      },
                    ),
                    AppMenuTile(
                      iconPath: AppIcons.mail,
                      caption: 'Email',
                      label: user.email,
                      valueFontWeight: FontWeight.w500,
                      showChevron: false,
                      onTap: () {
                        // Email tidak dapat diubah
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // 3. Keamanan Section
              Text(
                'Keamanan',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),
              _buildChangePasswordCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Material(
      color: colors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(color: colors.borderDefault, width: 1.0),
      ),
      child: InkWell(
        onTap: () {
          // Belum ada layar ubah password
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76.0),
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            children: [
              SvgPicture.asset(
                AppIcons.lockKeyhole,
                width: AppTheme.iconSizeMedium,
                height: AppTheme.iconSizeMedium,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ubah Password',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Kelola password untuk keamanan akun.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              SvgPicture.asset(
                AppIcons.chevronRight,
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
