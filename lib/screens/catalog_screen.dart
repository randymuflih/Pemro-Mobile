import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../providers/loan_provider.dart';

/// Halaman katalog: daftar semua buku dengan pencarian judul/penulis.
/// Bisa dibuka oleh admin maupun anggota.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Muat buku setelah frame pertama selesai digambar, karena loadBooks
    // memanggil notifyListeners yang tidak boleh terjadi saat build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final books = provider.books;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            key: const Key('catalog_search'),
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari judul atau penulis',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              // Tombol hapus hanya muncul jika ada kata kunci.
              suffixIcon: provider.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.search('');
                      },
                    ),
            ),
            onChanged: provider.search,
          ),
        ),
        Expanded(child: _buildList(provider, books)),
      ],
    );
  }

  Widget _buildList(BookProvider provider, List<Book> books) {
    // Loading pertama kali (belum ada data sama sekali).
    if (provider.isLoading && books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: provider.loadBooks,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (books.isEmpty) {
      return Center(
        child: Text(
          provider.query.isEmpty
              ? 'Belum ada buku.'
              : 'Tidak ada buku yang cocok dengan "${provider.query}".',
        ),
      );
    }

    // Hanya anggota yang boleh meminjam, jadi tombol Pinjam hanya untuk mereka.
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);

    // Tarik ke bawah untuk memuat ulang daftar buku.
    return RefreshIndicator(
      onRefresh: provider.loadBooks,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: books.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _BookTile(
          book: books[i],
          action: isAdmin ? null : _BorrowButton(book: books[i]),
        ),
      ),
    );
  }
}

/// Satu baris buku di katalog.
class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, this.action});

  final Book book;

  /// Tombol tambahan di sisi kanan (misalnya tombol Pinjam).
  /// Boleh kosong, misalnya untuk admin.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final status = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          book.isAvailable ? 'Tersedia' : 'Habis',
          style: TextStyle(
            color: book.isAvailable ? colors.primary : colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text('${book.available} / ${book.stock}'),
      ],
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        child: Icon(Icons.book, color: colors.onPrimaryContainer),
      ),
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: action == null
          ? status
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [status, const SizedBox(width: 12), action!],
            ),
    );
  }
}

/// Tombol pinjam untuk anggota. Ada tiga keadaan:
/// - buku sedang dipinjam user ini : chip "Dipinjam" (tidak bisa pinjam dua kali)
/// - stok tersedia                 : tombol "Pinjam" aktif
/// - stok habis                    : tombol "Pinjam" nonaktif
class _BorrowButton extends StatelessWidget {
  const _BorrowButton({required this.book});

  final Book book;

  /// Meminjam buku, lalu memuat ulang daftar buku
  /// agar jumlah "tersedia" langsung berkurang di layar.
  Future<void> _borrow(BuildContext context) async {
    // Ambil semua yang butuh context sebelum `await`.
    final loanProvider = context.read<LoanProvider>();
    final bookProvider = context.read<BookProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await loanProvider.borrow(book);
    if (success) await bookProvider.loadBooks();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Berhasil meminjam "${book.title}".'
              : loanProvider.errorMessage ?? 'Gagal meminjam buku.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: tombol ikut berubah setelah pinjam/kembali.
    final loans = context.watch<LoanProvider>();

    if (loans.isBorrowing(book.id)) {
      return const Chip(label: Text('Dipinjam'));
    }
    return FilledButton.tonal(
      key: Key('borrow_${book.id}'),
      onPressed:
          book.isAvailable && !loans.isLoading ? () => _borrow(context) : null,
      child: const Text('Pinjam'),
    );
  }
}
