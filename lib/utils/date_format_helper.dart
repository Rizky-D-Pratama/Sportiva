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

  /// Formats compact rupiah in Millions e.g. 14.4 -> "Rp14,4 jt"
  static String formatCompactRupiah(double jutaAmount) {
    final cleanStr = jutaAmount % 1 == 0
        ? jutaAmount.toInt().toString()
        : jutaAmount.toStringAsFixed(1).replaceAll('.', ',');
    return 'Rp$cleanStr jt';
  }
}
