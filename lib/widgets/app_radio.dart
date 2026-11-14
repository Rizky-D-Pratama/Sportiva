import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom Radio button widget matching Sportiva theme
class AppRadio extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool>? onChanged;

  const AppRadio({
    super.key,
    required this.selected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!selected) : null,
      borderRadius: BorderRadius.circular(100.0),
      child: Container(
        width: 18.0,
        height: 18.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.brandPrimary : colors.borderDefault,
            width: selected ? 2.0 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: 9.0,
                height: 9.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brandPrimary,
                ),
              )
            : null,
      ),
    );
  }
}

/// A row containing an AppRadio and a text label
class AppRadioOption<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  const AppRadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: SizedBox(
        height: 32.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppRadio(
              selected: _isSelected,
              onChanged: (_) => onChanged(value),
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
