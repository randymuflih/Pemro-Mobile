import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Halaman utama setelah login.
///
/// Untuk sementara hanya menampilkan sapaan dan tombol logout.
/// Menu per role, katalog, dan profil ditambahkan di langkah berikutnya.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan Mini'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: auth.isLoading ? null : auth.signOut,
          ),
        ],
      ),
      body: Center(
        child: Text('Halo, ${user.name} (${user.roleLabel})'),
      ),
    );
  }
}
