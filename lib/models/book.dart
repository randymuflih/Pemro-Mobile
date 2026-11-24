/// Model data buku di perpustakaan.
class Book {
  final String id;
  final String title;
  final String author;

  /// Jumlah total eksemplar buku yang dimiliki perpustakaan.
  final int stock;

  /// Jumlah eksemplar yang sedang tersedia (belum dipinjam).
  final int available;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.stock,
    required this.available,
  });

  /// `true` jika masih ada eksemplar yang bisa dipinjam.
  bool get isAvailable => available > 0;

  /// Membuat salinan buku dengan beberapa nilai yang diubah.
  /// Objek [Book] bersifat immutable (tidak bisa diubah langsung),
  /// jadi perubahan data selalu dilakukan dengan membuat objek baru.
  Book copyWith({
    String? title,
    String? author,
    int? stock,
    int? available,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      stock: stock ?? this.stock,
      available: available ?? this.available,
    );
  }

  /// Membuat [Book] dari Map (misalnya data JSON dari database).
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      stock: map['stock'] as int,
      available: map['available'] as int,
    );
  }

  /// Mengubah [Book] menjadi Map agar bisa disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'stock': stock,
      'available': available,
    };
  }
}
