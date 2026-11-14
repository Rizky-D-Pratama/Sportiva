import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_icons.dart';
import '../../data/court_repository.dart';
import '../../data/mock_data.dart';
import '../../models/court.dart';
import '../../models/unavailable_time_slot.dart';
import '../../models/venue_closure.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/app_calendar.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_info_notice.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_radio.dart';
import '../../widgets/closure_scope_bottom_sheet.dart';
import '../../widgets/time_select_bottom_sheet.dart';
import '../../widgets/unavailable_time_row.dart';

enum DurationOption {
  fullDay,
  specificHours,
}

/// Admin Screen for Schedule & Closure Management ("Manajemen Jadwal")
class AdminScheduleScreen extends StatefulWidget {
  final CourtRepository? courtRepository;

  const AdminScheduleScreen({
    super.key,
    this.courtRepository,
  });

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  late final CourtRepository _repository;
  final String _venueName = MockData.sportivaCenter.name;

  List<Court> _adminCourts = [];
  bool _isLoadingCourts = true;

  // Selected Scope: null = Seluruh Venue, otherwise courtId
  String? _selectedCourtId;

  // Selected Date on Inline Calendar
  late DateTime _selectedDate;

  // State Data
  List<UnavailableTimeSlot> _mergedSlots = [];
  List<VenueClosure> _venueClosures = [];
  bool _isFullDayVenueClosed = false;
  bool _isFullDayCourtClosed = false;

  // Form State
  DurationOption _durationOption = DurationOption.fullDay;
  int? _startHour;
  int? _endHour;
  final TextEditingController _reasonController = TextEditingController();

  // Validation Errors
  String? _startHourError;
  String? _endHourError;
  String? _reasonError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.courtRepository ?? FakeCourtRepository();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    _loadInitialData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Court? get _selectedCourt {
    if (_selectedCourtId == null || _selectedCourtId!.isEmpty) return null;
    return _adminCourts.firstWhere(
      (c) => c.id == _selectedCourtId,
      orElse: () => _adminCourts.first,
    );
  }

  bool get _isWholeVenueScope => _selectedCourtId == null || _selectedCourtId!.isEmpty;

  Future<void> _loadInitialData() async {
    final courts = await _repository.getAdminCourts();
    if (!mounted) return;
    setState(() {
      _adminCourts = courts;
      _isLoadingCourts = false;
    });
    _fetchScheduleData();
  }

  Future<void> _fetchScheduleData() async {
    final date = _selectedDate;
    final venueId = MockData.sportivaCenter.id;

    if (_isWholeVenueScope) {
      final closures = await _repository.getVenueClosures(
        venueId: venueId,
        date: date,
      );
      final isFullDayV = await _repository.isFullDayVenueClosed(
        venueId: venueId,
        date: date,
      );

      if (!mounted) return;
      setState(() {
        _venueClosures = closures;
        _isFullDayVenueClosed = isFullDayV;
        _isFullDayCourtClosed = false;
        _mergedSlots = [];
      });
    } else {
      final slots = await _repository.getMergedUnavailableSlots(
        courtId: _selectedCourtId!,
        date: date,
      );
      final isFullDayV = await _repository.isFullDayVenueClosed(
        venueId: venueId,
        date: date,
      );
      final isFullDayC = await _repository.isFullDayCourtClosed(
        courtId: _selectedCourtId!,
        date: date,
      );

      if (!mounted) return;
      setState(() {
        _mergedSlots = slots;
        _isFullDayVenueClosed = isFullDayV;
        _isFullDayCourtClosed = isFullDayC;
        _venueClosures = [];
      });
    }
  }

  void _resetFormFields() {
    setState(() {
      _startHour = null;
      _endHour = null;
      _reasonController.clear();
      _durationOption = DurationOption.fullDay;
      _startHourError = null;
      _endHourError = null;
      _reasonError = null;
    });
  }

  void _onScopeTap() async {
    final result = await ClosureScopeBottomSheet.show(
      context: context,
      venueName: _venueName,
      courts: _adminCourts,
      selectedCourtId: _selectedCourtId,
    );

    if (result != null && mounted) {
      if (result.courtId != _selectedCourtId) {
        setState(() {
          _selectedCourtId = result.courtId;
        });
        _resetFormFields();
        _fetchScheduleData();
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    _resetFormFields();
    _fetchScheduleData();
  }

  void _openStartHourSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimeSelectBottomSheet(
        title: 'Pilih jam mulai',
        selectedDate: _selectedDate,
        unavailableSlots: const [],
        minHour: AppConstants.operationalStartHour,
        maxHour: AppConstants.operationalEndHour - 1,
        onTimeSelected: (hour) {
          setState(() {
            _startHour = hour;
            _startHourError = null;
            if (_endHour != null && _endHour! <= hour) {
              _endHour = null;
            }
          });
        },
      ),
    );
  }

  void _openEndHourSheet() {
    if (_startHour == null) {
      setState(() {
        _startHourError = 'Pilih jam mulai terlebih dahulu.';
      });
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimeSelectBottomSheet(
        title: 'Pilih jam selesai',
        selectedDate: _selectedDate,
        unavailableSlots: const [],
        minHour: AppConstants.operationalStartHour + 1,
        maxHour: AppConstants.operationalEndHour,
        restrictAfterHour: _startHour,
        onTimeSelected: (hour) {
          setState(() {
            _endHour = hour;
            _endHourError = null;
          });
        },
      ),
    );
  }

  Future<void> _submitClosureForm() async {
    if (_isSubmitting) return;

    String? startErr;
    String? endErr;
    String? reasonErr;

    final isFullDaySubmit = _isWholeVenueScope && _durationOption == DurationOption.fullDay;

    final effectiveStartHour = isFullDaySubmit
        ? AppConstants.operationalStartHour
        : _startHour;
    final effectiveEndHour = isFullDaySubmit
        ? AppConstants.operationalEndHour
        : _endHour;
    final reasonTrimmed = _reasonController.text.trim();

    if (!isFullDaySubmit) {
      if (effectiveStartHour == null) {
        startErr = 'Pilih jam mulai.';
      }
      if (effectiveEndHour == null) {
        endErr = 'Pilih jam selesai.';
      } else if (effectiveStartHour != null && effectiveEndHour <= effectiveStartHour) {
        endErr = 'Jam selesai harus setelah jam mulai.';
      }
    }

    if (reasonTrimmed.isEmpty) {
      reasonErr = 'Alasan wajib diisi.';
    }

    if (startErr != null || endErr != null || reasonErr != null) {
      setState(() {
        _startHourError = startErr;
        _endHourError = endErr;
        _reasonError = reasonErr;
      });
      return;
    }

    // Periksa overlapping penutupan pada cakupan yang SAMA
    final hasOverlap = await _repository.hasOverlappingClosure(
      courtId: _selectedCourtId,
      date: _selectedDate,
      startHour: effectiveStartHour!,
      endHour: effectiveEndHour!,
    );

    if (hasOverlap && mounted) {
      setState(() {
        _endHourError = 'Waktu tersebut sudah ditutup.';
      });
      return;
    }

    // Periksa benturan dengan booking aktif
    final conflictCount = await _repository.countConflictingBookings(
      courtId: _selectedCourtId,
      date: _selectedDate,
      startHour: effectiveStartHour,
      endHour: effectiveEndHour,
    );

    if (!mounted) return;

    if (conflictCount > 0) {
      final confirm = await AppModal.show<bool>(
        context: context,
        iconPath: AppIcons.circleAlert,
        iconColor: context.appColors.dangerForeground,
        title: 'Ada Booking di Waktu Ini',
        message:
            'Ada $conflictCount booking pada waktu ini. Booking tidak dibatalkan otomatis; hubungi pelanggan untuk menjadwal ulang atau membatalkan.',
        primaryButtonLabel: 'Ya, Tutup',
        onPrimaryPressed: () => Navigator.pop(context, true),
        secondaryButtonLabel: 'Kembali',
        onSecondaryPressed: () => Navigator.pop(context, false),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final newClosure = VenueClosure(
      id: 'closure_${DateTime.now().millisecondsSinceEpoch}',
      venueId: MockData.sportivaCenter.id,
      courtId: _selectedCourtId,
      date: _selectedDate,
      startHour: effectiveStartHour,
      endHour: effectiveEndHour,
      reason: reasonTrimmed,
    );

    await _repository.addVenueClosure(newClosure);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AppInfoNotice(
          message: 'Penutupan disimpan.',
          iconPath: AppIcons.circleCheck,
        ),
        duration: Duration(seconds: 3),
      ),
    );

    _resetFormFields();
    setState(() {
      _isSubmitting = false;
    });
    _fetchScheduleData();
  }

  void _onReopenClosure(String closureId) async {
    final confirm = await AppModal.show<bool>(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: context.appColors.dangerForeground,
      title: 'Buka Kembali?',
      message: 'Waktu ini akan tersedia lagi untuk dibooking pengguna.',
      primaryButtonLabel: 'Ya, Buka',
      onPrimaryPressed: () => Navigator.pop(context, true),
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context, false),
    );

    if (confirm == true && mounted) {
      await _repository.deleteVenueClosure(closureId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AppInfoNotice(
            message: 'Penutupan dibuka kembali.',
            iconPath: AppIcons.circleCheck,
          ),
          duration: Duration(seconds: 3),
        ),
      );

      _fetchScheduleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: AppConstants.maxVenueClosureAdvanceDays));

    final scopeLabel = _isWholeVenueScope
        ? 'Seluruh $_venueName'
        : (_selectedCourt?.name ?? 'Arena Futsal A');

    final formattedDateLong = DateFormatHelper.formatFullDate(_selectedDate);

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
              child: AppHeader(
                title: 'Manajemen Jadwal',
                showBackButton: true,
                showNotificationBell: false,
                onBackTap: () => Navigator.of(context).pop(),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: _isLoadingCourts
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingXLarge,
                        vertical: AppTheme.paddingMedium,
                      ),
                      children: [
                        // 1. Input Cakupan Penutupan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppField(
                              label: 'Cakupan Penutupan',
                              trailingIconPath: AppIcons.chevronDown,
                              onTap: _onScopeTap,
                              child: Text(
                                scopeLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (_isWholeVenueScope) ...[
                              const SizedBox(height: 6.0),
                              Text(
                                'Penutupan berlaku untuk seluruh lapangan.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11.0,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),

                        // 2. AppCalendar (Inline Date Picker)
                        AppCalendar(
                          selectedDate: _selectedDate,
                          minDate: today,
                          maxDate: maxDate,
                          onDateSelected: _onDateSelected,
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),

                        // 3. Jam Operasional Read-Only
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam operasional',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '08.00 – 24.00',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.paddingLarge),

                        // 4. KARTU SESUAI CAKUPAN
                        if (_isWholeVenueScope) ...[
                          _buildWholeVenueClosureCard(colors, theme),
                          const SizedBox(height: AppTheme.paddingLarge),
                          _buildSetWholeVenueClosureCard(colors, theme, formattedDateLong),
                        ] else ...[
                          _buildCourtUnavailableSlotsCard(colors, theme),
                          const SizedBox(height: AppTheme.paddingLarge),
                          _buildSetCourtClosureCard(colors, theme, formattedDateLong),
                        ],

                        const SizedBox(height: 24.0),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILDERS FOR SELURUH VENUE ---

  Widget _buildWholeVenueClosureCard(AppCustomColors colors, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penutupan seluruh $_venueName',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),

          if (_venueClosures.isEmpty) ...[
            Text(
              'Belum ada penutupan seluruh $_venueName pada tanggal ini.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ] else ...[
            Column(
              children: _venueClosures.map((closure) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: UnavailableTimeRow(
                    timeRangeText: closure.timeRangeText,
                    statusLabel: 'Ditutup',
                    note: closure.reason,
                    statusType: SlotStatusType.closed,
                    onReopenTap: () => _onReopenClosure(closure.id),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 8.0),
          Text(
            'Booking dan penutupan tiap lapangan tetap berlaku.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetWholeVenueClosureCard(
    AppCustomColors colors,
    ThemeData theme,
    String formattedDateLong,
  ) {
    // If full day venue closure exists -> replace card with text
    if (_isFullDayVenueClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: colors.borderDefault, width: 1.0),
        ),
        child: Text(
          'Seluruh $_venueName ditutup seharian pada tanggal ini.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    final isSpecificHours = _durationOption == DurationOption.specificHours;

    String summaryHoursText;
    if (_durationOption == DurationOption.fullDay) {
      summaryHoursText = 'Sepanjang jam operasional, 08.00 – 24.00.';
    } else {
      if (_startHour != null && _endHour != null) {
        final startStr = _startHour! < 10 ? '0$_startHour.00' : '$_startHour.00';
        final endStr = _endHour! < 10 ? '0$_endHour.00' : '$_endHour.00';
        summaryHoursText = '$startStr – $endStr.';
      } else {
        summaryHoursText = '';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atur penutupan',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),

          // Radio options row
          Row(
            children: [
              AppRadioOption<DurationOption>(
                value: DurationOption.fullDay,
                groupValue: _durationOption,
                label: 'Tutup seharian',
                onChanged: (val) {
                  setState(() {
                    _durationOption = val;
                    _startHourError = null;
                    _endHourError = null;
                  });
                },
              ),
              const SizedBox(width: 16.0),
              AppRadioOption<DurationOption>(
                value: DurationOption.specificHours,
                groupValue: _durationOption,
                label: 'Jam tertentu',
                onChanged: (val) {
                  setState(() {
                    _durationOption = val;
                    _startHourError = null;
                    _endHourError = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Specific hours inputs
          if (isSpecificHours) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppField(
                    label: 'Jam mulai',
                    errorText: _startHourError,
                    onTap: _openStartHourSheet,
                    child: Text(
                      _startHour != null
                          ? '${_startHour!.toString().padLeft(2, '0')}.00'
                          : 'Pilih jam',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _startHour != null
                            ? colors.textPrimary
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: AppField(
                    label: 'Jam selesai',
                    errorText: _endHourError,
                    onTap: _openEndHourSheet,
                    child: Text(
                      _endHour != null
                          ? '${_endHour!.toString().padLeft(2, '0')}.00'
                          : 'Pilih jam',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _endHour != null
                            ? colors.textPrimary
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
          ],

          // Alasan penutupan
          AppField(
            label: 'Alasan penutupan',
            controller: _reasonController,
            hintText: 'Acara internal',
            maxLength: AppConstants.maxClosureReasonLength,
            errorText: _reasonError,
            onChanged: (_) {
              if (_reasonError != null) {
                setState(() => _reasonError = null);
              }
            },
          ),
          const SizedBox(height: 12.0),

          // Summary Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colors.successBackground,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seluruh lapangan • $formattedDateLong',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (summaryHoursText.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    summaryHoursText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 4.0),
                Text(
                  'Hanya tanggal ini; jam rutin tidak berubah.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          Text(
            'Sistem memeriksa benturan dengan booking terbayar dan pesanan yang masih ditahan pembayaran. Koordinasi dengan pelanggan jika terdapat benturan. Booking tidak otomatis dibatalkan.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0),

          // Submit Button
          InkWell(
            onTap: _isSubmitting ? null : _submitClosureForm,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: Container(
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                'Simpan penutupan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILDERS FOR PER LAPANGAN ---

  Widget _buildCourtUnavailableSlotsCard(AppCustomColors colors, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waktu tidak tersedia',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),

          if (_mergedSlots.isEmpty) ...[
            Text(
              'Semua waktu dalam jam operasional tersedia.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ] else ...[
            Column(
              children: _mergedSlots.map((slot) {
                final isCourtClosure = slot.statusType == SlotStatusType.closed &&
                    slot.sourceMark == SlotSourceMark.court &&
                    slot.closureId != null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: UnavailableTimeRow.fromSlot(
                    slot: slot,
                    onReopenTap: isCourtClosure
                        ? () => _onReopenClosure(slot.closureId!)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 8.0),
          Text(
            'Koordinasi dengan pelanggan jika ingin menutup pada jam diatas. Booking tidak otomatis dibatalkan.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCourtClosureCard(
    AppCustomColors colors,
    ThemeData theme,
    String formattedDateLong,
  ) {
    // Hidden rules:
    // (a) venue closed full day -> "Seluruh [nama venue] ditutup seharian pada tanggal ini."
    // (b) court closed full day -> "Lapangan ditutup seharian pada tanggal ini."
    // If both exist, use (a).
    if (_isFullDayVenueClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: colors.borderDefault, width: 1.0),
        ),
        child: Text(
          'Seluruh $_venueName ditutup seharian pada tanggal ini.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    if (_isFullDayCourtClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: colors.borderDefault, width: 1.0),
        ),
        child: Text(
          'Lapangan ditutup seharian pada tanggal ini.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    final courtName = _selectedCourt?.name ?? 'Arena Futsal A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tutup waktu',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '$courtName • $formattedDateLong',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0),

          // Form: Jam mulai & Jam selesai
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppField(
                  label: 'Jam mulai',
                  errorText: _startHourError,
                  onTap: _openStartHourSheet,
                  child: Text(
                    _startHour != null
                        ? '${_startHour!.toString().padLeft(2, '0')}.00'
                        : 'Pilih jam',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _startHour != null
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: AppField(
                  label: 'Jam selesai',
                  errorText: _endHourError,
                  onTap: _openEndHourSheet,
                  child: Text(
                    _endHour != null
                        ? '${_endHour!.toString().padLeft(2, '0')}.00'
                        : 'Pilih jam',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _endHour != null
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Alasan penutupan
          AppField(
            label: 'Alasan penutupan',
            controller: _reasonController,
            hintText: 'Perawatan',
            maxLength: AppConstants.maxClosureReasonLength,
            errorText: _reasonError,
            onChanged: (_) {
              if (_reasonError != null) {
                setState(() => _reasonError = null);
              }
            },
          ),
          const SizedBox(height: 12.0),

          // Submit Button
          InkWell(
            onTap: _isSubmitting ? null : _submitClosureForm,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            child: Container(
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                'Tutup waktu',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
