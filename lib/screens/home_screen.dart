import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/database_helper.dart';
import '../utils/session_manager.dart';
import '../widgets/notification_bell.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? userId;
  final String? userName;

  const HomeScreen({Key? key, this.userId, this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';
  late Future<List<BookModel>> _booksFuture;
  String? _currentUserName;

  final List<String> categories = [
    'Semua',
    'Fiksi',
    'Fiksi Fantasi',
    'Sejarah',
    'Pengembangan Diri',
    'Filsafat',
    'Teknologi',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshBooks();
  }

  Future<void> _loadUserData() async {
    if (widget.userName != null) {
      setState(() => _currentUserName = widget.userName);
    } else {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final user = await DatabaseHelper.instance.getUser(userId);
        if (mounted && user != null) {
          setState(() => _currentUserName = user.name);
        }
      }
    }
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = DatabaseHelper.instance.getAllBooks(
        query: searchQuery,
        category: selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUserName ?? widget.userName ?? 'Pengunjung';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshBooks(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(displayName),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildHeroBanner(),
                const SizedBox(height: 28),
                _buildCategoryFilter(),
                const SizedBox(height: 28),
                _buildBookSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. HEADER DENGAN AVATAR & NOTIFIKASI BADGE
  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Halo, $name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('👋', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const Text(
                      'Mau baca buku apa hari ini?',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const NotificationBell(),
      ],
    );
  }

  // 2. SEARCH BAR MODERN
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          searchQuery = value;
          _refreshBooks();
        },
        decoration: InputDecoration(
          hintText: 'Cari judul, penulis, atau topik...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 24),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // 3. HERO BANNER GRADIENT DENGAN ELEMEN DEKORATIF
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '⚡ Koleksi Terbaru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Jelajahi Dunia Lewat Buku',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. CHIP FILTER KATEGORI SQUIRCLE
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat;
                  _refreshBooks();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 5. DAFTAR BUKU (HORIZONTAL CAROUSEL + VERTICAL LIST)
  Widget _buildBookSection() {
    return FutureBuilder<List<BookModel>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            ),
          );
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off_rounded, size: 52, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text(
                  'Buku tidak ditemukan',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU BESAR HORIZONTAL (Hanya jika tidak sedang search)
            if (searchQuery.isEmpty && books.length >= 2) ...[
              const Text(
                '🔥 Populer Minggu Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: books.take(4).length,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(books[index]);
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],

            // LIST VERTIKAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📚 Semua Koleksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${books.length} Buku',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: books.length,
              itemBuilder: (context, index) {
                return _buildModernBookCard(books[index]);
              },
            ),
          ],
        );
      },
    );
  }

  // FEATURED CARD (KARTU BESAR HORIZONTAL)
  Widget _buildFeaturedCard(BookModel book) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
          );
          _refreshBooks();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  book.coverUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.book, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // CARD VERTIKAL DENGAN BADGE DAN SHADOW SOFT
  Widget _buildModernBookCard(BookModel book) {
    final bool isAvailable = book.stock > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            );
            _refreshBooks();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Cover Buku
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      book.coverUrl,
                      width: 72,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 100,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.book, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Detail Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // Indigo soft
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.category,
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: isAvailable
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isAvailable ? 'Stok: ${book.stock}' : 'Stok Habis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}