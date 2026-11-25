import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/local/local_auth_repository.dart';
import 'repositories/local/local_book_repository.dart';
import 'repositories/local/local_loan_repository.dart';

/// Titik awal aplikasi.
///
/// Di sini ditentukan sumber data yang dipakai. Saat ini memakai repository
/// lokal (in-memory). Untuk pindah ke database cloud, cukup ganti ketiga
/// repository di bawah dengan versi cloud-nya.
void main() {
  // BookRepository dipakai bersama karena LoanRepository perlu mengubah stok buku.
  final bookRepository = LocalBookRepository();

  runApp(
    PerpustakaanApp(
      authRepository: LocalAuthRepository(),
      bookRepository: bookRepository,
      loanRepository: LocalLoanRepository(bookRepository: bookRepository),
    ),
  );
}
