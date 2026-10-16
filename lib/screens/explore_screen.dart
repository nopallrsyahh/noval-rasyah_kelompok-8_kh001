import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

/// Halaman sementara. Nanti diisi pencarian dan grid kategori.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EmptyState(
        icon: Icons.explore_outlined,
        title: 'Jelajahi Segera Hadir',
        subtitle: 'Kategori dan pencarian buku akan muncul di sini.',
      ),
    );
  }
}