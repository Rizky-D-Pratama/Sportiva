import 'package:flutter/material.dart';
import 'app_button.dart';

/// Pasangan tombol Reset (sekunder) dan Terapkan (utama) di bottom sheet.
class SheetActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;
  final String resetLabel;
  final String applyLabel;

  const SheetActionButtons({
    super.key,
    required this.onReset,
    required this.onApply,
    this.resetLabel = 'Reset',
    this.applyLabel = 'Terapkan',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: AppButton(
            label: resetLabel,
            variant: AppButtonVariant.secondary,
            onPressed: onReset,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 9,
          child: AppButton(label: applyLabel, onPressed: onApply),
        ),
      ],
    );
  }
}