import 'package:flutter/material.dart';

/// Custom page transition builder that slides pages in from the right and out to the right.
class SlideRightPageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideRightPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      ),
      child: child,
    );
  }
}

/// Extension for custom colors defined in Figma design system.
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color bannerBackground;
  final Color successForeground;
  final Color borderDefault;
  final Color activeIndicator;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color dangerBackground;
  final Color dangerForeground;

  const AppCustomColors({
    required this.bannerBackground,
    required this.successForeground,
    required this.borderDefault,
    required this.activeIndicator,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.dangerBackground,
    required this.dangerForeground,
  });

  @override
  AppCustomColors copyWith({
    Color? bannerBackground,
    Color? successForeground,
    Color? borderDefault,
    Color? activeIndicator,
    Color? cardBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? dangerBackground,
    Color? dangerForeground,
  }) {
    return AppCustomColors(
      bannerBackground: bannerBackground ?? this.bannerBackground,
      successForeground: successForeground ?? this.successForeground,
      borderDefault: borderDefault ?? this.borderDefault,
      activeIndicator: activeIndicator ?? this.activeIndicator,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerForeground: dangerForeground ?? this.dangerForeground,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      bannerBackground:
          Color.lerp(bannerBackground, other.bannerBackground, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      activeIndicator: Color.lerp(activeIndicator, other.activeIndicator, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      dangerBackground: Color.lerp(dangerBackground, other.dangerBackground, t)!,
      dangerForeground: Color.lerp(dangerForeground, other.dangerForeground, t)!,
    );
  }
}

/// AppTheme defines the ThemeData using values extracted from the Figma tokens.
class AppTheme {
  // Base Palette Colors from Figma
  static const Color baseBackground = Color(0xFFFFFDF1);
  static const Color textPrimaryColor = Color(0xFF202820);
  static const Color textSecondaryColor = Color(0xFF777D75);
  static const Color statusSuccessForeground = Color(0xFF286B24);
  static const Color statusSuccessBackground = Color(0xFFEDF8E8);
  static const Color statusDangerBackground = Color(0xFFFDEDEE);
  static const Color statusDangerForeground = Color(0xFFAB3E45);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderDefaultColor = Color(0xFFE8EBDD);
  static const Color primaryIndicatorColor = Color(0xFF59C749);

  // Spacing & Border Radius Tokens
  static const double borderRadiusSmall = 10.4;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 14.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;

  static const double iconSizeSmall = 12.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double shortcutBoxSize = 56.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: baseBackground,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: SlideRightPageTransitionsBuilder(),
          TargetPlatform.iOS: SlideRightPageTransitionsBuilder(),
          TargetPlatform.windows: SlideRightPageTransitionsBuilder(),
          TargetPlatform.macOS: SlideRightPageTransitionsBuilder(),
          TargetPlatform.linux: SlideRightPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: statusSuccessForeground,
        secondary: primaryIndicatorColor,
        surface: surfaceCard,
        onSurface: textPrimaryColor,
        onSurfaceVariant: textSecondaryColor,
        outline: borderDefaultColor,
        primaryContainer: statusSuccessBackground,
        onPrimaryContainer: statusSuccessForeground,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.25,
        ),
        titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: statusSuccessForeground,
          height: 1.45,
        ),
        labelMedium: TextStyle(
          fontSize: 10.4,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
          height: 1.45,
        ),
        labelSmall: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          height: 1.45,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: borderDefaultColor, width: 1.0),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppCustomColors(
          bannerBackground: statusSuccessBackground,
          successForeground: statusSuccessForeground,
          borderDefault: borderDefaultColor,
          activeIndicator: primaryIndicatorColor,
          cardBackground: surfaceCard,
          textPrimary: textPrimaryColor,
          textSecondary: textSecondaryColor,
          dangerBackground: statusDangerBackground,
          dangerForeground: statusDangerForeground,
        ),
      ],
    );
  }
}
