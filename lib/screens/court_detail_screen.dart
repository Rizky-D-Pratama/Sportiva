import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../models/court.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';
import '../widgets/app_calendar.dart';
import '../widgets/app_image.dart';
import 'booking_summary_screen.dart';
import '../widgets/time_select_bottom_sheet.dart';

/// Screen displaying detailed information for a selected Court
class CourtDetailScreen extends StatefulWidget {
  final Court court;

  const CourtDetailScreen({
    super.key,
    required this.court,
  });

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  late DateTime _selectedDate;
  int? _selectedStartHour; // e.g. 18 for 18.00
  int? _selectedDurationHours; // e.g. 2 for 2 hours

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  bool _isHourUnavailable(int hour) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    if (isToday && hour <= now.hour) {
      return true;
    }

    for (final slot in widget.court.unavailableTimeSlots) {
      if (hour >= slot.startHour && hour < slot.endHour) {
        return true;
      }
    }

    return false;
  }

  bool _hasAvailableStartHours() {
    for (int h = AppConstants.operationalStartHour;
        h < AppConstants.operationalEndHour;
        h++) {
      if (!_isHourUnavailable(h)) {
        return true;
      }
    }
    return false;
  }

  int _calculateMaxAvailableDuration(int startHour) {
    int maxHours = 0;
    for (int h = startHour; h < AppConstants.operationalEndHour; h++) {
      if (_isHourUnavailable(h) && h != startHour) {
        break;
      }
      maxHours++;
      if (maxHours >= AppConstants.maxBookingDurationHours) {
        break;
      }
    }
    return maxHours;
  }

  void _openTimeSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimeSelectBottomSheet(
          selectedDate: _selectedDate,
          unavailableSlots: widget.court.unavailableTimeSlots,
          onTimeSelected: (hour) {
            setState(() {
              _selectedStartHour = hour;
              _selectedDurationHours = null; // Reset duration when start hour changes
            });
          },
        );
      },
    );
  }

  String _formatMonthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final baseBg = theme.scaffoldBackgroundColor;
    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final textPrimary =
        customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary =
        customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;
    final borderColor =
        customColors?.borderDefault ?? theme.colorScheme.outline;
    final successFg =
        customColors?.successForeground ?? theme.colorScheme.primary;
    final successBg = customColors?.bannerBackground ??
        theme.colorScheme.primaryContainer;

    final hasAvailableHours = _hasAvailableStartHours();
    final maxDuration = _selectedStartHour != null
        ? _calculateMaxAvailableDuration(_selectedStartHour!)
        : 0;

    final isBookingValid = _selectedStartHour != null &&
        _selectedDurationHours != null &&
        _selectedDurationHours! > 0;

    final endHour = isBookingValid
        ? _selectedStartHour! + _selectedDurationHours!
        : null;

    final totalPrice = isBookingValid
        ? widget.court.pricePerHour * _selectedDurationHours!
        : 0;

    final formattedDateText =
        '${_selectedDate.day} ${_formatMonthAbbrev(_selectedDate.month)}';

    final bookingSummaryText = isBookingValid
        ? '$formattedDateText • ${_selectedStartHour! < 10 ? '0$_selectedStartHour.00' : '$_selectedStartHour.00'} – ${endHour! < 10 ? '0$endHour.00' : '$endHour.00'} • $_selectedDurationHours jam'
        : 'Pilih tanggal, jam mulai & durasi';

    return Scaffold(
      backgroundColor: baseBg,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingXLarge,
                  vertical: AppTheme.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. App Header (Back Arrow & Title)
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(100.0),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.asset(
                              AppIcons.arrowLeft,
                              width: AppTheme.iconSizeMedium,
                              height: AppTheme.iconSizeMedium,
                              colorFilter: ColorFilter.mode(
                                textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Detail Lapangan',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Court Photography
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      child: SizedBox(
                        height: 170.0,
                        width: double.infinity,
                        child: AppImage(
                          imagePath: widget.court.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 3. Court Information Header
                    Text(
                      widget.court.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: textPrimary,
                        fontSize: 23.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),

                    // Venue & Rating
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.building,
                          width: AppTheme.iconSizeSmall + 2.0,
                          height: AppTheme.iconSizeSmall + 2.0,
                          colorFilter: ColorFilter.mode(
                            textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            '${widget.court.venue.name} • ★ ${widget.court.rating.toString().replaceAll('.', ',')} (${widget.court.reviewCount} ulasan)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),

                    // Location
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.mapPin,
                          width: AppTheme.iconSizeSmall + 2.0,
                          height: AppTheme.iconSizeSmall + 2.0,
                          colorFilter: ColorFilter.mode(
                            textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            widget.court.venue.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Facility Badges
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.court.facilities.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: successBg,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text(
                            facility,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: successFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12.0),

                    // Description
                    Text(
                      widget.court.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Price
                    Text(
                      widget.court.formattedPrice,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: successFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // 4. Section: Date & Time Picker Header
                    Text(
                      'Pilih tanggal & waktu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // 5. Date Picker Calendar
                    AppCalendar(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                          _selectedStartHour = null; // Reset time selection on date change
                          _selectedDurationHours = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // 6. Operational Hours Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jam operasional',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '08.00 – 24.00 WIB',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // 7. Time Information Card ("Waktu tidak tersedia")
                    if (widget.court.unavailableTimeSlots.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                          border: Border.all(color: borderColor, width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(32, 40, 32, 0.03),
                              blurRadius: 16.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu tidak tersedia',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Column(
                              children: widget.court.unavailableTimeSlots
                                  .map((slot) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _buildUnavailableSlotRow(
                                    slot: slot,
                                    theme: theme,
                                    customColors: customColors,
                                    cardBg: cardBg,
                                    borderColor: borderColor,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16.0),

                    // 8. Time Input Row (Jam mulai & Durasi)
                    Row(
                      children: [
                        // Jam Mulai Input Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jam mulai',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              InkWell(
                                onTap: hasAvailableHours
                                    ? _openTimeSelectBottomSheet
                                    : null,
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  height: 46.0,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          !hasAvailableHours
                                              ? 'Tidak ada jam tersedia'
                                              : _selectedStartHour != null
                                                  ? '${_selectedStartHour! < 10 ? '0$_selectedStartHour' : '$_selectedStartHour'}.00'
                                                  : 'Pilih jam',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: !hasAvailableHours
                                                ? (customColors
                                                        ?.dangerForeground ??
                                                    AppTheme
                                                        .statusDangerForeground)
                                                : (_selectedStartHour != null
                                                    ? textPrimary
                                                    : textSecondary),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        AppIcons.clock,
                                        width: 18.0,
                                        height: 18.0,
                                        colorFilter: ColorFilter.mode(
                                          textSecondary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),

                        // Durasi Input Field (Dropdown)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi',
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
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.0,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: _selectedDurationHours,
                                    hint: Text(
                                      'Pilih durasi',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: textSecondary,
                                      ),
                                    ),
                                    icon: SvgPicture.asset(
                                      AppIcons.chevronDown,
                                      width: 18.0,
                                      height: 18.0,
                                      colorFilter: ColorFilter.mode(
                                        _selectedStartHour == null
                                            ? textSecondary.withValues(alpha: 0.4)
                                            : textSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onChanged: _selectedStartHour == null ||
                                            maxDuration == 0
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedDurationHours = value;
                                            });
                                          },
                                    items: maxDuration == 0
                                        ? []
                                        : List.generate(
                                            maxDuration,
                                            (index) {
                                              final d = index + 1;
                                              return DropdownMenuItem<int>(
                                                value: d,
                                                child: Text(
                                                  '$d jam',
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: textPrimary,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Actions Bar
            Container(
              decoration: BoxDecoration(
                color: baseBg,
                border: Border(
                  top: BorderSide(
                    color: borderColor,
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookingSummaryText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              isBookingValid
                                  ? 'Rp${_formatNumber(totalPrice)}'
                                  : 'Rp0',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: isBookingValid
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingSummaryScreen(
                                    court: widget.court,
                                    selectedDate: _selectedDate,
                                    startHour: _selectedStartHour!,
                                    durationHours: _selectedDurationHours!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        disabledBackgroundColor:
                            borderColor.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: Text(
                        'Booking Sekarang',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isBookingValid
                              ? textPrimary
                              : textSecondary.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableSlotRow({
    required UnavailableTimeSlot slot,
    required ThemeData theme,
    required AppCustomColors? customColors,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    Color statusBg;
    Color statusFg;

    switch (slot.statusType) {
      case SlotStatusType.booked:
        statusBg =
            customColors?.dangerBackground ?? AppTheme.statusDangerBackground;
        statusFg =
            customColors?.dangerForeground ?? AppTheme.statusDangerForeground;
        break;
      case SlotStatusType.onHold:
        statusBg = const Color(0xFFFFF3D9);
        statusFg = const Color(0xFF9A6B21);
        break;
      case SlotStatusType.closed:
        statusBg = const Color(0xFFF0F2EC);
        statusFg = const Color(0xFF777D75);
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slot.timeRangeText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  slot.statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            slot.note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
