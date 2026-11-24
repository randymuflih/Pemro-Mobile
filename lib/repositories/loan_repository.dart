import '../models/app_user.dart';
import '../models/book.dart';
import '../models/loan.dart';

/// Error saat proses pinjam/kembali, misalnya stok habis.
/// [message] langsung ditampilkan ke pengguna.
class LoanException implements Exception {
  final String message;
  const LoanException(this.message);

  @override
  String toString() => message;
}

/// Kontrak untuk mengakses data peminjaman (lihat penjelasan di `AuthRepository`).
abstract class LoanRepository {
  /// Mengambil data peminjaman, diurutkan dari yang terbaru.
  /// Jika [userId] diisi, hanya milik user tersebut (untuk anggota).
  /// Jika [userId] `null`, semua data peminjaman (untuk admin).
  Future<List<Loan>> fetchLoans({String? userId});

  /// Meminjam [book] atas nama [user]. Stok tersedia berkurang 1.
  Future<Loan> borrowBook({required Book book, required AppUser user});

  /// Mengembalikan buku dari peminjaman [loanId]. Stok tersedia bertambah 1.
  Future<Loan> returnBook(String loanId);
}
