import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/borrow_service.dart';
import '../utils/date_format.dart';
import 'login_screen.dart';

const Color _bg = Color(0xFFF1F5F9);
const Color _dark = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _indigo = Color(0xFF4F46E5);
const Color _red = Color(0xFFDC2626);

/// Dashboard admin: statistik, persetujuan pengajuan pinjam, dan
/// konfirmasi pengembalian (beserta denda). Data real-time dari Firestore.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: BorrowService.instance.streamAll(),
          builder: (context, snap) {
            final all = snap.data ?? const <Map<String, dynamic>>[];

            List<Map<String, dynamic>> by(List<String> s) =>
                all.where((e) => s.contains(e['status'])).toList();

            final menunggu = by([BorrowService.menunggu]);
            final dipinjam = by([BorrowService.dipinjam]);
            final riwayat =
            by([BorrowService.dikembalikan, BorrowService.ditolak]);

            final terlambat = dipinjam
                .where((e) => BorrowService.hariTerlambat(e) > 0)
                .length;
            final dendaBerjalan = dipinjam.fold<int>(
                0, (sum, e) => sum + BorrowService.denda(e));

            Widget body;
            if (snap.hasError) {
              body = _Message(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat data',
                subtitle: '${snap.error}',
              );
            } else if (!snap.hasData) {
              body = const Center(child: CircularProgressIndicator());
            } else {
              body = TabBarView(
                children: [
                  _AdminList(
                    items: menunggu,
                    icon: Icons.inbox_outlined,
                    title: 'Tidak ada pengajuan baru',
                    subtitle: 'Pengajuan pinjam dari user akan muncul di sini.',
                  ),
                  _AdminList(
                    items: dipinjam,
                    icon: Icons.menu_book_outlined,
                    title: 'Tidak ada buku dipinjam',
                    subtitle: 'Buku yang sedang dipinjam akan muncul di sini.',
                  ),
                  _AdminList(
                    items: riwayat,
                    icon: Icons.history_rounded,
                    title: 'Belum ada riwayat',
                    subtitle: 'Peminjaman yang selesai atau ditolak ada di sini.',
                  ),
                ],
              );
            }

            return Column(
              children: [
                _Header(
                  menunggu: menunggu.length,
                  dipinjam: dipinjam.length,
                  terlambat: terlambat,
                  denda: dendaBerjalan,
                  onLogout: () => _logout(context),
                ),
                _Tabs(
                  menunggu: menunggu.length,
                  dipinjam: dipinjam.length,
                  riwayat: riwayat.length,
                ),
                Expanded(child: body),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Header
class _Header extends StatelessWidget {
  final int menunggu;
  final int dipinjam;
  final int terlambat;
  final int denda;
  final VoidCallback onLogout;

  const _Header({
    required this.menunggu,
    required this.dipinjam,
    required this.terlambat,
    required this.denda,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Kelola peminjaman LibraryKu',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Keluar',
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Menunggu',
                  value: '$menunggu',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.auto_stories_rounded,
                  label: 'Dipinjam',
                  value: '$dipinjam',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Terlambat',
                  value: '$terlambat',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.payments_outlined,
                  label: 'Denda berjalan',
                  value: BorrowService.rupiah(denda),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Tabs
class _Tabs extends StatelessWidget {
  final int menunggu;
  final int dipinjam;
  final int riwayat;

  const _Tabs({
    required this.menunggu,
    required this.dipinjam,
    required this.riwayat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: _indigo,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(text: 'Menunggu ($menunggu)'),
          Tab(text: 'Dipinjam ($dipinjam)'),
          Tab(text: 'Riwayat ($riwayat)'),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ List
class _AdminList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminList({
    required this.items,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Message(icon: icon, title: title, subtitle: subtitle);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, i) => _AdminCard(item: items[i]),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _indigo.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: _indigo),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Card
class _AdminCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _AdminCard({required this.item});

  String _fmt(dynamic v) {
    if (v is String && v.isNotEmpty) return formatDate(v);
    if (v is Timestamp) return formatDate(v.toDate().toIso8601String());
    return '-';
  }

  Future<void> _run(
      BuildContext context,
      Future<void> Function() action,
      String okMessage,
      ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(okMessage)));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Gagal memproses: $e'),
          backgroundColor: _red,
        ));
    }
  }

  Future<void> _konfirmasiKembali(BuildContext context) async {
    final hari = BorrowService.hariTerlambat(item);
    final denda = BorrowService.denda(item);
    final judul = (item['title'] ?? '') as String;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Text(
          hari > 0
              ? 'Buku "$judul" terlambat $hari hari.\n'
              'Denda yang harus dibayar: ${BorrowService.rupiah(denda)}.\n\n'
              'Tandai sebagai dikembalikan?'
              : 'Tandai buku "$judul" sebagai dikembalikan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Dikembalikan'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;
    await _run(
      context,
          () => BorrowService.instance.kembalikan(item),
      hari > 0
          ? 'Buku dikembalikan. Denda ${BorrowService.rupiah(denda)}.'
          : 'Buku ditandai sudah dikembalikan.',
    );
  }

  Color _statusColor(String status, bool telat) {
    if (telat) return _red;
    switch (status) {
      case BorrowService.menunggu:
        return const Color(0xFFD97706);
      case BorrowService.dipinjam:
        return const Color(0xFF2563EB);
      case BorrowService.ditolak:
        return _red;
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? '') as String;
    final service = BorrowService.instance;
    final hariTelat = BorrowService.hariTerlambat(item);
    final telatAktif = status == BorrowService.dipinjam && hariTelat > 0;
    final statusColor = _statusColor(status, telatAktif);
    final userName = (item['userName'] ?? 'User') as String;

    final List<Widget> chips = [];
    switch (status) {
      case BorrowService.menunggu:
        chips.add(_InfoChip(
            icon: Icons.event_note_rounded,
            text: 'Diajukan ${_fmt(item['tanggalPengajuan'])}'));
        chips.add(_InfoChip(
            icon: Icons.timer_outlined,
            text: '${item['durasiHari'] ?? 7} hari'));
        break;
      case BorrowService.dipinjam:
        chips.add(_InfoChip(
            icon: Icons.event_available_rounded,
            text: 'Dipinjam ${_fmt(item['borrowDate'])}'));
        chips.add(_InfoChip(
            icon: Icons.event_busy_rounded,
            text: 'Batas ${_fmt(item['returnDate'])}'));
        break;
      case BorrowService.dikembalikan:
        chips.add(_InfoChip(
            icon: Icons.event_available_rounded,
            text: 'Dipinjam ${_fmt(item['borrowDate'])}'));
        chips.add(_InfoChip(
            icon: Icons.assignment_turned_in_rounded,
            text: 'Kembali ${_fmt(item['returnedAt'])}'));
        break;
      default:
        chips.add(_InfoChip(
            icon: Icons.event_note_rounded,
            text: 'Diajukan ${_fmt(item['tanggalPengajuan'])}'));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: telatAktif ? Border.all(color: _red.withAlpha(90)) : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    (item['coverUrl'] ?? '') as String,
                    width: 58,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 58,
                      height: 82,
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              (item['title'] ?? '') as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _dark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(28),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              telatAktif ? 'Terlambat' : status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (item['author'] ?? '') as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _muted),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: _indigo.withAlpha(30),
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _indigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _dark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
            if (hariTelat > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _red.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: _red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Terlambat $hariTelat hari \u2022 '
                            'Denda ${BorrowService.rupiah(BorrowService.denda(item))}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (status == BorrowService.menunggu) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _red,
                        side: BorderSide(color: _red.withAlpha(120)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Tolak'),
                      onPressed: () => _run(
                        context,
                            () => service.tolak(item),
                        'Pengajuan ditolak.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Setujui'),
                      onPressed: () => _run(
                        context,
                            () => service.setujui(item),
                        'Peminjaman disetujui.',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (status == BorrowService.dipinjam) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.assignment_return_rounded, size: 18),
                label: const Text('Tandai Dikembalikan'),
                onPressed: () => _konfirmasiKembali(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _muted),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
        ],
      ),
    );
  }
}