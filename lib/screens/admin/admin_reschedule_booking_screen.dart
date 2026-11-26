import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_icons.dart';
import '../../data/booking_repository.dart';
import '../../models/booking.dart';
import '../../models/reschedule_option.dart';
import '../../models/unavailable_time_slot.dart';
import '../../theme/app_theme.dart';
import '../../utils/booking_error_handler.dart';
import '../../utils/date_format_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_calendar.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_info_notice.dart';
import '../../widgets/app_info_row.dart';
import '../../widgets/app_modal.dart';
import '../../widgets/app_sticky_bottom_bar.dart';
import '../../widgets/time_select_bottom_sheet.dart';

/// Screen for Admin to reschedule a paid booking ("Ubah Jadwal")
class AdminRescheduleBookingScreen extends StatefulWidget {
  final Booking booking;

  const AdminRescheduleBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<AdminRescheduleBookingScreen> createState() =>
      _AdminRescheduleBookingScreenState();
}

class _AdminRescheduleBookingScreenState
    extends State<AdminRescheduleBookingScreen> {
  late DateTime _initialDate;
  late int _initialStartHour;

  late DateTime _selectedDate;
  int? _selectedStartHour;

  List<RescheduleOption> _options = [];
  bool _isLoadingOptions = true;
  String? _optionsError;
  int _optionsRequestId = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final playDt = widget.booking.playDateTime;
    _initialDate = DateTime(playDt.year, playDt.month, playDt.day);
    _initialStartHour = playDt.hour;

    _selectedDate = _initialDate;
    _selectedStartHour = _initialStartHour;

    _fetchRescheduleOptions();
  }

  Future<void> _fetchRescheduleOptions() async {
    final requestId = ++_optionsRequestId;
    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });

    try {
      final options = await AppConfig.bookingRepository.getRescheduleOptions(
        bookingId: widget.booking.id,
        date: _selectedDate,
      );

      if (!mounted || requestId != _optionsRequestId) return;

      setState(() {
        _options = options;
        _isLoadingOptions = false;

        // Preserve selected hour if it is still available on the new date
        if (_selectedStartHour != null) {
          final isAvailable = options.any(
            (o) => o.jamMulai == _selectedStartHour && o.tersedia,
          );
          if (!isAvailable) {
            _selectedStartHour = null;
          }
        }
      });
    } on BookingNetworkException {
      if (!mounted || requestId != _optionsRequestId) return;
      setState(() {
        _optionsError = 'Koneksi terputus. Gagal memuat jam tersedia.';
        _isLoadingOptions = false;
      });
    } catch (_) {
      if (!mounted || requestId != _optionsRequestId) return;
      setState(() {
        _optionsError = 'Gagal memuat jadwal tersedia.';
        _isLoadingOptions = false;
      });
    }
  }

  void _openTimeSelectBottomSheet() {
    if (_isLoadingOptions) return;

    final maxH = AppConstants.operationalEndHour - widget.booking.durationHours;

    final unavailableSlots = _options.where((o) => !o.tersedia).map((o) {
      String noteText = 'Tidak tersedia';
      if (o.alasan != null) {
        noteText = switch (o.alasan!) {
          RescheduleReason.dipesan => 'Dipesan',
          RescheduleReason.ditutup => 'Ditutup',
          RescheduleReason.terlaluDekat => 'Terlalu dekat',
          RescheduleReason.tanggalTidakValid => 'Tanggal tidak valid',
          RescheduleReason.lapanganNonaktif => 'Lapangan nonaktif',
          RescheduleReason.unknown => 'Tidak tersedia',
        };
      }
      return UnavailableTimeSlot(
        courtId: null,
        startHour: o.jamMulai,
        endHour: o.jamMulai + 1,
        statusLabel: 'Tidak tersedia',
        note: noteText,
        statusType: SlotStatusType.closed,
        sourceMark: SlotSourceMark.court,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimeSelectBottomSheet(
          selectedDate: _selectedDate,
          unavailableSlots: unavailableSlots,
          maxHour: maxH > AppConstants.operationalStartHour ? maxH : AppConstants.operationalEndHour,
          onTimeSelected: (hour) {
            setState(() {
              _selectedStartHour = hour;
            });
          },
        );
      },
    );
  }

  bool get _isSameSchedule {
    return _selectedDate.year == _initialDate.year &&
        _selectedDate.month == _initialDate.month &&
        _selectedDate.day == _initialDate.day &&
        _selectedStartHour == _initialStartHour;
  }

  bool get _isButtonEnabled {
    return _selectedStartHour != null &&
        !_isLoadingOptions &&
        !_isSubmitting &&
        !_isSameSchedule;
  }

  void _showConfirmationModal() {
    if (!_isButtonEnabled || _selectedStartHour == null) return;

    final initialDateStr = DateFormatHelper.formatShortDate(_initialDate);
    final initialEndH = _initialStartHour + widget.booking.durationHours;
    final initialScheduleStr =
        '$initialDateStr, ${_initialStartHour.toString().padLeft(2, '0')}.00 – ${initialEndH.toString().padLeft(2, '0')}.00 WIB';

    final newDateStr = DateFormatHelper.formatShortDate(_selectedDate);
    final newEndH = _selectedStartHour! + widget.booking.durationHours;
    final newScheduleStr =
        '$newDateStr, ${_selectedStartHour!.toString().padLeft(2, '0')}.00 – ${newEndH.toString().padLeft(2, '0')}.00 WIB';

    AppModal.show(
      context: context,
      iconPath: AppIcons.circleAlert,
      iconColor: context.appColors.brandPrimary,
      title: 'Ubah jadwal pemesanan?',
      message:
          'Jadwal akan diubah dari $initialScheduleStr menjadi $newScheduleStr. Pelanggan dapat melihat perubahan ini di pesanannya.',
      primaryButtonLabel: 'Ya, ubah',
      onPrimaryPressed: () {
        Navigator.pop(context);
        _submitReschedule();
      },
      secondaryButtonLabel: 'Kembali',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> _submitReschedule() async {
    if (_selectedStartHour == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AppConfig.bookingRepository.rescheduleBooking(
        bookingId: widget.booking.id,
        date: _selectedDate,
        startHour: _selectedStartHour!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on BookingUnavailableException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _selectedStartHour = null;
      });
      final msg = e.errorCode == 'BK002'
          ? 'Jam mulai terlalu dekat dengan waktu sekarang.'
          : e.errorCode == 'BK004'
              ? 'Lapangan tidak aktif.'
              : 'Slot sudah terisi. Pilih jam lain.';
      _showSnackBarNotice(msg);
      _fetchRescheduleOptions();
    } on BookingSlotClosedException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _selectedStartHour = null;
      });
      _showSnackBarNotice('Slot sedang ditutup.');
      _fetchRescheduleOptions();
    } on BookingDateOutOfRangeException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBarNotice('Tanggal di luar rentang yang diizinkan.');
    } on BookingInvalidInputException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBarNotice('Data jadwal tidak valid.');
    } on BookingNotReschedulableException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBarNotice('Booking ini tidak dapat dijadwal ulang.');
      Navigator.pop(context, true);
    } on BookingNotFoundException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBarNotice('Booking tidak ditemukan.');
    } on BookingNotAdminException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBarNotice('Akun ini tidak memiliki akses admin.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      await BookingErrorHandler.showErrorDialog(context, e);
    }
  }

  void _showSnackBarNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: AppInfoNotice(
          message: message,
          variant: AppInfoNoticeVariant.danger,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 14));

    final selectedStartStr = _selectedStartHour != null
        ? '${_selectedStartHour!.toString().padLeft(2, '0')}.00'
        : 'Pilih jam mulai';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingXLarge,
                vertical: 12.0,
              ),
              child: AppHeader(
                title: 'Ubah Jadwal',
                showBackButton: true,
                onBackTap: () => Navigator.maybePop(context),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingXLarge,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Ringkasan Booking Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                            color: colors.borderDefault, width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(32, 40, 32, 0.03),
                            blurRadius: 16.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.bookingCode,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            widget.booking.courtName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Jadwal saat ini',
                            value:
                                '${widget.booking.date} • ${widget.booking.timeRange}',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Durasi',
                            value: '${widget.booking.durationHours} jam',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Pemesan',
                            value: widget.booking.userName ?? '-',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Nomor telepon',
                            value: widget.booking.userPhone ?? '-',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Info Notice Admin
                    const AppInfoNotice(
                      message:
                          'Pelanggan tidak dapat membatalkan pemesanan yang sudah dibayar. Hubungi pelanggan dan pastikan jadwal baru disetujui sebelum menyimpan.',
                      variant: AppInfoNoticeVariant.success,
                    ),
                    const SizedBox(height: 16.0),

                    // 3. AppCalendar (1 tanggal)
                    AppCalendar(
                      isRangeMode: false,
                      selectedDate: _selectedDate,
                      minDate: today,
                      maxDate: maxDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                        _fetchRescheduleOptions();
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // 4. Field "Jam mulai"
                    AppField(
                      label: 'Jam mulai',
                      onTap: _openTimeSelectBottomSheet,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedStartStr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _selectedStartHour != null
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ),
                          ),
                          if (_isLoadingOptions)
                            const SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                            ),
                        ],
                      ),
                    ),
                    if (_optionsError != null) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        _optionsError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.dangerForeground,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bar
            AppStickyBottomBar(
              child: AppButton(
                label: 'Simpan Perubahan',
                onPressed: _isButtonEnabled ? _showConfirmationModal : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
