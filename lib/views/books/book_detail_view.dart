import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book_model.dart';
import '../../viewmodels/book_vm.dart';
import 'book_form_dialog.dart';

class BookDetailView extends ConsumerWidget {
  final BookModel book;

  const BookDetailView({super.key, required this.book});

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookFormDialog(
        book: book,
        onSubmit: (payload) =>
            ref.read(bookProvider.notifier).update(book.id, payload),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Hapus "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await ref.read(bookProvider.notifier).delete(book.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    Navigator.pop(context);
  }

  Widget _field(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 28),
              _field(context, 'Penulis', book.author),
              _field(context, 'Penerbit', book.publisher ?? '-'),
              _field(context, 'ISBN', book.isbn),
              _field(context, 'Tahun Terbit', book.publishedYear.toString()),
              _field(context, 'Stok', book.stock.toString()),
              _field(context, 'Deskripsi', book.description ?? '-'),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _edit(context, ref),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
