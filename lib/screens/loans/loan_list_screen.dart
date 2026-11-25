import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/loan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/loan_provider.dart';
import '../../utils/date_format.dart';

/// Halaman daftar peminjaman.
///
/// - Anggota : hanya melihat pinjaman miliknya sendiri ("Pinjaman Saya").
/// - Admin   : melihat semua peminjaman dari semua anggota ("Peminjaman").
/// Pemilihan data ini dilakukan di LoanProvider.loadLoans, bukan di sini.
///
/// Isinya dibagi dua tab: buku yang masih dipinjam dan riwayat pengembalian.
class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  @override
  void initState() {
    super.initState();
    // HomeScreen memakai IndexedStack, jadi halaman ini sudah dibuat sejak
    // awal login. Data pinjaman ikut dimuat di sini supaya tombol Pinjam
    // di katalog langsung tahu buku mana yang sedang dipinjam user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoanProvider>().loadLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanProvider>();
    final isAdmin = context.select<AuthProvider, bool>((a) => a.isAdmin);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Dipinjam (${provider.activeLoans.length})'),
              Tab(text: 'Riwayat (${provider.returnedLoans.length})'),
            ],
          ),
          // Garis loading tipis saat memuat atau memproses pengembalian.
          if (provider.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: TabBarView(
              children: [
                _LoanList(
                  loans: provider.activeLoans,
                  isAdmin: isAdmin,
                  emptyText: 'Tidak ada buku yang sedang dipinjam.',
                ),
                _LoanList(
                  loans: provider.returnedLoans,
                  isAdmin: isAdmin,
                  emptyText: 'Belum ada riwayat pengembalian.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar peminjaman untuk satu tab.
class _LoanList extends StatelessWidget {
  const _LoanList({
    required this.loans,
    required this.isAdmin,
    required this.emptyText,
  });

  final List<Loan> loans;
  final bool isAdmin;
  final String emptyText;

  /// Mengembalikan buku, lalu memuat ulang daftar buku
  /// agar jumlah "tersedia" di katalog ikut bertambah.
  Future<void> _return(BuildContext context, Loan loan) async {
    // Ambil semua yang butuh context sebelum `await`.
    final loanProvider = context.read<LoanProvider>();
    final bookProvider = context.read<BookProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await loanProvider.returnLoan(loan);
    if (success) await bookProvider.loadBooks();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '"${loan.bookTitle}" dikembalikan.'
              : loanProvider.errorMessage ?? 'Gagal mengembalikan buku.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LoanProvider>();

    return RefreshIndicator(
      onRefresh: provider.loadLoans,
      // Saat kosong tetap memakai ListView supaya tarik-untuk-refresh
      // masih bisa dipakai.
      child: loans.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 120),
                Center(child: Text(emptyText)),
              ],
            )
          : ListView.separated(
              itemCount: loans.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final loan = loans[index];
                // Baris keterangan; nama peminjam hanya perlu dilihat admin.
                final lines = [
                  if (isAdmin) 'Peminjam: ${loan.userName}',
                  'Dipinjam: ${formatDate(loan.borrowedAt)}',
                  if (loan.returnedAt != null)
                    'Dikembalikan: ${formatDate(loan.returnedAt!)}',
                ];
                return ListTile(
                  leading: Icon(
                    loan.isReturned ? Icons.check_circle : Icons.schedule,
                    color: loan.isReturned ? Colors.green : Colors.orange,
                  ),
                  title: Text(loan.bookTitle),
                  subtitle: Text(lines.join('\n')),
                  isThreeLine: lines.length > 1,
                  // Tombol Kembalikan hanya untuk pinjaman yang masih aktif.
                  trailing: loan.isReturned
                      ? null
                      : TextButton(
                          key: Key('return_${loan.id}'),
                          onPressed: provider.isLoading
                              ? null
                              : () => _return(context, loan),
                          child: const Text('Kembalikan'),
                        ),
                );
              },
            ),
    );
  }
}
