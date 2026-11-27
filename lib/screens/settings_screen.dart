import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/data_events.dart';
import '../utils/session_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _clearHistory(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus riwayat?'),
        content: const Text(
            'Semua riwayat buku yang sudah dikembalikan akan dihapus. Buku yang sedang dipinjam tidak terpengaruh.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    final userId = await SessionManager.getUserId();
    if (userId == null) return;
    final n = await DatabaseHelper.instance.clearReturnedHistory(userId);
    DataEvents.notify();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$n riwayat dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: AppTheme.dark),
            title: const Text('Hapus riwayat peminjaman'),
            subtitle: const Text('Bersihkan buku yang sudah dikembalikan.'),
            onTap: () => _clearHistory(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.dark),
            title: const Text('Tentang LibraryKu'),
            subtitle: const Text('Versi 1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'LibraryKu',
              applicationVersion: '1.0.0',
              children: const [
                Text('Aplikasi perpustakaan digital untuk meminjam buku.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
