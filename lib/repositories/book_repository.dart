import '../models/book.dart';

/// Kontrak untuk mengakses data buku (lihat penjelasan di `AuthRepository`).
abstract class BookRepository {
  /// Mengambil semua buku, diurutkan berdasarkan judul.
  Future<List<Book>> fetchBooks();

  /// Mengambil satu buku berdasarkan [id], `null` jika tidak ditemukan.
  Future<Book?> getBook(String id);

  /// Menambah buku baru. Jumlah tersedia awal sama dengan [stock].
  Future<Book> addBook({
    required String title,
    required String author,
    required int stock,
  });

  /// Menyimpan perubahan data buku.
  Future<Book> updateBook(Book book);

  /// Menghapus buku berdasarkan [id].
  Future<void> deleteBook(String id);
}
