import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'admin/manage_books_screen.dart';
import 'catalog_screen.dart';
import 'profile_screen.dart';

/// Halaman utama setelah login, berisi menu navigasi bawah.
///
/// Authorization di UI: daftar menu ditentukan oleh role pengguna.
/// - Admin   : Katalog, Kelola Buku, Profil.
/// - Anggota : Katalog, Profil.
/// Aturan akses tetap dicek ulang di provider (lihat BookProvider._ensureAdmin),
/// jadi menyembunyikan menu di sini bukan satu-satunya pengaman.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0; // Menu yang sedang dipilih.

  @override
  Widget build(BuildContext context) {
    // select: hanya rebuild jika role berubah, bukan setiap AuthProvider berubah.
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);
    final menus = isAdmin ? _adminMenus : _memberMenus;

    // Jaga-jaga jika jumlah menu berubah dan index jadi di luar batas.
    final index = _index < menus.length ? _index : 0;

    return Scaffold(
      appBar: AppBar(title: Text(menus[index].title)),
      // IndexedStack menyimpan state tiap halaman (misalnya teks pencarian)
      // saat berpindah menu.
      body: IndexedStack(
        index: index,
        children: [for (final menu in menus) menu.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final menu in menus)
            NavigationDestination(
              icon: Icon(menu.icon),
              selectedIcon: Icon(menu.selectedIcon),
              label: menu.label,
            ),
        ],
      ),
    );
  }
}

/// Data satu item menu navigasi bawah.
class _Menu {
  const _Menu({
    required this.label,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final String title; // Judul di AppBar.
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const _catalogMenu = _Menu(
  label: 'Katalog',
  title: 'Katalog Buku',
  icon: Icons.menu_book_outlined,
  selectedIcon: Icons.menu_book,
  page: CatalogScreen(),
);

const _profileMenu = _Menu(
  label: 'Profil',
  title: 'Profil',
  icon: Icons.person_outline,
  selectedIcon: Icons.person,
  page: ProfileScreen(),
);

const _adminMenus = [
  _catalogMenu,
  _Menu(
    label: 'Kelola Buku',
    title: 'Kelola Buku',
    icon: Icons.edit_note_outlined,
    selectedIcon: Icons.edit_note,
    page: ManageBooksScreen(),
  ),
  _profileMenu,
];

const _memberMenus = [_catalogMenu, _profileMenu];
