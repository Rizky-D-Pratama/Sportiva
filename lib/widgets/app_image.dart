import 'package:flutter/material.dart';
import '../constants/app_images.dart';

/// Shared image widget supporting local asset paths and network URLs
/// with automatic local asset fallback on error.
class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String defaultFallback;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.defaultFallback = AppImages.blankProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            defaultFallback,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultFallback,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
