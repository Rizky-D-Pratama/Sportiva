import 'package:flutter/material.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import 'app_badge.dart';
import 'app_image.dart';

/// Reusable Admin Court Card widget for Admin Courts Management screen (Figma 279:2042).
class AdminCourtCard extends StatelessWidget {
  final Court court;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminCourtCard({
    super.key,
    required this.court,
    required this.onEdit,
    required this.onDelete,
  });

  /// Helper to format price for court card e.g. "Rp150.000/jam"
  String get formattedPricePerHours {
    final buffer = StringBuffer();
    final priceStr = court.pricePerHour.toString();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return 'Rp${buffer.toString()}/jam';
  }

  /// Helper to format subtitle: "Category • Facility1 • Facility2..."
  String get formattedSubtitle {
    final list = <String>[court.category, ...court.facilities];
    return list.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Thumbnail image + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Thumbnail (76x80)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: 76.0,
                  height: 80.0,
                  child: AppImage(
                    imagePath: court.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // Content Group
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Court Name
                    Text(
                      court.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),

                    // Subtitle: Category • Facilities
                    Text(
                      formattedSubtitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 10.0,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),

                    // Price & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formattedPricePerHours,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        AppBadge(
                          label: court.isActive ? 'Aktif' : 'Nonaktif',
                          variant: court.isActive
                              ? AppBadgeVariant.success
                              : AppBadgeVariant.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Actions row: Edit (left) and Hapus (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: Text(
                    'Edit',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: colors.successForeground,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: Text(
                    'Hapus',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                      color: colors.dangerForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
