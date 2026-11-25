import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';
import 'book_form_screen.dart';

/// Halaman kelola buku (khusus admin): tambah, ubah, dan hapus buku.
///
/// Halaman ini hanya muncul di menu admin, tetapi setiap aksi tetap dicek
/// lagi oleh BookProvider, sehingga anggota tidak bisa mengubah data buku
/// walaupun berhasil membuka halaman ini.
class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  /// Membuka form. [book] kosong = tambah buku, terisi = ubah buku.
  void _openForm(BuildContext context, [Book? book]) {
    context.read<BookProvider>().clearError();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
    );
  }

  /// Minta konfirmasi dulu sebelum menghapus, lalu tampilkan hasilnya.
  Future<void> _confirmDelete(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus buku?'),
        content: Text('"${book.title}" akan dihapus dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<BookProvider>();
    final success = await provider.deleteBook(book);
    if (!context.mounted) return;

    // Jika gagal (misalnya buku masih dipinjam), pesan error dari provider
    // yang ditampilkan.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Buku "${book.title}" dihapus.' : provider.errorMessage!,
        ),
      ),
    );
    if (!success) provider.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    // Daftar lengkap tanpa filter pencarian dari halaman katalog.
    final books = provider.allBooks;

    return Scaffold(
      body: provider.isLoading && books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('Belum ada buku. Tekan + untuk menambah.'))
              : ListView.separated(
                  // Ruang di bawah agar baris terakhir tidak tertutup tombol +.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final book = books[i];
                    final borrowed = book.stock - book.available;
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(
                        '${book.author} · stok ${book.stock}'
                        '${borrowed > 0 ? ' · $borrowed dipinjam' : ''}',
                      ),
                      onTap: () => _openForm(context, book),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Ubah',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openForm(context, book),
                          ),
                          IconButton(
                            key: Key('delete_${book.id}'),
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: provider.isLoading
                                ? null
                                : () => _confirmDelete(context, book),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_book_button'),
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah buku'),
      ),
    );
  }
}
