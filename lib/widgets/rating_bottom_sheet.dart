import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/sheet_action_buttons.dart';
import '../widgets/app_chip.dart';

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
    return AppBottomSheet(
      title: 'Rating',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppChip(
                label: 'Tertinggi',
                isSelected: _selectedSort == RatingSortType.highest,
                onTap: () => _selectSort(RatingSortType.highest),
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              AppChip(
                label: 'Terendah',
                isSelected: _selectedSort == RatingSortType.lowest,
                onTap: () => _selectSort(RatingSortType.lowest),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          SheetActionButtons(onReset: _reset, onApply: _apply),
        ],
      ),
    );
  }
}
