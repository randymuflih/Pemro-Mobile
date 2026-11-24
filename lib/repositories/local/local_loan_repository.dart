import '../../models/app_user.dart';
import '../../models/book.dart';
import '../../models/loan.dart';
import '../book_repository.dart';
import '../loan_repository.dart';

/// Implementasi [LoanRepository] yang menyimpan data peminjaman di memori.
///
/// Membutuhkan [BookRepository] karena setiap pinjam/kembali harus
/// mengubah jumlah buku yang tersedia.
class LocalLoanRepository implements LoanRepository {
  LocalLoanRepository({
    required BookRepository bookRepository,
    this.latency = const Duration(milliseconds: 300),
  }) : _bookRepository = bookRepository;

  final BookRepository _bookRepository;
  final Duration latency;

  /// Data peminjaman, dengan key berupa id peminjaman.
  final Map<String, Loan> _loans = {};
  int _idCounter = 0;

  @override
  Future<List<Loan>> fetchLoans({String? userId}) async {
    await Future.delayed(latency);
    final loans = _loans.values
        .where((loan) => userId == null || loan.userId == userId)
        .toList()
      ..sort((a, b) => b.borrowedAt.compareTo(a.borrowedAt));
    return loans;
  }

  @override
  Future<Loan> borrowBook({required Book book, required AppUser user}) async {
    await Future.delayed(latency);

    // 1. Ambil data buku terbaru agar stok yang dicek akurat.
    final latest = await _bookRepository.getBook(book.id);
    if (latest == null) {
      throw const LoanException('Buku tidak ditemukan.');
    }

    // 2. Pastikan stok masih ada.
    if (!latest.isAvailable) {
      throw const LoanException('Stok buku sedang habis.');
    }

    // 3. Satu anggota tidak boleh meminjam buku yang sama dua kali.
    final alreadyBorrowed = _loans.values.any(
      (loan) =>
          loan.bookId == book.id && loan.userId == user.id && !loan.isReturned,
    );
    if (alreadyBorrowed) {
      throw const LoanException('Kamu masih meminjam buku ini.');
    }

    // 4. Kurangi stok tersedia, lalu catat peminjaman.
    await _bookRepository.updateBook(
      latest.copyWith(available: latest.available - 1),
    );
    final loan = Loan(
      id: 'l-${++_idCounter}',
      bookId: latest.id,
      bookTitle: latest.title,
      userId: user.id,
      userName: user.name,
      borrowedAt: DateTime.now(),
    );
    _loans[loan.id] = loan;
    return loan;
  }

  @override
  Future<Loan> returnBook(String loanId) async {
    await Future.delayed(latency);

    final loan = _loans[loanId];
    if (loan == null) {
      throw const LoanException('Data peminjaman tidak ditemukan.');
    }
    if (loan.isReturned) {
      throw const LoanException('Buku sudah dikembalikan.');
    }

    // Tambah kembali stok tersedia, lalu isi tanggal pengembalian.
    final book = await _bookRepository.getBook(loan.bookId);
    if (book != null) {
      await _bookRepository.updateBook(
        book.copyWith(available: book.available + 1),
      );
    }
    final updated = loan.copyWith(returnedAt: DateTime.now());
    _loans[loanId] = updated;
    return updated;
  }
}
