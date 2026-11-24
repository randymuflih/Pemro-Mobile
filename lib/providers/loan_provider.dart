import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';

/// State management untuk peminjaman buku.
class LoanProvider extends ChangeNotifier {
  LoanProvider(this._repository);

  final LoanRepository _repository;

  // ---------------------------------------------------------------- State

  /// User yang sedang login, dikirim dari AuthProvider lewat [updateUser].
  AppUser? _user;
  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Loan> get loans => List.unmodifiable(_loans);

  /// Peminjaman yang bukunya belum dikembalikan.
  List<Loan> get activeLoans => _loans.where((l) => !l.isReturned).toList();

  /// Peminjaman yang bukunya sudah dikembalikan (riwayat).
  List<Loan> get returnedLoans => _loans.where((l) => l.isReturned).toList();

  /// `true` jika user yang login sedang meminjam buku [bookId].
  bool isBorrowing(String bookId) => _loans.any(
        (l) => l.bookId == bookId && !l.isReturned && l.userId == _user?.id,
      );

  /// Dipanggil otomatis oleh `ChangeNotifierProxyProvider` saat user berganti.
  void updateUser(AppUser? user) {
    if (_user?.id == user?.id) return;
    _user = user;
    _loans = [];
    _errorMessage = null;
  }

  // ---------------------------------------------------------------- Aksi

  /// Memuat data peminjaman.
  /// Authorization: admin melihat semua, anggota hanya miliknya sendiri.
  Future<void> loadLoans() async {
    final user = _user;
    if (user == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _loans = await _repository.fetchLoans(
        userId: user.isAdmin ? null : user.id,
      );
    } catch (_) {
      _errorMessage = 'Gagal memuat data peminjaman.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Meminjam buku.
  /// Authorization: hanya anggota yang boleh meminjam, admin tidak.
  Future<bool> borrow(Book book) async {
    final user = _user;
    if (user == null || user.isAdmin) {
      _setError('Akses ditolak. Hanya anggota yang dapat meminjam buku.');
      return false;
    }
    return _mutate(() => _repository.borrowBook(book: book, user: user));
  }

  /// Mengembalikan buku.
  /// Authorization: anggota hanya bisa mengembalikan pinjamannya sendiri,
  /// admin boleh memproses pengembalian milik siapa pun.
  Future<bool> returnLoan(Loan loan) async {
    final user = _user;
    if (user == null || (!user.isAdmin && loan.userId != user.id)) {
      _setError('Akses ditolak.');
      return false;
    }
    return _mutate(() => _repository.returnBook(loan.id));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- Helper

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Pola umum untuk pinjam/kembali: jalankan [action],
  /// lalu muat ulang data peminjaman agar UI menampilkan data terbaru.
  Future<bool> _mutate(Future<void> Function() action) async {
    final user = _user!;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _loans = await _repository.fetchLoans(
        userId: user.isAdmin ? null : user.id,
      );
      return true;
    } on LoanException catch (e) {
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
