import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBg = colors.surfaceCard;
    final textPrimary =
        colors.textPrimary;
    final textSecondary =
        colors.textSecondary;
    final borderColor =
        colors.borderDefault;
    final successBg = colors.successBackground;
    final successFg =
        colors.successForeground;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rentang harga',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(100.0),
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      AppIcons.cross,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: ColorFilter.mode(
                        textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Quick Choice Options
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildQuickChip(
                  optionId: 1,
                  label: 'Di bawah Rp100.000',
                  theme: theme,
                  successBg: successBg,
                  successFg: successFg,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                ),
                _buildQuickChip(
                  optionId: 2,
                  label: 'Rp100.000 – Rp200.000',
                  theme: theme,
                  successBg: successBg,
                  successFg: successFg,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                ),
                _buildQuickChip(
                  optionId: 3,
                  label: 'Di atas Rp200.000',
                  theme: theme,
                  successBg: successBg,
                  successFg: successFg,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // Custom Range Inputs
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minimum',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        height: 46.0,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          children: [
                            Text(
                              'Rp  ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _minController,
                                keyboardType: TextInputType.number,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) {
                                  setState(() {
                                    _updateQuickOptionFromInputs();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maksimum',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        height: 46.0,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          children: [
                            Text(
                              'Rp  ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textPrimary,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _maxController,
                                keyboardType: TextInputType.number,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) {
                                  setState(() {
                                    _updateQuickOptionFromInputs();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Action Buttons (Reset & Terapkan)
            Row(
              children: [
                SizedBox(
                  width: 104.0,
                  height: 48.0,
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: cardBg,
                      side: BorderSide(color: borderColor, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Reset',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: Text(
                        'Terapkan',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required int optionId,
    required String label,
    required ThemeData theme,
    required Color successBg,
    required Color successFg,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
  }) {
    final isSelected = _selectedQuickOption == optionId;
    return InkWell(
      onTap: () => _selectQuickOption(optionId),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? successBg : cardBg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : borderColor,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected ? successFg : textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
