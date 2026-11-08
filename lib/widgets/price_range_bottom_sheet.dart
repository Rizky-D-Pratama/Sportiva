import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/sheet_action_buttons.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_field.dart';

/// Bottom sheet widget for filtering Courts by price range
class PriceRangeBottomSheet extends StatefulWidget {
  final int? initialMinPrice;
  final int? initialMaxPrice;
  final Function(int? minPrice, int? maxPrice) onApply;

  const PriceRangeBottomSheet({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<PriceRangeBottomSheet> createState() => _PriceRangeBottomSheetState();
}

class _PriceRangeBottomSheetState extends State<PriceRangeBottomSheet> {
  late TextEditingController _minController;
  late TextEditingController _maxController;
  int? _selectedQuickOption; // 1: <100k, 2: 100k-200k, 3: >200k, null: custom or none

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: _formatPrice(widget.initialMinPrice),
    );
    _maxController = TextEditingController(
      text: _formatPrice(widget.initialMaxPrice),
    );
    _updateQuickOptionFromInputs();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _formatPrice(int? price) {
    if (price == null) return '';
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  int? _parsePrice(String str) {
    final clean = str.replaceAll('.', '').replaceAll(' ', '').trim();
    return int.tryParse(clean);
  }

  void _updateQuickOptionFromInputs() {
    final min = _parsePrice(_minController.text);
    final max = _parsePrice(_maxController.text);

    if (min == null && max == 100000) {
      _selectedQuickOption = 1;
    } else if (min == 100000 && max == 200000) {
      _selectedQuickOption = 2;
    } else if (min == 200000 && max == null) {
      _selectedQuickOption = 3;
    } else {
      _selectedQuickOption = null;
    }
  }

  void _selectQuickOption(int option) {
    setState(() {
      if (_selectedQuickOption == option) {
        _selectedQuickOption = null;
        _minController.clear();
        _maxController.clear();
      } else {
        _selectedQuickOption = option;
        if (option == 1) {
          _minController.clear();
          _maxController.text = '100.000';
        } else if (option == 2) {
          _minController.text = '100.000';
          _maxController.text = '200.000';
        } else if (option == 3) {
          _minController.text = '200.000';
          _maxController.clear();
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedQuickOption = null;
      _minController.clear();
      _maxController.clear();
    });
  }

  void _apply() {
    final min = _parsePrice(_minController.text);
    final max = _parsePrice(_maxController.text);
    widget.onApply(min, max);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Rentang harga',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppTheme.paddingSmall,
            runSpacing: AppTheme.paddingSmall,
            children: [
              AppChip(
                label: 'Di bawah Rp100.000',
                isSelected: _selectedQuickOption == 1,
                onTap: () => _selectQuickOption(1),
              ),
              AppChip(
                label: 'Rp100.000 – Rp200.000',
                isSelected: _selectedQuickOption == 2,
                onTap: () => _selectQuickOption(2),
              ),
              AppChip(
                label: 'Di atas Rp200.000',
                isSelected: _selectedQuickOption == 3,
                onTap: () => _selectQuickOption(3),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PriceInputField(
                  label: 'Minimum',
                  controller: _minController,
                  onChanged: () => setState(_updateQuickOptionFromInputs),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _PriceInputField(
                  label: 'Maksimum',
                  controller: _maxController,
                  onChanged: () => setState(_updateQuickOptionFromInputs),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          SheetActionButtons(onReset: _reset, onApply: _apply)
        ]
      ),
    );
  }
}

class _PriceInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _PriceInputField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppField(
      label: label,
      child: Row(
        children: [
          const Text('Rp  '),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}