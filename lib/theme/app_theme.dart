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
  final Color successBackground;
  final Color successForeground;
  final Color borderDefault;
  final Color brandPrimary;
  final Color surfaceCard;
  final Color surfaceControl;
  final Color surfaceNavigation;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;
  final Color dangerBackground;
  final Color dangerForeground;
  final Color warningForeground;
  final Color warningBackground;
  final Color neutralForeground;
  final Color neutralBackground;

  const AppCustomColors({
    required this.successBackground,
    required this.successForeground,
    required this.borderDefault,
    required this.brandPrimary,
    required this.surfaceCard,
    required this.surfaceControl,
    required this.surfaceNavigation,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.dangerBackground,
    required this.dangerForeground,
    required this.warningForeground,
    required this.warningBackground,
    required this.neutralForeground,
    required this.neutralBackground,
  });

  @override
  AppCustomColors copyWith({
    Color? successBackground,
    Color? successForeground,
    Color? borderDefault,
    Color? brandPrimary,
    Color? surfaceCard,
    Color? textPrimary,
    Color? textSecondary,
    Color? dangerBackground,
    Color? dangerForeground,
    Color? surfaceControl,
    Color? surfaceNavigation,
    Color? textOnPrimary,
    Color? warningForeground,
    Color? warningBackground,
    Color? neutralForeground,
    Color? neutralBackground,
  }) {
    return AppCustomColors(
      successBackground: successBackground ?? this.successBackground,
      successForeground: successForeground ?? this.successForeground,
      borderDefault: borderDefault ?? this.borderDefault,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      surfaceControl: surfaceControl ?? this.surfaceControl,
      surfaceNavigation: surfaceNavigation ?? this.surfaceNavigation,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      warningForeground: warningForeground ?? this.warningForeground,
      warningBackground: warningBackground ?? this.warningBackground,
      neutralForeground: neutralForeground ?? this.neutralForeground,
      neutralBackground: neutralBackground ?? this.neutralBackground,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      successBackground:
          Color.lerp(successBackground, other.successBackground, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      dangerBackground: Color.lerp(dangerBackground, other.dangerBackground, t)!,
      dangerForeground: Color.lerp(dangerForeground, other.dangerForeground, t)!,
      surfaceControl: Color.lerp(surfaceControl, other.surfaceControl, t)!,
      surfaceNavigation: Color.lerp(surfaceNavigation, other.surfaceNavigation, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      warningForeground: Color.lerp(warningForeground, other.warningForeground, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      neutralForeground: Color.lerp(neutralForeground, other.neutralForeground, t)!,
      neutralBackground: Color.lerp(neutralBackground, other.neutralBackground, t)!,
    );
  }
}

/// AppTheme defines the ThemeData using values extracted from the Figma tokens.
class AppTheme {
  // Base Palette Colors
  static const Color baseBackground = Color(0xFFFFFDF1);
  static const Color brandPrimary = Color(0xFF59C749);
  //text
  static const Color textPrimaryColor = Color(0xFF202820);
  static const Color textSecondaryColor = Color(0xFF777D75);
  static const Color textOnPrimaryColor = Color(0xFF202820);
  //surface
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceControlColor = Color(0xFFFFFFFF);
  static const Color surfaceNavigationColor = Color(0xFFFFFFFF);
  //status succes
  static const Color statusSuccessForeground = Color(0xFF286B24);
  static const Color statusSuccessBackground = Color(0xFFEDF8E8);
  //status warning
  static const Color statusWarningForeground = Color(0xFF9A6B21);
  static const Color statusWarningBackground = Color(0xFFFFF3D9);
  //status danger
  static const Color statusDangerBackground = Color(0xFFFDEDEE);
  static const Color statusDangerForeground = Color(0xFFAB3E45);
  //status neutral
  static const Color statusNeutralForeground = Color(0xFF777D75);
  static const Color statusNeutralBackground = Color(0xFFF0F2EC);
  //border
  static const Color borderDefaultColor = Color(0xFFE8EBDD);

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
        primary: brandPrimary,
        onPrimary: textOnPrimaryColor,       // Figma: Text/on-primary (#202820)
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
          successBackground: statusSuccessBackground,
          successForeground: statusSuccessForeground,
          borderDefault: borderDefaultColor,
          brandPrimary: brandPrimary,
          surfaceCard: surfaceCard,
          textPrimary: textPrimaryColor,
          textSecondary: textSecondaryColor,
          dangerBackground: statusDangerBackground,
          dangerForeground: statusDangerForeground,
          surfaceControl: surfaceControlColor,
          surfaceNavigation: surfaceNavigationColor,
          textOnPrimary: textOnPrimaryColor,
          warningForeground: statusWarningForeground,
          warningBackground: statusWarningBackground,
          neutralForeground: statusNeutralForeground,
          neutralBackground: statusNeutralBackground,
        ),
      ],
    );
  }
}

extension AppColorsContext on BuildContext {
  AppCustomColors get appColors => Theme.of(this).extension<AppCustomColors>()!;
}