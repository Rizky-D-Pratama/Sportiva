import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import '../constants/app_icons.dart';
import '../data/booking_repository.dart';
import '../data/mock_data.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import '../widgets/app_image.dart';
import '../widgets/app_info_notice.dart';
import '../widgets/app_info_row.dart';
import '../widgets/app_modal.dart';
import '../widgets/app_sticky_bottom_bar.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Court court;
  final DateTime selectedDate;
  final int startHour;
  final int durationHours;

  static const int serviceFee = 5000;

  const BookingSummaryScreen({
    super.key,
    required this.court,
    required this.selectedDate,
    required this.startHour,
    required this.durationHours,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;

  String _formatNumber(int number) {
    final buffer = StringBuffer();
    final priceStr = number.toString();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dayName = days[(date.weekday - 1) % 7];
    final monthName = months[date.month];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  Future<void> _handleCreateBooking() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final booking = await AppConfig.bookingRepository.createBooking(
        court: widget.court,
        date: widget.selectedDate,
        startHour: widget.startHour,
        durationHours: widget.durationHours,
      );

      if (!mounted) return;

      // Correction #5: Insert into MockData.mockBookings only if ID is not already present
      if (!MockData.mockBookings.any((b) => b.id == booking.id)) {
        MockData.mockBookings.insert(0, booking);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: AppInfoNotice(
            message: 'Booking berhasil dibuat. Silakan selesaikan pembayaran.',
            iconPath: AppIcons.circleCheck,
          ),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } on BookingUnavailableException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Show single button confirmation modal as specified in Note 9
      await AppModal.show(
        context: context,
        title: 'Waktu Tidak Tersedia',
        message: 'Waktu ini sudah tidak tersedia. Silakan pilih waktu lain.',
        primaryButtonLabel: 'Pilih Waktu Lain',
        onPrimaryPressed: () {
          Navigator.pop(context); // Close modal
          Navigator.pop(context, true); // Pop summary screen with result true
        },
      );
    } on BookingNetworkException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Koneksi terputus. Periksa jaringan internet Anda.';
      });
    } on BookingServerException {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final baseBg = theme.scaffoldBackgroundColor;
    final cardBg = colors.surfaceCard;
    final borderColor = colors.borderDefault;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;

    final subtotal = widget.court.pricePerHour * widget.durationHours;
    final totalPayment = subtotal + BookingSummaryScreen.serviceFee;
    final formattedStartTime = '${widget.startHour.toString().padLeft(2, '0')}.00';
    final facilitiesText = widget.court.facilities.join(' • ');

    return Scaffold(
      backgroundColor: baseBg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Header
            Container(
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isSubmitting ? null : () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      AppIcons.arrowLeft,
                      width: 20.0,
                      height: 20.0,
                      colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'Ringkasan Booking',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card (Court Info)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(color: borderColor, width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(32, 40, 32, 0.03),
                            blurRadius: 16.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: SizedBox(
                              width: 76.0,
                              height: 80.0,
                              child: AppImage(
                                imagePath: widget.court.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.court.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  facilitiesText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textSecondary,
                                    fontSize: 10.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Rp${_formatNumber(widget.court.pricePerHour)}/jam',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),

                    // Date & Time Input (Read-only)
                    AppField(label: 'Tanggal booking', child: Text(_formatDate(widget.selectedDate))),
                    const SizedBox(height: 15.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: AppField(label: 'Jam mulai', child: Text(formattedStartTime))),
                        const SizedBox(width: 12.0),
                        Expanded(child: AppField(label: 'Durasi', child: Text('${widget.durationHours} jam'))),
                      ],
                    ),
                    const SizedBox(height: 15.0),

                    // Payment Summary Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(color: borderColor, width: 1.0),
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
                            'Rincian biaya',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Harga per jam',
                            value: 'Rp${_formatNumber(widget.court.pricePerHour)}',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Durasi',
                            value: '${widget.durationHours} jam × Rp${_formatNumber(widget.court.pricePerHour)}',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Subtotal',
                            value: 'Rp${_formatNumber(subtotal)}',
                          ),
                          const SizedBox(height: 8.0),
                          AppInfoRow(
                            label: 'Biaya layanan',
                            value: 'Rp${_formatNumber(BookingSummaryScreen.serviceFee)}',
                          ),
                          const SizedBox(height: 12.0),
                          Divider(color: borderColor, height: 1.0),
                          const SizedBox(height: 12.0),
                          AppInfoRow(
                            label: 'Total pembayaran',
                            value: 'Rp${_formatNumber(totalPayment)}',
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Helper text below payment summary card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'Metode pembayaran dipilih di langkah berikutnya.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Actions Bar
            AppStickyBottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    AppInfoNotice(
                      message: _errorMessage!,
                      variant: AppInfoNoticeVariant.danger,
                      iconPath: AppIcons.circleAlert,
                    ),
                    const SizedBox(height: 8.0),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        'Rp${_formatNumber(totalPayment)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  AppButton(
                    label: 'Lanjutkan Pembayaran',
                    onPressed: _isSubmitting ? null : _handleCreateBooking,
                    trailingIconPath: AppIcons.arrowRight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
