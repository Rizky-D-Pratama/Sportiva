import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_icons.dart';
import '../models/court.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

class BookingSummaryScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>();

    final baseBg = AppTheme.baseBackground;
    final cardBg = customColors?.cardBackground ?? theme.colorScheme.surface;
    final borderColor = customColors?.borderDefault ?? theme.colorScheme.outline;
    final textPrimary = customColors?.textPrimary ?? theme.colorScheme.onSurface;
    final textSecondary = customColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant;
    final primaryColor = theme.colorScheme.secondary;
    final onPrimaryColor = textPrimary;

    final subtotal = court.pricePerHour * durationHours;
    final totalPayment = subtotal + serviceFee;
    final formattedStartTime = '${startHour.toString().padLeft(2, '0')}.00';
    final facilitiesText = court.facilities.join(' • ');

    return Scaffold(
      backgroundColor: baseBg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Header (without bell icon as requested)
            Container(
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 19.0,
                      ),
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
                                imagePath: court.imageUrl,
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
                                  court.name,
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
                                  'Rp${_formatNumber(court.pricePerHour)}/jam',
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

                    // Date Input (Read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal booking',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 46.0),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: borderColor, width: 1.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDate(selectedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textPrimary,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),

                    // Time Input Row (Start time & Duration, Read-only)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jam mulai',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 46.0),
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: borderColor, width: 1.0),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  formattedStartTime,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textPrimary,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 46.0),
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: borderColor, width: 1.0),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$durationHours jam',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textPrimary,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          _buildSummaryRow(
                            theme,
                            'Harga per jam',
                            'Rp${_formatNumber(court.pricePerHour)}',
                            textSecondary,
                            textPrimary,
                          ),
                          const SizedBox(height: 8.0),
                          _buildSummaryRow(
                            theme,
                            'Durasi',
                            '$durationHours jam × Rp${_formatNumber(court.pricePerHour)}',
                            textSecondary,
                            textPrimary,
                          ),
                          const SizedBox(height: 8.0),
                          _buildSummaryRow(
                            theme,
                            'Subtotal',
                            'Rp${_formatNumber(subtotal)}',
                            textSecondary,
                            textPrimary,
                          ),
                          const SizedBox(height: 8.0),
                          _buildSummaryRow(
                            theme,
                            'Biaya layanan',
                            'Rp${_formatNumber(serviceFee)}',
                            textSecondary,
                            textPrimary,
                          ),
                          const SizedBox(height: 12.0),
                          Divider(color: borderColor, height: 1.0),
                          const SizedBox(height: 12.0),
                          _buildSummaryRow(
                            theme,
                            'Total pembayaran',
                            'Rp${_formatNumber(totalPayment)}',
                            textSecondary,
                            textPrimary,
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Helper text below payment summary card as specified in behavior notes
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: () {
                        // Button action: no destination screen yet as per rules
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjutkan Pembayaran',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: onPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          SvgPicture.asset(
                            AppIcons.arrowRight,
                            width: 16.0,
                            height: 16.0,
                            colorFilter: ColorFilter.mode(onPrimaryColor, BlendMode.srcIn),
                          ),
                        ],
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

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: labelColor,
            fontSize: 12.0,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontSize: 12.0,
            fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
