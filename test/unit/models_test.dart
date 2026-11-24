// Unit test untuk model data (AppUser, Book, Loan).
// Memastikan konversi toMap/fromMap dan getter bekerja dengan benar.
// Jalankan: flutter test test/unit/models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:perpustakaan_mini/models/app_user.dart';
import 'package:perpustakaan_mini/models/book.dart';
import 'package:perpustakaan_mini/models/loan.dart';

void main() {
  test('AppUser toMap dan fromMap menghasilkan data yang sama', () {
    const user = AppUser(
      id: '1',
      name: 'Admin',
      email: 'admin@perpus.com',
      role: UserRole.admin,
    );
    final copy = AppUser.fromMap(user.toMap());

    expect(copy.id, user.id);
    expect(copy.email, user.email);
    expect(copy.isAdmin, isTrue);
    expect(copy.roleLabel, 'Admin');
  });

  test('AppUser default role adalah member', () {
    final user = AppUser.fromMap({'id': '2', 'name': 'A', 'email': 'a@b.c'});
    expect(user.role, UserRole.member);
  });

  test('Book.isAvailable bergantung pada jumlah tersedia', () {
    const book = Book(
      id: 'b',
      title: 'Judul',
      author: 'Penulis',
      stock: 1,
      available: 1,
    );
    expect(book.isAvailable, isTrue);
    expect(book.copyWith(available: 0).isAvailable, isFalse);
  });

  test('Loan serialisasi tanggal dengan benar', () {
    final loan = Loan(
      id: 'l',
      bookId: 'b',
      bookTitle: 'Judul',
      userId: 'u',
      userName: 'User',
      borrowedAt: DateTime(2026, 11, 24, 9, 5),
    );
    final copy = Loan.fromMap(loan.toMap());

    expect(copy.borrowedAt, loan.borrowedAt);
    expect(copy.isReturned, isFalse);
    expect(
        loan.copyWith(returnedAt: DateTime(2026, 11, 25)).isReturned, isTrue);
  });
}
