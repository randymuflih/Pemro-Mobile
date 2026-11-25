import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

/// State management untuk data buku: daftar, pencarian, dan kelola buku.
class BookProvider extends ChangeNotifier {
  BookProvider(this._repository);

  final BookRepository _repository;

  // ---------------------------------------------------------------- State

  /// User yang sedang login, dikirim dari AuthProvider lewat [updateUser].
  AppUser? _user;
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;

  /// Semua buku tanpa filter pencarian, dipakai di halaman kelola buku.
  List<Book> get allBooks => List.unmodifiable(_books);

  /// Daftar buku yang sudah difilter sesuai kata kunci pencarian.
  List<Book> get books {
    if (_query.isEmpty) return List.unmodifiable(_books);
    final q = _query.toLowerCase();
    return _books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Dipanggil otomatis oleh `ChangeNotifierProxyProvider` setiap kali
  /// AuthProvider berubah (login/logout). Saat logout, data dibersihkan.
  void updateUser(AppUser? user) {
    if (_user?.id == user?.id) return;
    _user = user;
    if (user == null) {
      _books = [];
      _query = '';
      _errorMessage = null;
    }
  }

  // ---------------------------------------------------------------- Aksi

  /// Mengambil daftar buku dari repository.
  Future<void> loadBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _books = await _repository.fetchBooks();
    } catch (_) {
      _errorMessage = 'Gagal memuat data buku.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan kata kunci pencarian. Getter [books] otomatis memfilter.
  void search(String query) {
    _query = query.trim();
    notifyListeners();
  }

  /// Menambah buku baru (khusus admin).
  Future<bool> addBook({
    required String title,
    required String author,
    required int stock,
  }) async {
    if (!_ensureAdmin()) return false;
    return _mutate(() async {
      await _repository.addBook(title: title, author: author, stock: stock);
    });
  }

  /// Mengubah data buku (khusus admin).
  /// Stok baru tidak boleh lebih kecil dari jumlah yang sedang dipinjam.
  Future<bool> updateBook(
    Book book, {
    required String title,
    required String author,
    required int stock,
  }) async {
    if (!_ensureAdmin()) return false;
    final borrowed = book.stock - book.available;
    if (stock < borrowed) {
      _setError(
        'Stok tidak boleh kurang dari jumlah yang dipinjam ($borrowed).',
      );
      return false;
    }
    return _mutate(() async {
      await _repository.updateBook(
        book.copyWith(
          title: title.trim(),
          author: author.trim(),
          stock: stock,
          available: stock - borrowed,
        ),
      );
    });
  }

  /// Menghapus buku (khusus admin). Buku yang sedang dipinjam tidak bisa dihapus.
  Future<bool> deleteBook(Book book) async {
    if (!_ensureAdmin()) return false;
    if (book.available < book.stock) {
      _setError('Buku masih dipinjam, tidak bisa dihapus.');
      return false;
    }
    return _mutate(() => _repository.deleteBook(book.id));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- Helper

  /// Authorization: hanya admin yang boleh mengubah data buku.
  /// Dicek di sini juga (bukan hanya di UI) agar aturan tidak bisa dilewati.
  bool _ensureAdmin() {
    if (_user?.isAdmin ?? false) return true;
    _setError('Akses ditolak. Hanya admin yang dapat mengelola buku.');
    return false;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Pola umum untuk tambah/ubah/hapus: jalankan [action],
  /// lalu muat ulang daftar buku agar UI menampilkan data terbaru.
  Future<bool> _mutate(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _books = await _repository.fetchBooks();
      return true;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan perubahan.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
