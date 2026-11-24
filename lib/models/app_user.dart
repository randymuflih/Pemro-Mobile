/// Role (peran) pengguna. Dipakai untuk authorization:
/// - [admin]  : mengelola data buku dan melihat semua peminjaman.
/// - [member] : anggota biasa yang meminjam dan mengembalikan buku.
enum UserRole { admin, member }

/// Model data pengguna yang sedang login.
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.member, // Default: pengguna baru adalah anggota.
  });

  /// `true` jika pengguna adalah admin.
  bool get isAdmin => role == UserRole.admin;

  /// Nama role dalam Bahasa Indonesia untuk ditampilkan di UI.
  String get roleLabel => isAdmin ? 'Admin' : 'Anggota';

  /// Membuat [AppUser] dari Map (misalnya data JSON dari database).
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.byName(map['role'] as String? ?? 'member'),
    );
  }

  /// Mengubah [AppUser] menjadi Map agar bisa disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
}
