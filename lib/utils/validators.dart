/// Pure validation functions for Sportiva auth forms.
class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi.';
    }
    final trimmed = value.trim();
    // Simple email regex format text@text.text
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi.';
    }
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Must start with 08 or +628
    String digitsAfterPrefix = '';
    if (cleaned.startsWith('+628')) {
      digitsAfterPrefix = cleaned.substring(4);
    } else if (cleaned.startsWith('08')) {
      digitsAfterPrefix = cleaned.substring(2);
    } else {
      return 'Nomor telepon tidak valid.';
    }

    // Remaining must be digits only, total 8 to 11 digits after prefix
    if (!RegExp(r'^\d+$').hasMatch(digitsAfterPrefix)) {
      return 'Nomor telepon tidak valid.';
    }
    if (digitsAfterPrefix.length < 8 || digitsAfterPrefix.length > 11) {
      return 'Nomor telepon tidak valid.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter, gunakan huruf dan angka.';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Password minimal 8 karakter, gunakan huruf dan angka.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }
    if (value != password) {
      return 'Password tidak sama.';
    }
    return null;
  }
}
