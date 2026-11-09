import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_star_rating.dart';

/// Opens the "Beri penilaian" bottom sheet for a finished booking.
Future<void> showGiveRatingBottomSheet({
  required BuildContext context,
  required Booking booking,
  required ValueChanged<int> onRatingSubmitted,
}) {
  return showAppBottomSheet(
    context: context,
    builder: (context) => GiveRatingBottomSheet(
      booking: booking,
      onRatingSubmitted: onRatingSubmitted,
    ),
  );
}

/// Content for "Beri penilaian" bottom sheet.
class GiveRatingBottomSheet extends StatefulWidget {
  final Booking booking;
  final ValueChanged<int> onRatingSubmitted;

  const GiveRatingBottomSheet({
    super.key,
    required this.booking,
    required this.onRatingSubmitted,
  });

  @override
  State<GiveRatingBottomSheet> createState() => _GiveRatingBottomSheetState();
}

class _GiveRatingBottomSheetState extends State<GiveRatingBottomSheet> {
  int _selectedRating = 0;

  void _submitRating() {
    if (_selectedRating <= 0) return;
    // TODO: Nanti mengirim rating ke server/backend
    widget.onRatingSubmitted(_selectedRating);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppBottomSheet(
      title: 'Beri penilaian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konteks booking
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking.courtName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${widget.booking.date} • ${widget.booking.timeRange}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Area pilihan bintang
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bagaimana pengalaman bermainmu?',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: AppStarRating(
                  rating: _selectedRating,
                  onChanged: (val) {
                    setState(() {
                      _selectedRating = val;
                    });
                  },
                  iconSize: 32.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Pilih 1–5 bintang',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Tombol Kirim penilaian
          AppButton(
            label: 'Kirim penilaian',
            onPressed: _selectedRating > 0 ? _submitRating : null,
          ),
        ],
      ),
    );
  }
}
