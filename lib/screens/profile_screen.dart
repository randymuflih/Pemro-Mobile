import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Halaman profil: data pengguna yang sedang login, hak aksesnya, dan logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    // Saat logout, user sudah null sebelum AuthGate berpindah halaman.
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        Text(user.email, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            avatar: Icon(
              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
              size: 18,
            ),
            label: Text(user.roleLabel),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hak akses', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                // Penjelasan singkat apa saja yang boleh dilakukan role ini.
                for (final access in user.isAdmin ? _adminAccess : _memberAccess)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(access)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const Key('logout_button'),
          onPressed: auth.isLoading ? null : auth.signOut,
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}

const _adminAccess = [
  'Melihat katalog buku',
  'Menambah, mengubah, dan menghapus buku',
];

const _memberAccess = [
  'Melihat katalog buku',
  'Meminjam dan mengembalikan buku',
];
