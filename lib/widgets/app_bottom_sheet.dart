import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

/// Membuka bottom sheet dengan pengaturan standar Sportiva.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// Kerangka bottom sheet: judul, tombol tutup, dan area isi.
/// Naik mengikuti keyboard dan bisa di-scroll bila isinya tinggi.
class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Padding(
      // Mengangkat sheet setinggi keyboard agar isi tidak tertutup.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusSheet),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppTheme.paddingXLarge,
          AppTheme.paddingLarge,
          AppTheme.paddingXLarge,
          AppTheme.paddingXLarge,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: theme.textTheme.headlineMedium),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(100.0),
                      child: SizedBox(
                        width: AppTheme.iconButtonSize,
                        height: AppTheme.iconButtonSize,
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.cross,
                            width: AppTheme.iconSizeMedium,
                            height: AppTheme.iconSizeMedium,
                            colorFilter: ColorFilter.mode(
                              colors.textPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}