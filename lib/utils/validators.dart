/// Kumpulan fungsi validasi untuk form.
///
/// Setiap fungsi mengembalikan `null` jika input valid, atau pesan error
/// jika tidak valid. Format ini sesuai dengan parameter `validator`
/// pada widget `TextFormField`.
class Validators {
  Validators._(); // Tidak perlu dibuat objeknya, cukup panggil Validators.email(...)

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  /// Validasi umum untuk field wajib, [field] dipakai di pesan error.
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  /// Validasi angka bulat minimal 1, misalnya untuk jumlah stok.
  static String? positiveNumber(String? value, String field) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) return '$field harus berupa angka';
    if (number < 1) return '$field minimal 1';
    return null;
  }
}
