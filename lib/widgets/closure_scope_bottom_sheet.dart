import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';

/// Scope item selected: courtId (or null for whole venue)
class ClosureScopeItem {
  final String? courtId; // null = whole venue
  final String label;

  const ClosureScopeItem({
    required this.courtId,
    required this.label,
  });

  bool get isWholeVenue => courtId == null || courtId!.isEmpty;
}

/// Bottom Sheet for selecting closure scope ("Seluruh Sportiva Center" or specific court)
class ClosureScopeBottomSheet extends StatelessWidget {
  final String venueName;
  final List<Court> courts;
  final String? selectedCourtId; // null = whole venue
  final ValueChanged<ClosureScopeItem> onScopeSelected;

  const ClosureScopeBottomSheet({
    super.key,
    required this.venueName,
    required this.courts,
    required this.selectedCourtId,
    required this.onScopeSelected,
  });

  /// Static helper to show the sheet
  static Future<ClosureScopeItem?> show({
    required BuildContext context,
    required String venueName,
    required List<Court> courts,
    required String? selectedCourtId,
  }) {
    return showModalBottomSheet<ClosureScopeItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClosureScopeBottomSheet(
        venueName: venueName,
        courts: courts,
        selectedCourtId: selectedCourtId,
        onScopeSelected: (item) => Navigator.pop(ctx, item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final isWholeVenueSelected = selectedCourtId == null || selectedCourtId!.isEmpty;

    return AppBottomSheet(
      title: 'Pilih Cakupan Penutupan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top full-width row: "Seluruh [nama venue]"
          _ScopeCard(
            label: 'Seluruh $venueName',
            isSelected: isWholeVenueSelected,
            onTap: () {
              onScopeSelected(ClosureScopeItem(
                courtId: null,
                label: 'Seluruh $venueName',
              ));
            },
          ),
          const SizedBox(height: 12.0),

          // Label "Lapangan"
          Text(
            'Pilih Lapangan',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),

          // 2. Grid 2-column of courts belonging to the venue
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final court = courts[index];
              final isSelected = selectedCourtId == court.id;
              return _ScopeCard(
                label: court.name,
                isSelected: isSelected,
                onTap: () {
                  onScopeSelected(ClosureScopeItem(
                    courtId: court.id,
                    label: court.name,
                  ));
                },
              );
            },
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _ScopeCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Material(
      color: isSelected ? colors.successBackground : colors.surfaceCard,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            border: Border.all(
              color: isSelected ? colors.brandPrimary : colors.borderDefault,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? colors.successForeground : colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                SvgPicture.asset(
                  AppIcons.check,
                  width: 16.0,
                  height: 16.0,
                  colorFilter: ColorFilter.mode(
                    colors.successForeground,
                    BlendMode.srcIn,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
