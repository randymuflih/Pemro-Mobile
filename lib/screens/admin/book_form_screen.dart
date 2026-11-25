import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../utils/validators.dart';

/// Form tambah buku dan ubah buku (khusus admin).
///
/// Satu halaman dipakai untuk dua keperluan:
/// - [book] null      : mode tambah, form kosong.
/// - [book] terisi    : mode ubah, form diisi data buku tersebut.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _stockController;

  bool get _isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title);
    _authorController = TextEditingController(text: book?.author);
    _stockController = TextEditingController(text: book?.stock.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Validasi form, simpan lewat BookProvider, lalu kembali ke daftar buku.
  /// Jika provider menolak (misalnya stok kurang dari yang dipinjam),
  /// pesan error tampil di bawah form dan halaman tidak ditutup.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = context.read<BookProvider>();
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final stock = int.parse(_stockController.text.trim());

    final success = _isEdit
        ? await provider.updateBook(
            widget.book!,
            title: title,
            author: author,
            stock: stock,
          )
        : await provider.addBook(title: title, author: author, stock: stock);

    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Buku "$title" diperbarui.' : 'Buku "$title" ditambahkan.'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final theme = Theme.of(context);
    final book = widget.book;
    final borrowed = book == null ? 0 : book.stock - book.available;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Buku' : 'Tambah Buku')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('book_title'),
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Judul'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('book_author'),
                  controller: _authorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Penulis',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Penulis'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('book_stock'),
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    border: const OutlineInputBorder(),
                    // Saat ubah buku, beri tahu batas minimal stok.
                    helperText: borrowed > 0
                        ? '$borrowed eksemplar sedang dipinjam, stok minimal $borrowed'
                        : null,
                  ),
                  validator: (v) => Validators.positiveNumber(v, 'Stok'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('book_save_button'),
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
