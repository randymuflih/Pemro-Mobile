// Unit test untuk BookProvider.
// Fokus pada aturan Authorization: hanya admin yang boleh mengelola buku.
// Jalankan: flutter test test/unit/book_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:perpustakaan_mini/models/app_user.dart';
import 'package:perpustakaan_mini/providers/book_provider.dart';
import 'package:perpustakaan_mini/repositories/local/local_book_repository.dart';

const admin = AppUser(
  id: 'a',
  name: 'Admin',
  email: 'admin@perpus.com',
  role: UserRole.admin,
);
const member = AppUser(id: 'm', name: 'Member', email: 'm@perpus.com');

void main() {
  late BookProvider provider;

  setUp(() {
    provider = BookProvider(LocalBookRepository(latency: Duration.zero));
  });

  test('memuat daftar buku', () async {
    await provider.loadBooks();
    expect(provider.books, hasLength(3));
  });

  test('pencarian memfilter judul atau penulis', () async {
    await provider.loadBooks();
    provider.search('andrea');

    expect(provider.books, hasLength(1));
    expect(provider.books.first.title, 'Laskar Pelangi');
  });

  test('admin dapat menambah buku', () async {
    provider.updateUser(admin);
    final ok = await provider.addBook(
      title: 'Buku Baru',
      author: 'Penulis',
      stock: 2,
    );

    expect(ok, isTrue);
    expect(provider.books.any((b) => b.title == 'Buku Baru'), isTrue);
  });

  test('anggota tidak boleh menambah buku', () async {
    provider.updateUser(member);
    final ok = await provider.addBook(title: 'X', author: 'Y', stock: 1);

    expect(ok, isFalse);
    expect(provider.errorMessage, contains('Akses ditolak'));
  });

  test('anggota tidak boleh menghapus buku', () async {
    provider.updateUser(member);
    await provider.loadBooks();
    final ok = await provider.deleteBook(provider.books.first);

    expect(ok, isFalse);
    expect(provider.books, hasLength(3));
  });

  test('admin dapat mengubah dan menghapus buku', () async {
    provider.updateUser(admin);
    await provider.loadBooks();
    final book = provider.books.first;

    expect(
      await provider.updateBook(book,
          title: 'Judul Baru', author: 'A', stock: 5),
      isTrue,
    );
    final updated = provider.books.firstWhere((b) => b.id == book.id);
    expect(updated.title, 'Judul Baru');
    expect(updated.available, 5);

    expect(await provider.deleteBook(updated), isTrue);
    expect(provider.books.any((b) => b.id == book.id), isFalse);
  });

  test('buku yang sedang dipinjam tidak bisa dihapus', () async {
    provider.updateUser(admin);
    await provider.loadBooks();
    final borrowed = provider.books.first.copyWith(available: 0);

    expect(await provider.deleteBook(borrowed), isFalse);
    expect(provider.errorMessage, contains('masih dipinjam'));
  });
}
