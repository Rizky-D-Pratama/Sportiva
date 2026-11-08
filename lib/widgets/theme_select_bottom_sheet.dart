import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';

enum AppThemeModeOption { light, dark, system }

/// Opens the Tampilan (Theme Selection) Bottom Sheet
Future<void> showThemeSelectBottomSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    builder: (context) => const ThemeSelectBottomSheet(),
  );
}

/// Bottom Sheet content for selecting app display theme
class ThemeSelectBottomSheet extends StatefulWidget {
  const ThemeSelectBottomSheet({super.key});

  @override
  State<ThemeSelectBottomSheet> createState() =>
      _ThemeSelectBottomSheetState();
}

class _ThemeSelectBottomSheetState extends State<ThemeSelectBottomSheet> {
  AppThemeModeOption _selectedOption = AppThemeModeOption.system;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBottomSheet(
      title: 'Tampilan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Light & Dark theme options side by side
          Row(
            children: [
              Expanded(
                child: _buildThemePreviewCard(
                  context: context,
                  option: AppThemeModeOption.light,
                  label: 'Light',
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
                  option: AppThemeModeOption.dark,
                  label: 'Dark',
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

          // System theme option (Selected by default)
          _buildSystemOptionCard(context),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard({
    required BuildContext context,
    required AppThemeModeOption option,
    required String label,
    required Color bgColor,
    required Color cardColor,
    required Color headingColor,
    required Color descColor,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? colors.brandPrimary : colors.borderDefault,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Preview Mock Box
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
                            color: colors.successBackground,
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
            // Option Label & Selection indicator
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
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colors.brandPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? colors.brandPrimary
                            : colors.borderDefault,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: SvgPicture.asset(
                              AppIcons.check,
                              width: 12.0,
                              height: 12.0,
                              colorFilter: ColorFilter.mode(
                                colors.surfaceCard,
                                BlendMode.srcIn,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOptionCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isSelected = _selectedOption == AppThemeModeOption.system;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = AppThemeModeOption.system;
        });
      },
      child: Container(
        height: 76.0,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.successBackground
              : colors.surfaceCard,
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
            Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colors.brandPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? colors.brandPrimary
                      : colors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: SvgPicture.asset(
                        AppIcons.check,
                        width: 14.0,
                        height: 14.0,
                        colorFilter: ColorFilter.mode(
                          colors.surfaceCard,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
