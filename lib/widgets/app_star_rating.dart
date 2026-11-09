import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Reusable star rating widget supporting display mode and interactive mode.
class AppStarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double iconSize;
  final double gap;

  const AppStarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.iconSize = 32.0,
    this.gap = 12.0,
  });

  bool get isInteractive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        Widget starIcon = SvgPicture.asset(
          isFilled ? AppIcons.starYellow : AppIcons.starOutline,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            isFilled ? AppTheme.starYellow : colors.textSecondary,
            BlendMode.srcIn,
          ),
        );

        if (isInteractive) {
          starIcon = InkWell(
            onTap: () => onChanged?.call(starValue),
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox(
              width: 48.0,
              height: 48.0,
              child: Center(child: starIcon),
            ),
          );
        }

        if (index == 4) return starIcon;

        return Padding(
          padding: EdgeInsets.only(right: isInteractive ? 0 : gap),
          child: starIcon,
        );
      }),
    );
  }
}
