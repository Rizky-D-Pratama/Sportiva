import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_field.dart';

/// Bottom Sheet for adding a new facility ("Fasilitas Lapangan" - Figma node 880:2012)
class FacilityBottomSheet extends StatefulWidget {
  final List<String> existingFacilities;
  final ValueChanged<String> onFacilityAdded;

  const FacilityBottomSheet({
    super.key,
    required this.existingFacilities,
    required this.onFacilityAdded,
  });

  static Future<void> show({
    required BuildContext context,
    required List<String> existingFacilities,
    required ValueChanged<String> onFacilityAdded,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (ctx) => FacilityBottomSheet(
        existingFacilities: existingFacilities,
        onFacilityAdded: onFacilityAdded,
      ),
    );
  }

  @override
  State<FacilityBottomSheet> createState() => _FacilityBottomSheetState();
}

class _FacilityBottomSheetState extends State<FacilityBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _errorText = 'Nama fasilitas wajib diisi.';
      });
      return;
    }

    if (trimmed.length > 20) {
      setState(() {
        _errorText = 'Maksimal 20 karakter.';
      });
      return;
    }

    final isDuplicate = widget.existingFacilities.any(
      (f) => f.toLowerCase() == trimmed.toLowerCase(),
    );

    if (isDuplicate) {
      setState(() {
        _errorText = 'Fasilitas sudah ditambahkan.';
      });
      return;
    }

    widget.onFacilityAdded(trimmed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Fasilitas Lapangan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppField(
            label: 'Masukkan Fasilitas',
            controller: _controller,
            focusNode: _focusNode,
            hintText: 'Contoh: Rumput Sintetis',
            maxLength: 20,
            errorText: _errorText,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          AppButton(
            label: 'Simpan',
            leadingIconPath: AppIcons.check,
            onPressed: _validateAndSave,
          ),
        ],
      ),
    );
  }
}
