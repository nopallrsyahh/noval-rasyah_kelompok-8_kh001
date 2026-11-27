import 'package:flutter/foundation.dart';

/// Pemicu sederhana agar semua halaman memuat ulang data
/// setelah ada perubahan (pinjam, kembalikan, favorit, dll).
class DataEvents {
  static final ValueNotifier<int> changed = ValueNotifier<int>(0);
  static void notify() => changed.value++;
}
