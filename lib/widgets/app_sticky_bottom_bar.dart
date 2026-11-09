import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable sticky bottom action bar component
class AppStickyBottomBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppStickyBottomBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colors.borderDefault,
            width: 1.0,
          ),
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
