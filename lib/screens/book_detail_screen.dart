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

/// Membuka detail buku berdasarkan id (dipakai dari daftar peminjaman).
Future<void> openBookById(BuildContext context, int bookId) async {
  final book = await DatabaseHelper.instance.getBook(bookId);
  if (book == null || !context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
  );
}

class BookDetailScreen extends StatefulWidget {
  final BookModel book;
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late BookModel _book;
  int? _userId;
  bool _isFav = false;
  bool _busy = false;
  double _durasi = 7; // lama peminjaman (hari), 1 - 30

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _load();
  }

  Future<void> _load() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;
    final db = DatabaseHelper.instance;
    final fav = await db.isFavorite(userId, _book.id!);
    final fresh = await db.getBook(_book.id!);
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _isFav = fav;
      if (fresh != null) _book = fresh;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;
    await DatabaseHelper.instance.toggleFavorite(
      FavoriteModel(userId: _userId!, bookId: _book.id!),
    );
    DataEvents.notify();
    if (!mounted) return;
    setState(() => _isFav = !_isFav);
    _snack(_isFav ? 'Ditambahkan ke favorit.' : 'Dihapus dari favorit.');
  }

  /// Mengirim pengajuan peminjaman ke Firestore (status: Menunggu).
  /// Buku baru resmi dipinjam setelah disetujui admin.
  Future<void> _borrow() async {
    if (_userId == null || _busy) return;
    setState(() => _busy = true);

    try {
      final service = BorrowService.instance;

      // Cegah pengajuan ganda untuk buku yang sama.
      final sudahAda = await service.adaAktif(_userId!, _book.id!);
      if (!mounted) return;
      if (sudahAda) {
        _snack('Anda sudah mengajukan atau sedang meminjam buku ini.');
        return;
      }

      await service.ajukan(
        userId: _userId!,
        // Jika SessionManager punya getUserName(), ganti dengan itu.
        userName: 'User #$_userId',
        bookId: _book.id!,
        title: _book.title,
        author: _book.author,
        coverUrl: _book.coverUrl,
        durasiHari: _durasi.round(),
      );

      DataEvents.notify();
      if (!mounted) return;
      _snack('Pengajuan terkirim. Menunggu persetujuan admin.');
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mengajukan peminjaman: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Memilih tanggal pengembalian lewat kalender (1 - 30 hari dari hari ini).
  Future<void> _pilihTanggal() async {
    final today = DateTime.now();
    final awal = DateTime(today.year, today.month, today.day);

    final hasil = await showDatePicker(
      context: context,
      initialDate: awal.add(Duration(days: _durasi.round())),
      firstDate: awal.add(const Duration(days: BorrowService.minDurasi)),
      lastDate: awal.add(const Duration(days: BorrowService.maxDurasi)),
      helpText: 'Pilih tanggal pengembalian',
      confirmText: 'Pilih',
      cancelText: 'Batal',
    );

    if (hasil == null || !mounted) return;
    setState(() => _durasi = hasil.difference(awal).inDays.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final available = _book.stock > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFav ? AppTheme.danger : AppTheme.dark,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
              child: BookCover(url: _book.coverUrl, width: 150, height: 215)),
          const SizedBox(height: 20),
          Text(_book.title,
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_book.author,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(label: Text(_book.category)),
              const SizedBox(width: 8),
              Chip(
                label: Text(available ? 'Stok: ${_book.stock}' : 'Stok habis'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Deskripsi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_book.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          const Text('Lama Peminjaman',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _busy ? null : _pilihTanggal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dikembalikan paling lambat',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDate(DateTime.now()
                              .add(Duration(days: _durasi.round()))
                              .toIso8601String()),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_durasi.round()} hari',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final d in const [1, 3, 7, 14, 30])
                ChoiceChip(
                  label: Text('$d hari'),
                  selected: _durasi.round() == d,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _durasi = d.toDouble()),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ketuk kartu untuk memilih tanggal di kalender (maksimal 30 hari). '
                'Tenggat dihitung sejak pengajuan disetujui admin.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Denda keterlambatan ${BorrowService.rupiah(BorrowService.dendaPerHari)} per hari.',
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: available && !_busy ? _borrow : null,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(available ? 'Ajukan Peminjaman' : 'Stok Habis'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}