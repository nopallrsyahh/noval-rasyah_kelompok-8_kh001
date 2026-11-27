import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import '../services/borrow_service.dart';
import '../utils/session_manager.dart';

/// Ikon lonceng dengan badge jumlah pengingat tenggat (real-time).
/// Dipakai di header home_screen.dart.
class NotificationBell extends StatefulWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final id = await SessionManager.getUserId();
    if (!mounted) return;
    setState(() => _userId = id);
  }

  @override
  Widget build(BuildContext context) {
    final stream = _userId == null
        ? const Stream<List<Map<String, dynamic>>>.empty()
        : BorrowService.instance.streamUser(_userId!);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        final count = snap.hasData
            ? BorrowService.buildReminders(snap.data!).length
            : 0;

        return GestureDetector(
          onTap: () {
            if (_userId == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(userId: _userId!),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 22, color: Color(0xFF1E293B)),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}