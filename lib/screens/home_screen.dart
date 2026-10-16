import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/database_helper.dart';
import '../utils/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    'Semua',
    'Fiksi',
    'Fiksi Fantasi',
    'Sejarah',
    'Pengembangan Diri',
    'Filsafat',
    'Teknologi',
  ];

  List<BookModel> _books = [];
  String _query = '';
  String _category = 'Semua';
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadBooks();
  }

  Future<void> _loadUser() async {
    final name = await SessionManager.getUserName();
    if (!mounted) return;
    setState(() => _userName = name ?? '');
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await DatabaseHelper.instance
        .getAllBooks(query: _query, category: _category);
    if (!mounted) return;
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  void _showBookInfo(BookModel book) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(book.author, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(book.description),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 60,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 85,
          color: Colors.indigo.shade50,
          child: const Icon(Icons.menu_book, color: Colors.indigo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_userName'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari judul buku...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                _query = value.trim();
                _loadBooks();
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return ChoiceChip(
                  label: Text(cat),
                  selected: _category == cat,
                  onSelected: (_) {
                    _category = cat;
                    _loadBooks();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                ? const Center(child: Text('Buku tidak ditemukan.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              itemBuilder: (context, i) {
                final book = _books[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showBookInfo(book),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildCover(book.coverUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book.title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(book.author,
                                    style: const TextStyle(
                                        color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text(
                                    '${book.category}  •  Stok: ${book.stock}',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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