import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// State management untuk autentikasi (login, register, logout).
///
/// Cara kerja Provider:
/// 1. Data state disimpan di variabel private (`_user`, `_isLoading`, dll).
/// 2. UI membaca data lewat getter (`user`, `isLoading`, dll).
/// 3. Setiap kali data berubah, `notifyListeners()` dipanggil sehingga
///    semua widget yang "mendengarkan" provider ini otomatis di-rebuild.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) : _user = _repository.currentUser;

  final AuthRepository _repository;

  // ---------------------------------------------------------------- State
  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  // ---------------------------------------------------------------- Aksi

  /// Login. Mengembalikan `true` jika berhasil.
  Future<bool> signIn(String email, String password) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  /// Daftar akun baru. Mengembalikan `true` jika berhasil.
  Future<bool> signUp(String name, String email, String password) {
    return _run(
      () => _repository.signUp(name: name, email: email, password: password),
    );
  }

  /// Logout, lalu UI otomatis kembali ke halaman login.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _repository.signOut();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Menghapus pesan error, misalnya saat pindah halaman.
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Pola umum untuk login/register:
  /// tampilkan loading, jalankan [action], simpan hasil atau pesan error,
  /// lalu matikan loading.
  Future<bool> _run(Future<AppUser> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
