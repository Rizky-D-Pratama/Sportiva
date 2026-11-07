import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';

/// Reusable CourtCard widget displaying court details (Lapangan)
class CourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback? onTap;

  const CourtCard({
    super.key,
    required this.court,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final borderColor =
        customColors?.borderDefault ?? theme.colorScheme.outline;
    final textPrimary =
        customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary =
        customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;
    final successForeground =
        customColors?.successForeground ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(32, 40, 32, 0.03),
            blurRadius: 16.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image container
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.borderRadiusMedium),
                ),
                child: SizedBox(
                  height: 135.0,
                  width: double.infinity,
                  child: Image.network(
                    court.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: borderColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: borderColor,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: textSecondary,
                          size: 32.0,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Information container
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Name
                    Text(
                      court.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),

                    // Location Row
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.mapPin,
                          width: AppTheme.iconSizeSmall + 2.0,
                          height: AppTheme.iconSizeSmall + 2.0,
                          colorFilter: ColorFilter.mode(
                            textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            court.venue.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Price & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          court.formattedPrice,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: successForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          court.formattedRating,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Venue, Category & Action Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.building,
                                width: AppTheme.iconSizeSmall,
                                height: AppTheme.iconSizeSmall,
                                colorFilter: ColorFilter.mode(
                                  textSecondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  court.venue.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '•',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                court.category,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Lihat Detail →',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: successForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
