import '../models/app_user.dart';

/// Error yang terjadi saat login atau register, misalnya password salah.
/// [message] langsung ditampilkan ke pengguna.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Kontrak (aturan) untuk fitur autentikasi.
///
/// Class ini hanya berisi daftar fungsi tanpa isi (abstract). Isinya dibuat
/// oleh class lain, misalnya:
/// - `LocalAuthRepository`   : data disimpan di memori (untuk sementara/testing)
/// - `SupabaseAuthRepository`: data disimpan di database cloud (tahap berikutnya)
///
/// Dengan cara ini, Provider dan UI tidak perlu diubah saat sumber data diganti.
abstract class AuthRepository {
  /// Pengguna yang sedang login, `null` jika belum login.
  AppUser? get currentUser;

  /// Masuk dengan email dan password. Melempar [AuthException] jika gagal.
  Future<AppUser> signIn({required String email, required String password});

  /// Mendaftarkan akun baru. Melempar [AuthException] jika email sudah dipakai.
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Keluar dari akun.
  Future<void> signOut();
}
