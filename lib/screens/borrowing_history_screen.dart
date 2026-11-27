import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'library_screen.dart';

/// Riwayat peminjaman user (read-only).
/// Tidak ada fitur pengembalian manual; pengembalian dikonfirmasi admin.
class BorrowingHistoryScreen extends StatelessWidget {
  const BorrowingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withAlpha(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppTheme.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pengembalian buku dikonfirmasi oleh admin perpustakaan.',
                    style: TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: BorrowedBooksList(onlyActive: false)),
        ],
      ),
    );
  }
}