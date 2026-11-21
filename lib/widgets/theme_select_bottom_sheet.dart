import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'app_bottom_sheet.dart';

enum AppThemeModeOption { light, dark, system }

Future<void> showThemeSelectBottomSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    builder: (context) => const ThemeSelectBottomSheet(),
  );
}

/// Bottom Sheet content for selecting app display theme
class ThemeSelectBottomSheet extends StatelessWidget {
  const ThemeSelectBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final controller = ThemeControllerScope.of(context);

    final selectedOption = switch (controller.themeMode) {
      ThemeMode.light => AppThemeModeOption.light,
      ThemeMode.dark => AppThemeModeOption.dark,
      ThemeMode.system => AppThemeModeOption.system,
    };

    return AppBottomSheet(
      title: 'Tampilan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildThemePreviewCard(
                  context: context,
                  label: 'Light',
                  isSelected: selectedOption == AppThemeModeOption.light,
                  onTap: () {
                    controller.setThemeMode(ThemeMode.light);
                  },
                  bgColor: const Color(0xFFFFFDF1),
                  cardColor: Colors.white,
                  headingColor: const Color(0xFF697568),
                  descColor: const Color(0xFFDDE2D5),
                  accentColor: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildThemePreviewCard(
                  context: context,
                  label: 'Dark',
                  isSelected: selectedOption == AppThemeModeOption.dark,
                  onTap: () {
                    controller.setThemeMode(ThemeMode.dark);
                  },
                  bgColor: const Color(0xFF202820),
                  cardColor: const Color(0xFF343E34),
                  headingColor: const Color(0xFFDDE2D5),
                  descColor: const Color(0xFF697568),
                  accentColor: colors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildSystemOptionCard(
            context,
            isSelected: selectedOption == AppThemeModeOption.system,
            onTap: () {
              controller.setThemeMode(ThemeMode.system);
            },
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color bgColor,
    required Color cardColor,
    required Color headingColor,
    required Color descColor,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSelected ? colors.successBackground : colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? colors.brandPrimary : colors.borderDefault,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 88.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 47.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: headingColor,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: headingColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: BoxDecoration(
                            color: headingColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 45.0,
                              height: 4.0,
                              decoration: BoxDecoration(
                                color: headingColor,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Container(
                              width: 30.0,
                              height: 3.0,
                              decoration: BoxDecoration(
                                color: descColor,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  _buildSelectionIndicator(
                    context,
                    isSelected: isSelected,
                    size: 20.0,
                    iconSize: 12.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOptionCard(
      BuildContext context, {
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76.0,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected ? colors.successBackground : colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? colors.brandPrimary : colors.borderDefault,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              AppIcons.smartphone,
              width: 22.0,
              height: 22.0,
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
                    'System',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Ikuti pengaturan perangkat',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildSelectionIndicator(
              context,
              isSelected: isSelected,
              size: 22.0,
              iconSize: 14.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(
      BuildContext context, {
        required bool isSelected,
        required double size,
        required double iconSize,
      }) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colors.brandPrimary : Colors.transparent,
        border: Border.all(
          color: isSelected ? colors.brandPrimary : colors.borderDefault,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
        child: SvgPicture.asset(
          AppIcons.check,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            colors.surfaceCard,
            BlendMode.srcIn,
          ),
        ),
      )
          : null,
    );
  }
}
