import '../constants/app_images.dart';

/// Helper class for Indonesian date, time, and currency formatting without external packages.
class DateFormatHelper {
  static const List<String> dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> monthNames = [
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
    'Desember',
  ];

  static const List<String> shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agt',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Returns full Indonesian date string e.g. "Kamis, 15 Oktober 2026"
  static String formatFullDate(DateTime date) {
    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Returns short Indonesian date string e.g. "15 Okt 2026"
  static String formatShortDate(DateTime date) {
    final monthName = shortMonthNames[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  /// Returns month name in Indonesian e.g. "Oktober"
  static String getMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return monthNames[month - 1];
  }

  /// Calculates Monday–Sunday date range text for the week containing [date]
  /// e.g. "5–11 Oktober 2026"
  static String formatWeekRange(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    if (monday.month == sunday.month) {
      final monthName = monthNames[monday.month - 1];
      return '${monday.day}–${sunday.day} $monthName ${monday.year}';
    } else if (monday.year == sunday.year) {
      final monMonth = monthNames[monday.month - 1];
      final sunMonth = monthNames[sunday.month - 1];
      return '${monday.day} $monMonth – ${sunday.day} $sunMonth ${monday.year}';
    } else {
      final monMonth = monthNames[monday.month - 1];
      final sunMonth = monthNames[sunday.month - 1];
      return '${monday.day} $monMonth ${monday.year} – ${sunday.day} $sunMonth ${sunday.year}';
    }
  }

  /// Formats compact rupiah in Millions or full format under 1 Million.
  /// e.g. 14.4 -> "Rp14,4 jt", 1.32 -> "Rp1,32 jt", 0.25 -> "Rp250.000", 0 -> "Rp0"
  static String formatCompactRupiah(double jutaAmount) {
    final int totalRupiah = (jutaAmount * 1000000).round();
    if (totalRupiah < 1000000) {
      if (totalRupiah == 0) return 'Rp0';
      // Format to RpXXX.XXX manually
      final buffer = StringBuffer();
      final priceStr = totalRupiah.toString();
      for (int i = 0; i < priceStr.length; i++) {
        if (i > 0 && (priceStr.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(priceStr[i]);
      }
      return 'Rp${buffer.toString()}';
    }
    final roundedJuta = (totalRupiah / 10000.0).round() / 100.0;
    String cleanStr = roundedJuta.toStringAsFixed(2).replaceAll('.', ',');
    if (cleanStr.endsWith(',00')) {
      cleanStr = cleanStr.substring(0, cleanStr.length - 3);
    } else if (cleanStr.endsWith('0')) {
      cleanStr = cleanStr.substring(0, cleanStr.length - 1);
    }
    return 'Rp$cleanStr jt';
  }

  /// Formats chart value label with EXACTLY two decimals using comma, e.g. 0.96 -> "0,96", 14.4 -> "14,40"
  static String formatChartValueLabel(double jutaAmount) {
    return jutaAmount.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Formats date range for input text field e.g. "1–31 Oktober 2026"
  static String formatDateRangeInputText(DateTime start, DateTime end) {
    final isSameDay =
        start.year == end.year && start.month == end.month && start.day == end.day;
    if (isSameDay) {
      return '${start.day} ${monthNames[start.month - 1]} ${start.year}';
    } else if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${monthNames[start.month - 1]} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${monthNames[start.month - 1]} – ${end.day} ${monthNames[end.month - 1]} ${start.year}';
    } else {
      return '${start.day} ${monthNames[start.month - 1]} ${start.year} – ${end.day} ${monthNames[end.month - 1]} ${end.year}';
    }
  }

  /// Parses ISO timestamptz string in UTC and converts to WIB (UTC+7 fixed)
  static DateTime parseUtcToWib(String isoUtcString) {
    final parsed = DateTime.parse(isoUtcString).toUtc();
    return parsed.add(const Duration(hours: 7));
  }

  /// Returns date with full month without day name e.g. "20 November 2026"
  static String formatDateMonthYear(DateTime date) {
    final monthName = monthNames[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  /// Returns short date with time in WIB e.g. "20 Nov 2026, 09.30 WIB"
  static String formatShortDateWithTime(DateTime wibDateTime) {
    final shortMonth = shortMonthNames[wibDateTime.month - 1];
    final hourStr = wibDateTime.hour.toString().padLeft(2, '0');
    final minStr = wibDateTime.minute.toString().padLeft(2, '0');
    return '${wibDateTime.day} $shortMonth ${wibDateTime.year}, $hourStr.$minStr WIB';
  }

  /// Returns payment deadline string in WIB e.g. "Bayar sebelum 20 Nov 2026, 18.00 WIB"
  static String formatPaymentDeadline(DateTime wibDeadline) {
    final shortMonth = shortMonthNames[wibDeadline.month - 1];
    final hourStr = wibDeadline.hour.toString().padLeft(2, '0');
    final minStr = wibDeadline.minute.toString().padLeft(2, '0');
    return 'Bayar sebelum ${wibDeadline.day} $shortMonth ${wibDeadline.year}, $hourStr.$minStr WIB';
  }

  /// Maps court category to default asset image path
  static String getCategoryImageUrl(String category) {
    final catLower = category.toLowerCase().trim();
    switch (catLower) {
      case 'futsal':
        return AppImages.soccer;
      case 'voli':
        return AppImages.volleyball;
      case 'basket':
        return AppImages.basket;
      case 'badminton':
        return AppImages.badminton;
      default:
        return AppImages.soccer;
    }
  }
}
