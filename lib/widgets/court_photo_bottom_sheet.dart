import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'app_menu_tile.dart';

/// Item definition for options in Photo Bottom Sheet
class PhotoSheetOption {
  final String iconPath;
  final String label;
  final VoidCallback? onTap;

  const PhotoSheetOption({
    required this.iconPath,
    required this.label,
    this.onTap,
  });
}

/// Bottom Sheet for "Edit Foto Lapangan" (Figma node 880:1555)
class CourtPhotoBottomSheet extends StatelessWidget {
  final String title;
  final List<PhotoSheetOption> options;

  const CourtPhotoBottomSheet({
    super.key,
    this.title = 'Edit Foto Lapangan',
    this.options = const [
      PhotoSheetOption(
        iconPath: AppIcons.layoutDashboard,
        label: 'Sesuaikan Foto',
      ),
      PhotoSheetOption(
        iconPath: AppIcons.imagePlus,
        label: 'Ganti Foto',
      ),
    ],
  });

  static Future<void> show({
    required BuildContext context,
    String title = 'Edit Foto Lapangan',
    List<PhotoSheetOption>? options,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (ctx) => CourtPhotoBottomSheet(
        title: title,
        options: options ??
            const [
              PhotoSheetOption(
                iconPath: AppIcons.layoutDashboard,
                label: 'Sesuaikan Foto',
              ),
              PhotoSheetOption(
                iconPath: AppIcons.imagePlus,
                label: 'Ganti Foto',
              ),
            ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
            child: AppMenuTile(
              iconPath: option.iconPath,
              label: option.label,
              onTap: option.onTap ?? () {}, // Does nothing as requested
            ),
          );
        }).toList(),
      ),
    );
  }
}
