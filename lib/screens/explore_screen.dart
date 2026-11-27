import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/data_events.dart';
import '../widgets/book_tile.dart';
import '../widgets/empty_state.dart';
import 'book_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  List<String> _categories = ['Semua'];
  String _selected = 'Semua';
  List<BookModel> _books = [];
  bool _loading = true;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    DataEvents.changed.addListener(_search);
    _init();
  }

  @override
  void dispose() {
    DataEvents.changed.removeListener(_search);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final all = await DatabaseHelper.instance.getAllBooks();
    final cats = all.map((b) => b.category).toSet().toList()..sort();
    if (!mounted) return;
    setState(() => _categories = ['Semua', ...cats]);
    await _search();
  }

  Future<void> _search() async {
    final token = ++_token;
    final result = await DatabaseHelper.instance.getAllBooks(
      query: _searchCtrl.text.trim(),
      category: _selected,
    );
    if (!mounted || token != _token) return;
    setState(() {
      _books = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Jelajahi',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                setState(() {});
                _search();
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari judul buku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                    _search();
                  },
                ),
                filled: true,
                fillColor: AppTheme.primarySoft,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selected == cat,
                  onSelected: (_) {
                    setState(() => _selected = cat);
                    _search();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Buku Tidak Ditemukan',
              subtitle: 'Coba kata kunci atau kategori lain.',
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              itemCount: _books.length,
              itemBuilder: (_, i) {
                final b = _books[i];
                return BookTile(
                  title: b.title,
                  author: b.author,
                  coverUrl: b.coverUrl,
                  subtitle: Text(
                    '${b.category} • ${b.stock > 0 ? 'Stok ${b.stock}' : 'Stok habis'}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.primary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: b)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
