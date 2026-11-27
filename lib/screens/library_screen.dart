import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/favorite_model.dart';
import '../services/borrow_service.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/data_events.dart';
import '../utils/date_format.dart';
import '../utils/session_manager.dart';
import '../widgets/book_tile.dart';
import '../widgets/empty_state.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Perpustakaan',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            ),
            TabBar(
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primary,
              tabs: [
                Tab(text: 'Semua'),
                Tab(text: 'Dipinjam'),
                Tab(text: 'Favorit'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AllBooksTab(),
                  BorrowedBooksList(onlyActive: true),
                  FavoriteBooksList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Semua
class _AllBooksTab extends StatefulWidget {
  const _AllBooksTab();

  @override
  State<_AllBooksTab> createState() => _AllBooksTabState();
}

class _AllBooksTabState extends State<_AllBooksTab> {
  List<BookModel> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DataEvents.changed.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DataEvents.changed.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final result = await DatabaseHelper.instance.getAllBooks();
    if (!mounted) return;
    setState(() {
      _books = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_books.isEmpty) {
      return const EmptyState(
        icon: Icons.local_library_outlined,
        title: 'Belum Ada Buku',
        subtitle: 'Koleksi buku akan muncul di sini.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _books.length,
      itemBuilder: (_, i) {
        final b = _books[i];
        return BookTile(
          title: b.title,
          author: b.author,
          coverUrl: b.coverUrl,
          subtitle: Text(b.category,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: b)),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------- Dipinjam
/// Daftar peminjaman milik user, diambil real-time dari Firestore.
///
/// [onlyActive] true  = hanya yang masih berjalan (Menunggu & Dipinjam),
///              false = seluruh riwayat (termasuk Ditolak & Dikembalikan).
///
/// User TIDAK bisa mengembalikan buku sendiri. Pengembalian hanya bisa
/// dikonfirmasi oleh admin lewat dashboard admin.
class BorrowedBooksList extends StatefulWidget {
  final bool onlyActive;
  const BorrowedBooksList({Key? key, required this.onlyActive})
      : super(key: key);

  @override
  State<BorrowedBooksList> createState() => _BorrowedBooksListState();
}

class _BorrowedBooksListState extends State<BorrowedBooksList> {
  int? _userId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final id = await SessionManager.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = id;
      _loadingUser = false;
    });
  }

  String _fmt(dynamic v) {
    if (v is String && v.isNotEmpty) return formatDate(v);
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) return const Center(child: CircularProgressIndicator());
    if (_userId == null) {
      return const EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Belum Login',
        subtitle: 'Silakan login terlebih dahulu.',
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: BorrowService.instance.streamUser(_userId!),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Gagal Memuat Data',
            subtitle: '${snap.error}',
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snap.data!;
        final items = widget.onlyActive
            ? all
            .where((b) =>
        b['status'] == BorrowService.menunggu ||
            b['status'] == BorrowService.dipinjam)
            .toList()
            : all;

        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.menu_book_outlined,
            title: widget.onlyActive
                ? 'Tidak Ada Buku Dipinjam'
                : 'Belum Ada Riwayat',
            subtitle: 'Pinjam buku dari halaman Jelajahi.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final b = items[i];
            return BookTile(
              title: (b['title'] ?? '') as String,
              author: (b['author'] ?? '') as String,
              coverUrl: (b['coverUrl'] ?? '') as String,
              onTap: () => openBookById(context, b['bookId'] as int),
              subtitle: _buildSubtitle(b),
              // Tidak ada tombol "Kembalikan": hanya admin yang bisa.
              trailing: null,
            );
          },
        );
      },
    );
  }

  Widget _buildSubtitle(Map<String, dynamic> b) {
    final status = b['status'] as String?;
    final hariTelat = BorrowService.hariTerlambat(b);
    final denda = BorrowService.denda(b);

    Widget muted(String t) => Text(
      t,
      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
    );
    Widget bold(String t, Color c) => Text(
      t,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c,
      ),
    );

    final List<Widget> lines = [];

    switch (status) {
      case BorrowService.menunggu:
        lines.add(muted(
            'Diajukan ${_fmt(b['tanggalPengajuan'])} \u2022 ${b['durasiHari'] ?? 7} hari'));
        lines.add(bold('Menunggu persetujuan admin', Colors.orange.shade800));
        break;

      case BorrowService.dipinjam:
        lines.add(muted('Dipinjam ${_fmt(b['borrowDate'])}'));
        lines.add(muted('Batas kembali ${_fmt(b['returnDate'])}'));
        if (hariTelat > 0) {
          lines.add(bold(
            'Terlambat $hariTelat hari \u2022 Denda ${BorrowService.rupiah(denda)}',
            Colors.red.shade700,
          ));
        } else {
          final sisa = BorrowService.sisaHari(b);
          lines.add(bold(
            sisa == 0 ? 'Jatuh tempo hari ini' : 'Sisa $sisa hari',
            sisa <= BorrowService.batasPengingatHari
                ? Colors.orange.shade800
                : Colors.blue.shade700,
          ));
        }
        break;

      case BorrowService.ditolak:
        lines.add(muted('Diajukan ${_fmt(b['tanggalPengajuan'])}'));
        lines.add(bold('Pengajuan ditolak admin', Colors.red.shade700));
        break;

      default: // Dikembalikan
        lines.add(muted('Dipinjam ${_fmt(b['borrowDate'])}'));
        lines.add(hariTelat > 0
            ? bold(
          'Dikembalikan \u2022 Terlambat $hariTelat hari, denda ${BorrowService.rupiah(denda)}',
          Colors.red.shade700,
        )
            : bold('Dikembalikan', Colors.green.shade700));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}

// --------------------------------------------------------------- Favorit
class FavoriteBooksList extends StatefulWidget {
  const FavoriteBooksList({Key? key}) : super(key: key);

  @override
  State<FavoriteBooksList> createState() => _FavoriteBooksListState();
}

class _FavoriteBooksListState extends State<FavoriteBooksList> {
  List<BookModel> _books = [];
  int? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DataEvents.changed.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DataEvents.changed.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;
    final rows = await DatabaseHelper.instance.getUserFavorites(userId);
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _books = rows.map((m) => BookModel.fromMap(m)).toList();
      _loading = false;
    });
  }

  Future<void> _remove(BookModel b) async {
    await DatabaseHelper.instance
        .toggleFavorite(FavoriteModel(userId: _userId!, bookId: b.id!));
    DataEvents.notify();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_books.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Belum Ada Favorit',
        subtitle: 'Tandai buku dengan ikon hati untuk menyimpannya di sini.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: _books.length,
      itemBuilder: (_, i) {
        final b = _books[i];
        return BookTile(
          title: b.title,
          author: b.author,
          coverUrl: b.coverUrl,
          subtitle: Text(b.category,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
          trailing: IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppTheme.danger),
            onPressed: () => _remove(b),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: b)),
          ),
        );
      },
    );
  }
}