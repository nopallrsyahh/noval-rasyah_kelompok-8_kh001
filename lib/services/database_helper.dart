import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/book_model.dart';
import '../models/borrowing_model.dart';
import '../models/favorite_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('libraryku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType UNIQUE,
        password $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id $idType,
        title $textType,
        author $textType,
        description $textType,
        coverUrl $textType,
        stock $intType,
        category $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE borrowings (
        id $idType,
        userId $intType,
        bookId $intType,
        borrowDate $textType,
        returnDate $textType,
        status $textType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id $idType,
        userId $intType,
        bookId $intType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await _insertDummyBooks(db);
  }

  Future _insertDummyBooks(Database db) async {
    List<Map<String, dynamic>> dummyBooks = [
      {
        'title': 'Bumi Manusia', 'author': 'Pramoedya Ananta Toer',
        'description': 'Kisah cinta Minke dan Annelies di masa kolonial Belanda yang penuh ketidakadilan.',
        'coverUrl': 'https://upload.wikimedia.org/wikipedia/id/2/22/Bumi_Manusia.jpg',
        'stock': 5, 'category': 'Fiksi'
      },
      {
        'title': 'Laskar Pelangi', 'author': 'Andrea Hirata',
        'description': 'Perjuangan 10 anak Belitung meraih pendidikan di SD Muhammadiyah yang hampir ditutup.',
        'coverUrl': 'https://upload.wikimedia.org/wikipedia/id/8/8e/Laskar_pelangi_sampul.jpg',
        'stock': 3, 'category': 'Fiksi'
      },
      {
        'title': 'Sapiens', 'author': 'Yuval Noah Harari',
        'description': 'Sejarah ringkas umat manusia dari zaman batu hingga abad ke-21.',
        'coverUrl': 'https://upload.wikimedia.org/wikipedia/en/0/06/%E1%B8%A2apiens_A_Brief_History_of_Humankind.jpg',
        'stock': 7, 'category': 'Sejarah'
      },
      {
        'title': 'Atomic Habits', 'author': 'James Clear',
        'description': 'Cara mudah dan terbukti untuk membentuk kebiasaan baik dan menghilangkan kebiasaan buruk.',
        'coverUrl': 'https://upload.wikimedia.org/wikipedia/en/a/a4/Atomic_Habits.jpg',
        'stock': 4, 'category': 'Pengembangan Diri'
      },
      {
        'title': 'Filosofi Teras', 'author': 'Henry Manampiring',
        'description': 'Pengantar filsafat Stoa untuk kehidupan yang lebih tenang di tengah dunia yang kacau.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1543460613i/43033503.jpg',
        'stock': 8, 'category': 'Filsafat'
      },
      {
        'title': 'Hujan', 'author': 'Tere Liye',
        'description': 'Kisah tentang persahabatan, cinta, dan melupakan di era futuristik yang terdampak bencana alam.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1453272481i/28572561.jpg',
        'stock': 6, 'category': 'Fiksi'
      },
      {
        'title': 'Clean Code', 'author': 'Robert C. Martin',
        'description': 'Panduan kerajinan perangkat lunak yang *agile* untuk menulis kode yang lebih baik.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1436202607i/3735293.jpg',
        'stock': 2, 'category': 'Teknologi'
      },
      {
        'title': 'The Pragmatic Programmer', 'author': 'Andrew Hunt',
        'description': 'Perjalanan seorang programmer dari pemula hingga menjadi ahli.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1401432508i/4099.jpg',
        'stock': 3, 'category': 'Teknologi'
      },
      {
        'title': 'Cantik Itu Luka', 'author': 'Eka Kurniawan',
        'description': 'Sebuah epos surealis tentang tragedi keluarga, sejarah Indonesia, dan kutukan kecantikan.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1388656157i/211756.jpg',
        'stock': 4, 'category': 'Fiksi'
      },
      {
        'title': 'Bumi', 'author': 'Tere Liye',
        'description': 'Petualangan Raib, Seli, dan Ali di dunia paralel yang penuh dengan klan dan kekuatan magis.',
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1435252876i/20266012.jpg',
        'stock': 5, 'category': 'Fiksi Fantasi'
      },
      {
        'title': 'To Kill a Mockingbird', 'author': 'Harper Lee',
        'description': 'Kisah klasik tentang ketidakadilan rasial di Amerika bagian Selatan, dilihat dari sudut pandang kepolosan seorang anak perempuan',
        'coverUrl': 'https://m.media-amazon.com/images/I/81gepf1eMqL._AC_UF894,1000_QL80_.jpg',
        'stock': 8, 'category': 'Fiksi'
      }
    ];

    for (var book in dummyBooks) {
      await db.insert('books', book);
    }
  }

  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<UserModel?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<List<BookModel>> getAllBooks({String? query, String? category}) async {
    final db = await instance.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND title LIKE ?';
      whereArgs.add('%$query%');
    }
    if (category != null && category != 'Semua') {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final result = await db.query('books', where: whereClause, whereArgs: whereArgs);
    return result.map((json) => BookModel.fromMap(json)).toList();
  }

  Future<String> borrowBook(BorrowingModel borrowing) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      final bookResult = await txn.query('books', where: 'id = ?', whereArgs: [borrowing.bookId]);
      if (bookResult.isEmpty) return 'Buku tidak ditemukan.';

      int currentStock = bookResult.first['stock'] as int;
      if (currentStock <= 0) return 'Stok buku habis.';

      final activeBorrowing = await txn.query(
        'borrowings',
        where: 'userId = ? AND bookId = ? AND status = ?',
        whereArgs: [borrowing.userId, borrowing.bookId, 'Dipinjam'],
      );
      if (activeBorrowing.isNotEmpty) return 'Anda masih meminjam buku ini.';

      await txn.insert('borrowings', borrowing.toMap());

      await txn.update(
        'books',
        {'stock': currentStock - 1},
        where: 'id = ?',
        whereArgs: [borrowing.bookId],
      );

      return 'Berhasil dipinjam.';
    });
  }

  Future<void> returnBook(int borrowingId, int bookId) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.update(
        'borrowings',
        {'status': 'Dikembalikan'},
        where: 'id = ?',
        whereArgs: [borrowingId],
      );

      await txn.rawUpdate(
          'UPDATE books SET stock = stock + 1 WHERE id = ?',
          [bookId]
      );
    });
  }

  Future<List<Map<String, dynamic>>> getUserBorrowings(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT borrowings.*, books.title, books.author, books.coverUrl 
      FROM borrowings 
      JOIN books ON borrowings.bookId = books.id 
      WHERE borrowings.userId = ? 
      ORDER BY borrowings.id DESC
    ''', [userId]);
  }

  Future<void> toggleFavorite(FavoriteModel favorite) async {
    final db = await instance.database;
    final exists = await db.query(
      'favorites',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [favorite.userId, favorite.bookId],
    );

    if (exists.isNotEmpty) {
      await db.delete('favorites', where: 'id = ?', whereArgs: [exists.first['id']]);
    } else {
      await db.insert('favorites', favorite.toMap());
    }
  }

  Future<bool> isFavorite(int userId, int bookId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [userId, bookId],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT books.* 
      FROM favorites 
      JOIN books ON favorites.bookId = books.id 
      WHERE favorites.userId = ?
    ''', [userId]);
  }
}