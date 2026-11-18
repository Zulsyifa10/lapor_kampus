// lib/core/validators.dart
// Penanggung jawab: Nad
// Validasi input form (login, daftar, edit profil, form laporan).

class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static String? required(String? value, [String field = 'Kolom ini']) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, 'Email');
    if (empty != null) return empty;
    if (!_emailRegex.hasMatch(value!.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
    if (value.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Ulangi kata sandi';
    if (value != original) return 'Kata sandi tidak sama';
    return null;
  }

  static String? nim(String? value) {
    final empty = required(value, 'NIM');
    if (empty != null) return empty;
    final v = value!.trim();
    if (!_digitsOnly.hasMatch(v)) return 'NIM hanya boleh berisi angka';
    if (v.length < 8 || v.length > 15) return 'NIM harus 8–15 digit';
    return null;
  }

  static String? minLength(String? value, int min, String field) {
    final empty = required(value, field);
    if (empty != null) return empty;
    if (value!.trim().length < min) return '$field minimal $min karakter';
    return null;
  }
}
