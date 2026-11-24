// Unit test untuk AuthProvider (Authentication).
// Memakai LocalAuthRepository dengan latency nol agar test berjalan cepat.
// Jalankan: flutter test test/unit/auth_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:perpustakaan_mini/providers/auth_provider.dart';
import 'package:perpustakaan_mini/repositories/local/local_auth_repository.dart';

void main() {
  late AuthProvider auth;

  setUp(() {
    auth = AuthProvider(LocalAuthRepository(latency: Duration.zero));
  });

  test('awalnya belum login', () {
    expect(auth.isLoggedIn, isFalse);
  });

  test('login admin berhasil dan role admin', () async {
    final ok = await auth.signIn('admin@perpus.com', 'admin123');

    expect(ok, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.isAdmin, isTrue);
  });

  test('login dengan password salah gagal', () async {
    final ok = await auth.signIn('admin@perpus.com', 'salah123');

    expect(ok, isFalse);
    expect(auth.isLoggedIn, isFalse);
    expect(auth.errorMessage, 'Email atau password salah.');
  });

  test('register membuat akun dengan role anggota', () async {
    final ok = await auth.signUp('Budi', 'budi@mail.com', 'rahasia');

    expect(ok, isTrue);
    expect(auth.user!.name, 'Budi');
    expect(auth.isAdmin, isFalse);
  });

  test('register dengan email terdaftar gagal', () async {
    final ok = await auth.signUp('X', 'admin@perpus.com', 'rahasia');

    expect(ok, isFalse);
    expect(auth.errorMessage, 'Email sudah terdaftar.');
  });

  test('logout menghapus user', () async {
    await auth.signIn('anggota@perpus.com', 'anggota123');
    await auth.signOut();

    expect(auth.isLoggedIn, isFalse);
    expect(auth.user, isNull);
  });
}
