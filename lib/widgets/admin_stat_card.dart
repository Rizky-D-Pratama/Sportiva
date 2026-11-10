import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Reusable Admin Statistic Card widget for Dashboard and Reports.
/// Displays value (large text), icon (16x16) on the right, and label (small text) below.
class AdminStatCard extends StatelessWidget {
  final String value;
  final String label;
  final String iconPath;

  const AdminStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: colors.borderDefault,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(32, 40, 32, 0.03),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              SvgPicture.asset(
                iconPath,
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 10.0,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
