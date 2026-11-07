import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../data/mock_data.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import '../widgets/app_calendar.dart';
import '../widgets/category_filter_chip.dart';
import 'court_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
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

  List<Map<String, dynamic>> _getSlotsForCourt(Court court, DateTime date) {
    // Standard schedule slots matching design and availability
    final List<Map<String, dynamic>> baseSlots = [
      {'start': 8, 'end': 9, 'status': 'Tersedia', 'type': 'success'},
      {'start': 9, 'end': 12, 'status': 'Dipesan', 'type': 'danger'},
      {'start': 12, 'end': 13, 'status': 'Belum Bayar', 'type': 'warning'},
      {'start': 13, 'end': 14, 'status': 'Ditutup', 'type': 'neutral'},
      {'start': 14, 'end': 21, 'status': 'Tersedia', 'type': 'success'},
    ];
    return baseSlots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final baseBg = theme.scaffoldBackgroundColor;
    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final textPrimary = customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary = customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;
    final borderColor = customColors?.borderDefault ?? theme.colorScheme.outline;
    
    const warningBg = Color(0xFFFFF3D9);
    const warningFg = Color(0xFF9A6B21);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

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
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
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

              // 5. Courts Schedule Cards
              ..._filterCourts(MockData.allCourts).map((court) {
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
                          final startH = slot['start'] as int;
                          final endH = slot['end'] as int;
                          final status = slot['status'] as String;
                          final type = slot['type'] as String;

                          // Time text formatting
                          final startStr = startH < 10 ? '0$startH.00' : '$startH.00';
                          final endStr = endH < 10 ? '0$endH.00' : '$endH.00';
                          final timeText = '$startStr – $endStr WIB';

                          // Today restriction check
                          bool isPastOrDimmed = false;
                          if (isToday && startH <= now.hour) {
                            isPastOrDimmed = true;
                          }

                          // Status badge styling
                          Color badgeBg;
                          Color badgeFg;
                          if (type == 'success') {
                            badgeBg = const Color(0xFFEDF8E8);
                            badgeFg = const Color(0xFF286B24);
                          } else if (type == 'danger') {
                            badgeBg = const Color(0xFFFDEDEE);
                            badgeFg = const Color(0xFFAB3E45);
                          } else if (type == 'warning') {
                            badgeBg = const Color(0xFFFFF3D9);
                            badgeFg = const Color(0xFF9A6B21);
                          } else {
                            badgeBg = const Color(0xFFF0F2EC);
                            badgeFg = const Color(0xFF777D75);
                          }

                          final isClickable = type == 'success' && !isPastOrDimmed;

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
                                child: Opacity(
                                  opacity: isPastOrDimmed ? 0.4 : 1.0,
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
