import 'package:flutter/material.dart';
import '../services/borrow_service.dart';
import '../widgets/empty_state.dart';

/// Daftar pengingat: mendekati tenggat dan keterlambatan beserta denda.
class NotificationsScreen extends StatelessWidget {
  final int userId;
  const NotificationsScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: BorrowService.instance.streamUser(userId),
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal Memuat Notifikasi',
              subtitle: '${snap.error}',
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data!;
          final reminders = BorrowService.buildReminders(items);

          if (reminders.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Tidak Ada Notifikasi',
              subtitle:
              'Pengingat tenggat pengembalian akan muncul di sini.',
            );
          }

          final totalDenda = items.fold<int>(
            0,
                (sum, e) => sum +
                (e['status'] == BorrowService.dipinjam
                    ? BorrowService.denda(e)
                    : 0),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (totalDenda > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined,
                          color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Total denda berjalan: '
                              '${BorrowService.rupiah(totalDenda)}. '
                              'Pembayaran diselesaikan ke admin saat mengembalikan buku.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              for (final r in reminders) _ReminderCard(reminder: r),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final BorrowReminder reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final danger = reminder.level >= 2;
    final color = danger ? Colors.red.shade700 : Colors.orange.shade800;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(
            danger ? Icons.warning_amber_rounded : Icons.schedule_rounded,
            color: color,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(reminder.message, style: const TextStyle(height: 1.4)),
        ),
        isThreeLine: true,
      ),
    );
  }
}