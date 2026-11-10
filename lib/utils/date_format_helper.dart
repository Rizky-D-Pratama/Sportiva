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
}
