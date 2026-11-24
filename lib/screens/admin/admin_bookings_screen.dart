import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../data/booking_repository.dart';
import '../../data/court_repository.dart';
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
import '../../widgets/app_search_bar.dart';
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
  Timer? _searchDebounce;
  String _searchQuery = '';

  late DateTime _selectedDate;
  Court? _selectedCourt; // null = Semua lapangan
  BookingStatus? _selectedStatus; // null = Semua status

  List<Booking> _adminBookings = [];
  List<Court> _adminCourts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _courtRepository = widget.courtRepository ?? AppConfig.courtRepository;
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String? _getStatusToken(BookingStatus? status) {
    if (status == null) return null;
    return switch (status) {
      BookingStatus.selesai => 'selesai',
      BookingStatus.sudahBayar => 'sudah_bayar',
      BookingStatus.belumBayar => 'belum_bayar',
      BookingStatus.dibatalkan => 'batal',
    };
  }

  Future<void> _loadInitialData() async {
    try {
      final courts = await _courtRepository.getAdminCourts();
      if (!mounted) return;
      setState(() {
        _adminCourts = courts;
      });
    } catch (_) {
      // Swallowed as courts list is non-critical for main list display
    }
    await _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statusToken = _getStatusToken(_selectedStatus);
      final query = _searchQuery.trim();

      final bookings = await AppConfig.bookingRepository.getAdminBookings(
        tanggal: query.isNotEmpty ? null : _selectedDate,
        courtId: _selectedCourt?.id,
        status: statusToken,
        search: query.isNotEmpty ? query : null,
      );

      if (!mounted) return;
      setState(() {
        _adminBookings = bookings;
        _isLoading = false;
      });
    } on BookingNetworkException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat booking. Periksa jaringan internet Anda.';
        _isLoading = false;
      });
    } on BookingNotAdminException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Akun ini tidak memiliki akses admin.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String val) {
    _searchDebounce?.cancel();
    _searchQuery = val;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _fetchBookings();
    });
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
                    minDate: DateTime(2020, 1, 1), // Allow past dates without lower bound
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
                      _fetchBookings();
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

  /// Opens Bottom Sheet for Court Selection
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
                      _fetchBookings();
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

  /// Opens Bottom Sheet for Booking Status Selection
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
                      _fetchBookings();
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

    final hasSearch = _searchQuery.trim().isNotEmpty;

    final infoRowText = hasSearch
        ? 'Hasil pencarian • ${_adminBookings.length} booking'
        : '${_selectedDate.day} ${DateFormatHelper.monthNames[_selectedDate.month - 1]} ${_selectedDate.year} • ${_adminBookings.length} booking';

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
              child: RefreshIndicator(
                onRefresh: _fetchBookings,
                color: colors.successForeground,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingXLarge,
                    vertical: 8.0,
                  ),
                  children: [
                    // Search Bar
                    AppSearchBar(
                      controller: _searchController,
                      hintText: 'Cari ID booking atau nama...',
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12.0),

                    // Dropdown Chips Filter Row
                    Row(
                      children: [
                        DropdownChip(
                          label: dateChipLabel,
                          isActive: false,
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

                    // Content State Handling
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Center(
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else if (_adminBookings.isEmpty)
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
                      ..._adminBookings.map((booking) {
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
                                    // Batalkan on Belum bayar does nothing
                                  }
                                : null,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
