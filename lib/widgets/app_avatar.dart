import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../constants/app_images.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

/// Reusable user profile Avatar widget with optional camera badge
class AppAvatar extends StatelessWidget {
  final double size;
  final String? imagePath;
  final bool showCameraBadge;
  final VoidCallback? onCameraTap;

  const AppAvatar({
    super.key,
    this.size = 88.0,
    this.imagePath,
    this.showCameraBadge = false,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final avatarWidget = ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: AppImage(
          imagePath: imagePath ?? AppImages.blankProfile,
          fit: BoxFit.cover,
          defaultFallback: AppImages.blankProfile,
        ),
      ),
    );

    if (!showCameraBadge) {
      return avatarWidget;
    }

    const badgeSize = 22.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarWidget,
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.borderDefault,
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(32, 40, 32, 0.08),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.camera,
                  width: 13.5,
                  height: 13.5,
                  colorFilter: ColorFilter.mode(
                    colors.brandPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
