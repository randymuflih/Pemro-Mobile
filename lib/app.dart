import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/loan_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/loan_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

/// Widget utama aplikasi.
///
/// Repository diterima dari luar (dependency injection), sehingga saat testing
/// kita bisa memasukkan repository lokal tanpa jeda.
class PerpustakaanApp extends StatelessWidget {
  const PerpustakaanApp({
    super.key,
    required this.authRepository,
    required this.bookRepository,
    required this.loanRepository,
  });

  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final LoanRepository loanRepository;

  @override
  Widget build(BuildContext context) {
    // MultiProvider mendaftarkan semua state agar bisa diakses dari widget
    // mana pun di bawahnya dengan context.watch / context.read.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),

        // ProxyProvider: setiap kali AuthProvider berubah (login/logout),
        // user terbaru dikirim ke BookProvider dan LoanProvider lewat updateUser.
        ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
          create: (_) => BookProvider(bookRepository),
          update: (_, auth, books) => books!..updateUser(auth.user),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LoanProvider>(
          create: (_) => LoanProvider(loanRepository),
          update: (_, auth, loans) => loans!..updateUser(auth.user),
        ),
      ],
      child: MaterialApp(
        title: 'Perpustakaan Mini',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// "Gerbang" autentikasi: menampilkan halaman utama jika sudah login,
/// atau halaman login jika belum. Berpindah otomatis saat status login berubah.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // context.select hanya rebuild jika nilai isLoggedIn berubah.
    final isLoggedIn = context.select<AuthProvider, bool>((a) => a.isLoggedIn);
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
