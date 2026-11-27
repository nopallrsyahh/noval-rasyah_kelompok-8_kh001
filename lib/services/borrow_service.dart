import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/date_format.dart';

/// Pengingat tenggat untuk ditampilkan ke user.
class BorrowReminder {
  final String title;
  final String message;

  /// 1 = peringatan (mendekati tenggat), 2 = bahaya (terlambat)
  final int level;
  final Map<String, dynamic> item;

  const BorrowReminder({
    required this.title,
    required this.message,
    required this.level,
    required this.item,
  });
}

/// Mengelola data peminjaman di Firestore (collection `peminjaman`).
///
/// Alur status:
///   Menunggu -> (admin setujui) -> Dipinjam -> (admin konfirmasi) -> Dikembalikan
///   Menunggu -> (admin tolak)   -> Ditolak
class BorrowService {
  BorrowService._();
  static final BorrowService instance = BorrowService._();

  static const String menunggu = 'Menunggu';
  static const String dipinjam = 'Dipinjam';
  static const String ditolak = 'Ditolak';
  static const String dikembalikan = 'Dikembalikan';

  /// Denda per hari keterlambatan (rupiah).
  static const int dendaPerHari = 1000;

  /// Rentang durasi pinjam yang boleh dipilih user (hari).
  static const int minDurasi = 1;
  static const int maxDurasi = 30;

  /// Pengingat muncul saat sisa hari <= nilai ini (H-2, H-1, hari H).
  static const int batasPengingatHari = 2;

  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('peminjaman');

  // ------------------------------------------------------------ User
  /// Dipanggil user saat menekan "Pinjam". Status awal: Menunggu.
  Future<void> ajukan({
    required int userId,
    required String userName,
    required int bookId,
    required String title,
    required String author,
    required String coverUrl,
    int durasiHari = 7,
  }) {
    final durasi = durasiHari.clamp(minDurasi, maxDurasi);
    return _col.add({
      'userId': userId,
      'userName': userName,
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'durasiHari': durasi,
      'status': menunggu,
      'tanggalPengajuan': DateTime.now().toIso8601String(),
      'borrowDate': null,
      'returnDate': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// True jika user masih punya pengajuan (Menunggu) atau pinjaman aktif
  /// (Dipinjam) untuk buku yang sama.
  Future<bool> adaAktif(int userId, int bookId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    return snap.docs.any((d) {
      final m = d.data();
      return m['bookId'] == bookId &&
          (m['status'] == menunggu || m['status'] == dipinjam);
    });
  }

  /// Peminjaman milik satu user (real-time).
  Stream<List<Map<String, dynamic>>> streamUser(int userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(_toList);
  }

  // ----------------------------------------------------------- Admin
  /// Seluruh peminjaman (real-time) untuk dashboard admin.
  Stream<List<Map<String, dynamic>>> streamAll() {
    return _col.snapshots().map(_toList);
  }

  /// Menyetujui pengajuan. Tenggat dihitung dari tanggal persetujuan.
  Future<void> setujui(Map<String, dynamic> item) {
    final now = DateTime.now();
    final durasi = ((item['durasiHari'] as num?)?.toInt() ?? 7)
        .clamp(minDurasi, maxDurasi);
    return _col.doc(item['docId'] as String).update({
      'status': dipinjam,
      'borrowDate': now.toIso8601String(),
      'returnDate': now.add(Duration(days: durasi)).toIso8601String(),
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> tolak(Map<String, dynamic> item) {
    return _col.doc(item['docId'] as String).update({
      'status': ditolak,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Konfirmasi pengembalian. Denda dihitung dan dibekukan saat ini.
  Future<void> kembalikan(Map<String, dynamic> item) {
    final hari = hariTerlambat(item);
    return _col.doc(item['docId'] as String).update({
      'status': dikembalikan,
      'returnedAt': FieldValue.serverTimestamp(),
      'hariTerlambat': hari,
      'dendaPerHari': dendaPerHari,
      'denda': hari * dendaPerHari,
    });
  }

  // ------------------------------------------- Tenggat, denda, notifikasi
  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  /// Sisa hari sampai tenggat (negatif = sudah lewat).
  static int sisaHari(Map<String, dynamic> item, {DateTime? now}) {
    final due = DateTime.tryParse((item['returnDate'] ?? '') as String);
    if (due == null) return 0;
    return _dateOnly(due).difference(_dateOnly(now ?? DateTime.now())).inDays;
  }

  /// Jumlah hari terlambat. Pengembalian di hari tenggat = 0 hari.
  /// Untuk status Dipinjam dihitung real-time, untuk Dikembalikan memakai
  /// nilai yang sudah dibekukan saat admin konfirmasi.
  static int hariTerlambat(Map<String, dynamic> item, {DateTime? now}) {
    final status = item['status'];
    if (status == dikembalikan) {
      return (item['hariTerlambat'] as num?)?.toInt() ?? 0;
    }
    if (status != dipinjam) return 0;
    final sisa = sisaHari(item, now: now);
    return sisa < 0 ? -sisa : 0;
  }

  /// Denda dalam rupiah (Rp1.000 x hari terlambat).
  static int denda(Map<String, dynamic> item, {DateTime? now}) {
    if (item['status'] == dikembalikan) {
      return (item['denda'] as num?)?.toInt() ?? 0;
    }
    return hariTerlambat(item, now: now) * dendaPerHari;
  }

  static String rupiah(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp$buf';
  }

  /// Menyusun daftar pengingat dari peminjaman aktif milik user.
  static List<BorrowReminder> buildReminders(
      List<Map<String, dynamic>> items, {
        DateTime? now,
      }) {
    final result = <BorrowReminder>[];

    for (final item in items) {
      if (item['status'] != dipinjam) continue;

      final title = (item['title'] ?? '') as String;
      final sisa = sisaHari(item, now: now);
      final tgl = formatDate((item['returnDate'] ?? '') as String);

      if (sisa < 0) {
        final hari = -sisa;
        result.add(BorrowReminder(
          title: 'Buku terlambat dikembalikan',
          message: '"$title" terlambat $hari hari. Denda saat ini '
              '${rupiah(hari * dendaPerHari)}. Segera kembalikan ke admin.',
          level: 2,
          item: item,
        ));
      } else if (sisa == 0) {
        result.add(BorrowReminder(
          title: 'Batas pengembalian hari ini',
          message: '"$title" harus dikembalikan hari ini ($tgl). '
              'Terlambat dikenai denda ${rupiah(dendaPerHari)} per hari.',
          level: 1,
          item: item,
        ));
      } else if (sisa <= batasPengingatHari) {
        result.add(BorrowReminder(
          title: 'Mendekati batas pengembalian',
          message: '"$title" harus dikembalikan $sisa hari lagi ($tgl).',
          level: 1,
          item: item,
        ));
      }
    }

    result.sort((a, b) => b.level.compareTo(a.level));
    return result;
  }

  // ---------------------------------------------------------- Helper
  List<Map<String, dynamic>> _toList(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = snapshot.docs.map((d) {
      final m = Map<String, dynamic>.from(d.data());
      m['docId'] = d.id;
      return m;
    }).toList();

    // Urutkan terbaru di atas (tanpa composite index Firestore).
    int millis(Map<String, dynamic> m) {
      final t = m['createdAt'];
      if (t is Timestamp) return t.millisecondsSinceEpoch;
      return DateTime.now().millisecondsSinceEpoch; // write lokal belum sync
    }

    list.sort((a, b) => millis(b).compareTo(millis(a)));
    return list;
  }
}