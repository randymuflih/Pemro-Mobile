/// Model data peminjaman buku oleh seorang anggota.
class Loan {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;

  /// Waktu buku dipinjam.
  final DateTime borrowedAt;

  /// Waktu buku dikembalikan. `null` artinya buku masih dipinjam.
  final DateTime? returnedAt;

  const Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.borrowedAt,
    this.returnedAt,
  });

  /// `true` jika buku sudah dikembalikan.
  bool get isReturned => returnedAt != null;

  /// Membuat salinan peminjaman, dipakai saat buku dikembalikan.
  Loan copyWith({DateTime? returnedAt}) {
    return Loan(
      id: id,
      bookId: bookId,
      bookTitle: bookTitle,
      userId: userId,
      userName: userName,
      borrowedAt: borrowedAt,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }

  /// Membuat [Loan] dari Map. Tanggal disimpan sebagai teks ISO 8601,
  /// contoh: "2026-11-24T09:05:00.000".
  factory Loan.fromMap(Map<String, dynamic> map) {
    final returnedAt = map['returned_at'] as String?;
    return Loan(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      bookTitle: map['book_title'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      borrowedAt: DateTime.parse(map['borrowed_at'] as String),
      returnedAt: returnedAt == null ? null : DateTime.parse(returnedAt),
    );
  }

  /// Mengubah [Loan] menjadi Map agar bisa disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'book_title': bookTitle,
      'user_id': userId,
      'user_name': userName,
      'borrowed_at': borrowedAt.toIso8601String(),
      'returned_at': returnedAt?.toIso8601String(),
    };
  }
}
