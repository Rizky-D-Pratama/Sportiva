import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../data/booking_repository.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../models/court.dart';
import '../models/unavailable_time_slot.dart';
import '../theme/app_theme.dart';
import '../widgets/app_calendar.dart';
import '../widgets/app_info_notice.dart';
import '../widgets/category_filter_chip.dart';
import 'court_detail_screen.dart';

class _HourlySlotStatus {
  final int hour;
  final String status;
  final String type; // 'success', 'danger', 'warning', 'neutral'

  const _HourlySlotStatus({
    required this.hour,
    required this.status,
    required this.type,
  });
}

class _MergedSlotRange {
  final int startHour;
  final int endHour;
  final String status;
  final String type;

  const _MergedSlotRange({
    required this.startHour,
    required this.endHour,
    required this.status,
    required this.type,
  });
}

/// Screen displaying court schedules and availability across dates
class CourtScheduleScreen extends StatefulWidget {
  const CourtScheduleScreen({super.key});

  @override
  State<CourtScheduleScreen> createState() => _CourtScheduleScreenState();
}

class _CourtScheduleScreenState extends State<CourtScheduleScreen> {
  late DateTime _selectedDate;
  String? _selectedCategory; // 'Futsal', 'Voli', 'Basket', 'Badminton', or null
  final Map<String, bool> _expandedCourts = {}; // courtId -> isExpanded

  bool _isLoading = true;
  String? _errorMessage;
  List<Court> _allCourts = [];
  Map<String, List<UnavailableTimeSlot>> _venueAvailabilityMap = {}; // venueId -> slots

  @override
  void initState() {
    super.initState();
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    _selectedDate = DateTime(nowWib.year, nowWib.month, nowWib.day);
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courts = await AppConfig.courtRepository.getAllCourts();
      if (!mounted) return;

      final venueIds = courts.map((c) => c.venue.id).toSet();
      final map = <String, List<UnavailableTimeSlot>>{};

      for (final venueId in venueIds) {
        final slots = await AppConfig.bookingRepository.getVenueAvailability(
          venueId: venueId,
          date: _selectedDate,
        );
        map[venueId] = slots;
      }

      if (!mounted) return;

      setState(() {
        _allCourts = courts;
        _venueAvailabilityMap = map;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final isNet = isNetworkError(e) || e is BookingNetworkException;
      setState(() {
        _isLoading = false;
        _errorMessage = isNet
            ? 'Gagal memuat jadwal. Periksa jaringan internet Anda.'
            : 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      });
    }
  }

  void _onCategoryTapped(String category) {
    setState(() {
      if (_selectedCategory?.toLowerCase() == category.toLowerCase()) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  List<Court> _filterCourts(List<Court> allCourts) {
    if (_selectedCategory == null) return allCourts;
    return allCourts
        .where((c) => c.category.toLowerCase() == _selectedCategory!.toLowerCase())
        .toList();
  }

  List<_MergedSlotRange> _getSlotsForCourt(Court court, DateTime date) {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final todayWib = DateTime(nowWib.year, nowWib.month, nowWib.day);
    final isToday = date.year == todayWib.year &&
        date.month == todayWib.month &&
        date.day == todayWib.day;

    int cutoffHour = AppConstants.operationalStartHour;
    if (isToday) {
      final lead = nowWib.add(const Duration(minutes: AppConstants.minBookingLeadTimeMinutes));
      if (lead.minute == 0 && lead.second == 0 && lead.millisecond == 0) {
        cutoffHour = lead.hour;
      } else {
        cutoffHour = lead.hour + 1;
      }
    }

    final venueSlots = _venueAvailabilityMap[court.venue.id] ?? [];
    final courtSlots = venueSlots.where((s) => s.courtId == null || s.courtId == court.id).toList();

    final List<_HourlySlotStatus> hourlyStatuses = [];

    for (int h = AppConstants.operationalStartHour; h < AppConstants.operationalEndHour; h++) {
      UnavailableTimeSlot? matchingSlot;
      for (final slot in courtSlots) {
        if (h >= slot.startHour && h < slot.endHour) {
          matchingSlot = slot;
          break;
        }
      }

      if (matchingSlot != null) {
        if (matchingSlot.statusType == SlotStatusType.booked) {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Dipesan', type: 'danger'));
        } else if (matchingSlot.statusType == SlotStatusType.onHold) {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Belum Bayar', type: 'warning'));
        } else if (matchingSlot.statusType == SlotStatusType.closed) {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Ditutup', type: 'neutral'));
        } else {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Ditutup', type: 'neutral'));
        }
      } else {
        if (isToday && h < cutoffHour) {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Terlewat', type: 'neutral'));
        } else {
          hourlyStatuses.add(_HourlySlotStatus(hour: h, status: 'Tersedia', type: 'success'));
        }
      }
    }

    final List<_MergedSlotRange> mergedSlots = [];
    if (hourlyStatuses.isEmpty) return mergedSlots;

    int startH = hourlyStatuses[0].hour;
    String currentStatus = hourlyStatuses[0].status;
    String currentType = hourlyStatuses[0].type;

    for (int i = 1; i < hourlyStatuses.length; i++) {
      final item = hourlyStatuses[i];
      if (item.status != currentStatus || item.type != currentType) {
        mergedSlots.add(_MergedSlotRange(
          startHour: startH,
          endHour: item.hour,
          status: currentStatus,
          type: currentType,
        ));
        startH = item.hour;
        currentStatus = item.status;
        currentType = item.type;
      }
    }

    mergedSlots.add(_MergedSlotRange(
      startHour: startH,
      endHour: AppConstants.operationalEndHour,
      status: currentStatus,
      type: currentType,
    ));

    return mergedSlots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final baseBg = theme.scaffoldBackgroundColor;
    final cardBg = colors.surfaceCard;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final borderColor = colors.borderDefault;

    final warningBg = colors.warningBackground;
    final warningFg = colors.warningForeground;

    final filteredCourts = _filterCourts(_allCourts);

    return Scaffold(
      backgroundColor: baseBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingXLarge,
            vertical: AppTheme.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Header
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(100.0),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        AppIcons.arrowLeft,
                        width: 20.0,
                        height: 20.0,
                        colorFilter: ColorFilter.mode(
                          textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'Jadwal Lapangan',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 19.0,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 2. Date Picker (AppCalendar)
              AppCalendar(
                selectedDate: _selectedDate,
                minDate: DateTime(2000, 1, 1),
                maxDate: DateTime(2100, 12, 31),
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadScheduleData();
                },
              ),
              const SizedBox(height: 16.0),

              // 3. Sport Category Filter Chips
              Row(
                children: [
                  Expanded(
                    child: CategoryFilterChip(
                      iconPath: AppIcons.soccerBall,
                      label: 'Futsal',
                      isSelected: _selectedCategory?.toLowerCase() == 'futsal',
                      onTap: () => _onCategoryTapped('Futsal'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: CategoryFilterChip(
                      iconPath: AppIcons.volleyball,
                      label: 'Voli',
                      isSelected: _selectedCategory?.toLowerCase() == 'voli',
                      onTap: () => _onCategoryTapped('Voli'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: CategoryFilterChip(
                      iconPath: AppIcons.basketBall,
                      label: 'Basket',
                      isSelected: _selectedCategory?.toLowerCase() == 'basket',
                      onTap: () => _onCategoryTapped('Basket'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: CategoryFilterChip(
                      iconPath: AppIcons.shuttlecock,
                      label: 'Badminton',
                      isSelected: _selectedCategory?.toLowerCase() == 'badminton',
                      onTap: () => _onCategoryTapped('Badminton'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // 4. Section Title
              Text(
                'Jadwal harian',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 17.0,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 16.0),

              // 5. Loading / Error / Courts Schedule Cards
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                AppInfoNotice(
                  message: _errorMessage!,
                  variant: AppInfoNoticeVariant.danger,
                  iconPath: AppIcons.circleAlert,
                )
              else
                ...filteredCourts.map((court) {
                  final isExpanded = _expandedCourts[court.id] ?? false;
                  final slots = _getSlotsForCourt(court, _selectedDate);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Court Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    court.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    court.formattedPrice,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11.0,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.building,
                                  width: 12.0,
                                  height: 12.0,
                                  colorFilter: ColorFilter.mode(
                                    textSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  court.venue.name,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),

                        // Expand / Collapse Toggle
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedCourts[court.id] = !isExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isExpanded ? 'Ringkas jadwal' : 'Lihat jadwal',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11.0,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                                RotatedBox(
                                  quarterTurns: isExpanded ? 2 : 0,
                                  child: SvgPicture.asset(
                                    AppIcons.chevronDown,
                                    width: 16.0,
                                    height: 16.0,
                                    colorFilter: ColorFilter.mode(
                                      textSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded Booking List
                        if (isExpanded) ...[
                          const SizedBox(height: 12.0),
                          ...slots.map((slot) {
                            final startH = slot.startHour;
                            final endH = slot.endHour;
                            final status = slot.status;
                            final type = slot.type;

                            final startStr = startH < 10 ? '0$startH.00' : '$startH.00';
                            final endStr = endH < 10 ? '0$endH.00' : '$endH.00';
                            final timeText = '$startStr – $endStr WIB';

                            Color badgeBg;
                            Color badgeFg;
                            if (type == 'success') {
                              badgeBg = colors.successBackground;
                              badgeFg = colors.successForeground;
                            } else if (type == 'danger') {
                              badgeBg = colors.dangerBackground;
                              badgeFg = colors.dangerForeground;
                            } else if (type == 'warning') {
                              badgeBg = colors.warningBackground;
                              badgeFg = colors.warningForeground;
                            } else {
                              badgeBg = colors.neutralBackground;
                              badgeFg = colors.neutralForeground;
                            }

                            final isClickable = type == 'success';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isClickable
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourtDetailScreen(
                                                court: court,
                                                initialDate: _selectedDate,
                                                initialStartHour: startH,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            timeText,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.0,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(100.0),
                                          ),
                                          child: Text(
                                            status,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10.0,
                                              color: badgeFg,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8.0),

              // 6. Aturan Penahanan Slot Banner
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: warningBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppIcons.clock,
                      width: 18.0,
                      height: 18.0,
                      colorFilter: ColorFilter.mode(
                        warningFg,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum dibayar? Slot tetap ditahan.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                              color: warningFg,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            'Pesanan belum dibayar menahan slot selama maksimal 2 jam sejak dibuat. Pembayaran berhasil mengonfirmasi slot; jika batas waktu habis tanpa pembayaran, pesanan otomatis dibatalkan dan slot dilepas.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.0,
                              height: 1.5,
                              color: warningFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
