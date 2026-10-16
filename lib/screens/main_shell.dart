import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'account_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  Key _accountKey = UniqueKey();

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    _NavItem(Icons.search_rounded, Icons.search_rounded, 'Jelajahi'),
    _NavItem(Icons.local_library_outlined, Icons.local_library_rounded,
        'Perpustakaan'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Akun'),
  ];

  void _onTap(int i) {
    setState(() {
      // Buat ulang halaman Akun supaya statistiknya selalu terbaru
      if (i == 3 && _index != 3) _accountKey = UniqueKey();
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const ExploreScreen(),
      const LibraryScreen(),
      AccountScreen(key: _accountKey),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == _index;
              final color = selected ? AppTheme.primary : AppTheme.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 3,
                        color: selected ? AppTheme.primary : Colors.transparent,
                      ),
                      const SizedBox(height: 8),
                      Icon(selected ? item.activeIcon : item.icon,
                          color: color, size: 26),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}