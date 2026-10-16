import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

/// Halaman sementara. Nanti diisi tab "Semua" dan "Koleksi Saya"
/// (peminjaman dan favorit).
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EmptyState(
        icon: Icons.local_library_outlined,
        title: 'Koleksi Belum Tersedia',
        subtitle: 'Pinjam buku atau tandai favorit untuk melihatnya di sini.',
      ),
    );
  }
}