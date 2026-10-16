import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/session_manager.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserModel? _user;
  int _borrowedCount = 0;
  int _favoriteCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      _goToLogin();
      return;
    }

    final db = DatabaseHelper.instance;
    final user = await db.getUser(userId);
    final borrowings = await db.getUserBorrowings(userId);
    final favorites = await db.getUserFavorites(userId);

    if (!mounted) return;
    setState(() {
      _user = user;
      _borrowedCount =
          borrowings.where((b) => b['status'] == 'Dipinjam').length;
      _favoriteCount = favorites.length;
      _isLoading = false;
    });
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu harus login lagi untuk masuk ke akunmu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await SessionManager.clearSession();
      _goToLogin();
    }
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini segera hadir.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = _user?.name ?? '';
    final email = _user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Akun',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Profil
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primarySoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _comingSoon,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Ubah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dark,
                  side: const BorderSide(color: AppTheme.border),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Statistik
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.menu_book_rounded,
                    value: _borrowedCount,
                    label: 'Sedang dipinjam',
                  ),
                ),
                Container(width: 1, height: 44, color: AppTheme.border),
                Expanded(
                  child: _StatItem(
                    icon: Icons.favorite_rounded,
                    value: _favoriteCount,
                    label: 'Favorit',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Menu
          _MenuTile(
            icon: Icons.shield_outlined,
            title: 'Akun & Keamanan',
            subtitle: 'Atur info pribadi dan keamanan akunmu.',
            onTap: _comingSoon,
          ),
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            title: 'Favorit Saya',
            subtitle: 'Lihat buku yang kamu sukai.',
            onTap: _comingSoon,
          ),
          _MenuTile(
            icon: Icons.history_rounded,
            title: 'Riwayat Peminjaman',
            subtitle: 'Cek buku yang pernah dan sedang kamu pinjam.',
            onTap: _comingSoon,
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Aplikasi',
            subtitle: 'Sesuaikan pengalaman membaca sesuai kebutuhanmu.',
            onTap: _comingSoon,
          ),
          _MenuTile(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            subtitle: 'Keluar dari akun LibraryKu.',
            color: AppTheme.danger,
            showArrow: false,
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 36, color: AppTheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value',
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool showArrow;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = color ?? AppTheme.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 28, color: color ?? AppTheme.dark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: titleColor)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textMuted)),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.dark, size: 28),
          ],
        ),
      ),
    );
  }
}