import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../data/court_repository.dart';
import '../../data/mock_data.dart';
import '../../models/booking.dart';
import '../../models/court.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/admin_booking_card.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_calendar.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dropdown_chip.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/sheet_action_buttons.dart';
import '../booking_detail_screen.dart';

/// Admin Screen for Booking Management (Manajemen Booking)
class AdminBookingsScreen extends StatefulWidget {
  final CourtRepository? courtRepository;

  const AdminBookingsScreen({
    super.key,
    this.courtRepository,
  });

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  late final CourtRepository _courtRepository;

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late DateTime _selectedDate;
  Court? _selectedCourt; // null = Semua lapangan
  BookingStatus? _selectedStatus; // null = Semua status (Batal includes dibatalkan)

  List<Booking> _adminBookings = [];
  List<Court> _adminCourts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _courtRepository = widget.courtRepository ?? AppConfig.courtRepository;
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final courts = await _courtRepository.getAdminCourts();
    final bookings = MockData.mockAdminBookings;
    if (!mounted) return;
    setState(() {
      _adminCourts = courts;
      _adminBookings = List.from(bookings);
      _isLoading = false;
    });
  }

  /// Calculates filtered and sorted list of admin bookings
  List<Booking> get _filteredAndSortedBookings {
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _adminBookings.where((booking) {
      // 1. Search Query Filter (spans all dates if search query present)
      if (hasSearch) {
        final matchesCode = booking.bookingCode.toLowerCase().contains(query);
        final matchesName = (booking.userName ?? '').toLowerCase().contains(query);
        if (!matchesCode && !matchesName) return false;
      } else {
        // Match selected date
        final bDate = booking.playDateTime;
        final isSameDate = bDate.year == _selectedDate.year &&
            bDate.month == _selectedDate.month &&
            bDate.day == _selectedDate.day;
        if (!isSameDate) return false;
      }

      // 2. Court Filter
      if (_selectedCourt != null) {
        if (booking.courtName.toLowerCase() != _selectedCourt!.name.toLowerCase()) {
          return false;
        }
      }

      // 3. Status Filter
      if (_selectedStatus != null) {
        if (booking.status != _selectedStatus) return false;
      }

      return true;
    }).toList();

    // Sorting logic:
    // Status weight: Belum bayar (1), Sudah bayar (2), Selesai (3), Dibatalkan (4)
    int statusWeight(BookingStatus status) {
      switch (status) {
        case BookingStatus.belumBayar:
          return 1;
        case BookingStatus.sudahBayar:
          return 2;
        case BookingStatus.selesai:
          return 3;
        case BookingStatus.dibatalkan:
          return 4;
      }
    }

    filtered.sort((a, b) {
      if (hasSearch) {
        // Cross-date search: newest play date first
        final dateCmp = b.playDateTime.compareTo(a.playDateTime);
        if (dateCmp != 0) return dateCmp;
      }

      // Within same date: Belum bayar -> Sudah bayar -> Selesai -> Dibatalkan
      final wA = statusWeight(a.status);
      final wB = statusWeight(b.status);
      if (wA != wB) return wA.compareTo(wB);

      // Same status: start time ascending
      return a.playDateTime.compareTo(b.playDateTime);
    });

    return filtered;
  }

  // --- FILTER BOTTOM SHEETS ---

  /// Opens Bottom Sheet for Date Selection
  void _openDateBottomSheet() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime tempDate = _selectedDate;

    showAppBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return AppBottomSheet(
              title: 'Tanggal',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCalendar(
                    isRangeMode: false,
                    selectedDate: tempDate,
                    minDate: DateTime(2020, 1, 1), // Allow past dates
                    maxDate: today.add(const Duration(days: 14)),
                    onDateSelected: (date) {
                      setSheetState(() {
                        tempDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  SheetActionButtons(
                    resetLabel: 'Reset',
                    applyLabel: 'Terapkan',
                    onReset: () {
                      setSheetState(() {
                        tempDate = today;
                      });
                    },
                    onApply: () {
                      setState(() {
                        _selectedDate = tempDate;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Opens Bottom Sheet for Court Selection (Figma 935:1526)
  void _openCourtBottomSheet() {
    Court? tempCourt = _selectedCourt;

    showAppBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return AppBottomSheet(
              title: 'Lapangan',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2-column grid for courts
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _adminCourts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 2.8,
                    ),
                    itemBuilder: (context, index) {
                      final court = _adminCourts[index];
                      final isSelected = tempCourt?.id == court.id;

                      return AppChip(
                        label: court.name,
                        isSelected: isSelected,
                        onTap: () {
                          setSheetState(() {
                            tempCourt = isSelected ? null : court;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  SheetActionButtons(
                    resetLabel: 'Reset',
                    applyLabel: 'Terapkan',
                    onReset: () {
                      setSheetState(() {
                        tempCourt = null;
                      });
                    },
                    onApply: () {
                      setState(() {
                        _selectedCourt = tempCourt;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Opens Bottom Sheet for Booking Status Selection (Figma 937:1940)
  void _openStatusBottomSheet() {
    BookingStatus? tempStatus = _selectedStatus;

    final options = [
      {'label': 'Selesai', 'status': BookingStatus.selesai},
      {'label': 'Sudah bayar', 'status': BookingStatus.sudahBayar},
      {'label': 'Belum bayar', 'status': BookingStatus.belumBayar},
      {'label': 'Batal', 'status': BookingStatus.dibatalkan},
    ];

    showAppBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return AppBottomSheet(
              title: 'Status Booking',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2x2 Grid for status options
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 2.8,
                    ),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final statusVal = option['status'] as BookingStatus;
                      final label = option['label'] as String;
                      final isSelected = tempStatus == statusVal;

                      return AppChip(
                        label: label,
                        isSelected: isSelected,
                        onTap: () {
                          setSheetState(() {
                            tempStatus = isSelected ? null : statusVal;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  SheetActionButtons(
                    resetLabel: 'Reset',
                    applyLabel: 'Terapkan',
                    onReset: () {
                      setSheetState(() {
                        tempStatus = null;
                      });
                    },
                    onApply: () {
                      setState(() {
                        _selectedStatus = tempStatus;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final dateChipLabel = '${_selectedDate.day} ${DateFormatHelper.shortMonthNames[_selectedDate.month - 1]}';
    final courtChipLabel = _selectedCourt?.name ?? 'Semua lapangan';

    String statusChipLabel = 'Semua status';
    if (_selectedStatus != null) {
      switch (_selectedStatus!) {
        case BookingStatus.selesai:
          statusChipLabel = 'Selesai';
          break;
        case BookingStatus.sudahBayar:
          statusChipLabel = 'Sudah bayar';
          break;
        case BookingStatus.belumBayar:
          statusChipLabel = 'Belum bayar';
          break;
        case BookingStatus.dibatalkan:
          statusChipLabel = 'Batal';
          break;
      }
    }

    final displayedBookings = _filteredAndSortedBookings;
    final hasSearch = _searchQuery.trim().isNotEmpty;

    final infoRowText = hasSearch
        ? 'Hasil pencarian • ${displayedBookings.length} booking'
        : '${_selectedDate.day} ${DateFormatHelper.monthNames[_selectedDate.month - 1]} ${_selectedDate.year} • ${displayedBookings.length} booking';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: AppTheme.paddingSmall,
              ),
              child: const AppHeader(
                title: 'Manajemen Booking',
                showNotificationBell: true,
              ),
            ),

            // Scrollable Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingXLarge,
                        vertical: 8.0,
                      ),
                      children: [
                        // Search Bar
                        SearchBarWidget(
                          hintText: 'Cari ID booking atau nama...',
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12.0),

                        // Dropdown Chips Filter Row
                        Row(
                          children: [
                            DropdownChip(
                              label: dateChipLabel,
                              isActive: false, // Always shows current date
                              onTap: _openDateBottomSheet,
                            ),
                            const SizedBox(width: 6.0),
                            DropdownChip(
                              label: courtChipLabel,
                              isActive: _selectedCourt != null,
                              onTap: _openCourtBottomSheet,
                            ),
                            const SizedBox(width: 6.0),
                            DropdownChip(
                              label: statusChipLabel,
                              isActive: _selectedStatus != null,
                              onTap: _openStatusBottomSheet,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),

                        // Date & Booking Count Info Header
                        Text(
                          infoRowText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.0,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Bookings List or Empty State
                        if (displayedBookings.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: Text(
                                'Tidak ada booking',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ...displayedBookings.map((booking) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: AdminBookingCard(
                                booking: booking,
                                onViewDetail: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingDetailScreen(
                                        booking: booking,
                                        isAdminView: true,
                                      ),
                                    ),
                                  );
                                },
                                onCancel: booking.status == BookingStatus.belumBayar
                                    ? () {
                                        // Batalkan on Belum bayar does nothing (modal batalkan not built yet)
                                      }
                                    : null,
                              ),
                            );
                          }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
