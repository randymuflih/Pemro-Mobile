import '../../models/book.dart';
import '../book_repository.dart';

/// Implementasi [BookRepository] yang menyimpan data buku di memori.
class LocalBookRepository implements BookRepository {
  /// [initialBooks] bisa diisi saat testing. Jika kosong, dipakai buku contoh.
  LocalBookRepository({
    this.latency = const Duration(milliseconds: 300),
    List<Book>? initialBooks,
  }) {
    for (final book in initialBooks ?? _sampleBooks) {
      _books[book.id] = book;
    }
  }

  final Duration latency;

  /// Data buku, dengan key berupa id buku.
  final Map<String, Book> _books = {};
  int _idCounter = 0;

  /// Buku contoh yang tampil saat aplikasi pertama kali dibuka.
  static const _sampleBooks = [
    Book(
      id: 'b-1',
      title: 'Laskar Pelangi',
      author: 'Andrea Hirata',
      stock: 3,
      available: 3,
    ),
    Book(
      id: 'b-2',
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      stock: 2,
      available: 2,
    ),
    Book(
      id: 'b-3',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      stock: 1,
      available: 1,
    ),
  ];

  @override
  Future<List<Book>> fetchBooks() async {
    await Future.delayed(latency);
    final books = _books.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return books;
  }

  @override
  Future<Book?> getBook(String id) async {
    await Future.delayed(latency);
    return _books[id];
  }

  @override
  Future<Book> addBook({
    required String title,
    required String author,
    required int stock,
  }) async {
    await Future.delayed(latency);
    final book = Book(
      id: 'b-new-${++_idCounter}',
      title: title.trim(),
      author: author.trim(),
      stock: stock,
      available: stock, // Buku baru: semua eksemplar tersedia.
    );
    _books[book.id] = book;
    return book;
  }

  @override
  Future<Book> updateBook(Book book) async {
    await Future.delayed(latency);
    if (!_books.containsKey(book.id)) {
      throw StateError('Buku tidak ditemukan.');
    }
    _books[book.id] = book;
    return book;
  }

  @override
  Future<void> deleteBook(String id) async {
    await Future.delayed(latency);
    _books.remove(id);
  }
}
