// Unit test untuk LoanProvider.
// Menguji aturan pinjam/kembali: stok, pinjam ganda, dan hak akses per role.
// Jalankan: flutter test test/unit/loan_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:perpustakaan_mini/models/app_user.dart';
import 'package:perpustakaan_mini/providers/loan_provider.dart';
import 'package:perpustakaan_mini/repositories/local/local_book_repository.dart';
import 'package:perpustakaan_mini/repositories/local/local_loan_repository.dart';

const admin = AppUser(
  id: 'a',
  name: 'Admin',
  email: 'admin@perpus.com',
  role: UserRole.admin,
);
const member = AppUser(id: 'm', name: 'Member', email: 'm@perpus.com');
const otherMember = AppUser(id: 'o', name: 'Other', email: 'o@perpus.com');

void main() {
  late LocalBookRepository bookRepository;
  late LoanProvider provider;

  setUp(() {
    bookRepository = LocalBookRepository(latency: Duration.zero);
    provider = LoanProvider(
      LocalLoanRepository(
        bookRepository: bookRepository,
        latency: Duration.zero,
      ),
    );
  });

  test('anggota meminjam buku dan stok berkurang', () async {
    provider.updateUser(member);
    final book = (await bookRepository.getBook('b-1'))!;

    expect(await provider.borrow(book), isTrue);
    expect(provider.activeLoans, hasLength(1));
    expect(provider.isBorrowing('b-1'), isTrue);
    expect(
        (await bookRepository.getBook('b-1'))!.available, book.available - 1);
  });

  test('tidak bisa meminjam buku yang stoknya habis', () async {
    provider.updateUser(member);
    final book = (await bookRepository.getBook('b-3'))!; // stok 1
    await provider.borrow(book);

    provider.updateUser(otherMember);
    expect(await provider.borrow(book), isFalse);
    expect(provider.errorMessage, 'Stok buku sedang habis.');
  });

  test('tidak bisa meminjam buku yang sama dua kali', () async {
    provider.updateUser(member);
    final book = (await bookRepository.getBook('b-1'))!;
    await provider.borrow(book);

    expect(await provider.borrow(book), isFalse);
    expect(provider.errorMessage, 'Kamu masih meminjam buku ini.');
  });

  test('admin tidak boleh meminjam buku', () async {
    provider.updateUser(admin);
    final book = (await bookRepository.getBook('b-1'))!;

    expect(await provider.borrow(book), isFalse);
    expect(provider.errorMessage, contains('Akses ditolak'));
  });

  test('mengembalikan buku menambah stok kembali', () async {
    provider.updateUser(member);
    final book = (await bookRepository.getBook('b-2'))!;
    await provider.borrow(book);

    expect(await provider.returnLoan(provider.activeLoans.first), isTrue);
    expect(provider.activeLoans, isEmpty);
    expect(provider.returnedLoans, hasLength(1));
    expect((await bookRepository.getBook('b-2'))!.available, book.available);
  });

  test('anggota hanya melihat pinjamannya sendiri, admin melihat semua',
      () async {
    provider.updateUser(member);
    await provider.borrow((await bookRepository.getBook('b-1'))!);
    provider.updateUser(otherMember);
    await provider.borrow((await bookRepository.getBook('b-2'))!);

    await provider.loadLoans();
    expect(provider.loans, hasLength(1));

    provider.updateUser(admin);
    await provider.loadLoans();
    expect(provider.loans, hasLength(2));
  });

  test('anggota tidak bisa mengembalikan pinjaman orang lain', () async {
    provider.updateUser(member);
    await provider.borrow((await bookRepository.getBook('b-1'))!);
    final loan = provider.activeLoans.first;

    provider.updateUser(otherMember);
    expect(await provider.returnLoan(loan), isFalse);
    expect(provider.errorMessage, 'Akses ditolak.');
  });
}
