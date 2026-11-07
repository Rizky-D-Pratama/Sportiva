import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';

enum RatingSortType { highest, lowest }

/// Bottom sheet widget for sorting Courts by rating (Tertinggi / Terendah)
class RatingBottomSheet extends StatefulWidget {
  final RatingSortType? initialSort;
  final Function(RatingSortType? sortType) onApply;

  const RatingBottomSheet({
    super.key,
    this.initialSort,
    required this.onApply,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  RatingSortType? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
  }

  void _selectSort(RatingSortType sort) {
    setState(() {
      if (_selectedSort == sort) {
        _selectedSort = null;
      } else {
        _selectedSort = sort;
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedSort = null;
    });
  }

  void _apply() {
    widget.onApply(_selectedSort);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final cardBg = colors.surfaceCard;
    final textPrimary =
        colors.textPrimary;
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
                  'Rating',
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

            // Rating Sort Options
            Row(
              children: [
                _buildSortChip(
                  sortType: RatingSortType.highest,
                  label: 'Tertinggi',
                  theme: theme,
                  successBg: successBg,
                  successFg: successFg,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                ),
                const SizedBox(width: 8.0),
                _buildSortChip(
                  sortType: RatingSortType.lowest,
                  label: 'Terendah',
                  theme: theme,
                  successBg: successBg,
                  successFg: successFg,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
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

  Widget _buildSortChip({
    required RatingSortType sortType,
    required String label,
    required ThemeData theme,
    required Color successBg,
    required Color successFg,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
  }) {
    final isSelected = _selectedSort == sortType;
    return InkWell(
      onTap: () => _selectSort(sortType),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
