import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_field.dart';

class AccountEditBottomSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hintText;
  final TextInputType? keyboardType;

  const AccountEditBottomSheet({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hintText,
    this.keyboardType,
  });

  @override
  State<AccountEditBottomSheet> createState() =>
      _AccountEditBottomSheetState();
}

class _AccountEditBottomSheetState
    extends State<AccountEditBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppField(
            label: '',
            controller: _controller,
            hintText: widget.hintText,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.none,
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: AppButton(
                  label: 'Batal',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                flex: 9,
                child: AppButton(
                  label: 'Simpan',
                  leadingIconPath: AppIcons.check,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}