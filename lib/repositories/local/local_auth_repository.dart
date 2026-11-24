import '../../models/app_user.dart';
import '../auth_repository.dart';

/// Implementasi [AuthRepository] yang menyimpan akun di memori (RAM).
///
/// Dipakai sementara sebelum database cloud dipasang, dan juga untuk testing.
/// Data akan hilang saat aplikasi ditutup.
class LocalAuthRepository implements AuthRepository {
  /// [latency] meniru jeda jaringan agar loading terlihat seperti aplikasi
  /// sungguhan. Saat testing diisi `Duration.zero` supaya test cepat.
  LocalAuthRepository({this.latency = const Duration(milliseconds: 400)}) {
    // Akun demo yang sudah tersedia sejak awal.
    _accounts['admin@perpus.com'] = _Account(
      password: 'admin123',
      user: const AppUser(
        id: 'u-admin',
        name: 'Admin Perpustakaan',
        email: 'admin@perpus.com',
        role: UserRole.admin,
      ),
    );
    _accounts['anggota@perpus.com'] = _Account(
      password: 'anggota123',
      user: const AppUser(
        id: 'u-anggota',
        name: 'Anggota Contoh',
        email: 'anggota@perpus.com',
      ),
    );
  }

  final Duration latency;

  /// Daftar akun, dengan key berupa email (huruf kecil).
  final Map<String, _Account> _accounts = {};
  AppUser? _currentUser;
  int _idCounter = 0;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(latency);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Email atau password salah.');
    }
    _currentUser = account.user;
    return account.user;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(latency);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Email sudah terdaftar.');
    }
    // Authorization: pendaftar baru selalu menjadi anggota, bukan admin.
    final user = AppUser(
      id: 'u-${++_idCounter}',
      name: name.trim(),
      email: key,
    );
    _accounts[key] = _Account(password: password, user: user);
    _currentUser = user; // Langsung login setelah daftar.
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(latency);
    _currentUser = null;
  }
}

/// Pasangan password dan data user untuk satu akun.
class _Account {
  final String password;
  final AppUser user;

  const _Account({required this.password, required this.user});
}
