LibraryKu - Aplikasi Manajemen Perpustakaan Digital

Aplikasi mobile berbasis Flutter dan Firebase untuk mengelola peminjaman buku, katalog bacaan, daftar favorit, notifikasi, serta dashboard admin perpustakaan.

Identitas Mahasiswa
Nama: Darrell Putra Prayata
NIM: 20250801150
Proyek: LibraryKu

Fitur Utama Aplikasi

1. Autentikasi & Keamanan Akun
Login dan Registrasi pengguna menggunakan email serta integrasi Google Sign-In (google_auth_service.dart).
Pengelolaan profil pengguna (account_screen.dart) dan pengaturan keamanan akun (account_security_screen.dart).

2. Eksplorasi & Katalog Buku
Halaman Beranda (home_screen.dart) dan Eksplorasi Buku (explore_screen.dart) untuk mencari koleksi perpustakaan.
Halaman Detail Buku (book_detail_screen.dart) yang menampilkan informasi lengkap buku.
Daftar Buku Favorit (favorites_screen.dart) untuk menyimpan buku pilihan pengguna.

3. Peminjaman & Riwayat
Layanan peminjaman dan pengembalian buku secara real-time (borrow_service.dart).
Halaman Koleksi Saya (library_screen.dart) dan Riwayat Peminjaman (borrowing_history_screen.dart).

4. Notifikasi & Dashboard Admin
Sistem notifikasi aktivitas peminjaman (notifications_screen.dart & notification_bell.dart).
Halaman Dashboard Admin (admin_dashboard_screen.dart) untuk mengelola data buku dan pengguna perpustakaan.

Struktur Proyek Utama
lib/main.dart: Entry point aplikasi dan inisialisasi Firebase.
lib/screens/: Berisi seluruh tampilan antarmuka pengguna (Login, Register, Home, Explore, Book Detail, Library, Favorites, Borrowing History, Account, Account Security, Notifications, Admin Dashboard).
lib/widgets/: Komponen UI yang dapat digunakan ulang seperti BookTile dan NotificationBell.
lib/utils/: Utilitas aplikasi termasuk penyimpanan lokal (database_helper.dart), format tanggal (date_format.dart), dan manajemen event data (data_events.dart).
borrow_service.dart & google_auth_service.dart: Layanan integrasi backend Firebase dan autentikasi Google.

Teknologi yang Digunakan
Flutter & Dart
Firebase Core & Firebase Authentication
Google Sign-In
SQLite / Database Helper lokal
