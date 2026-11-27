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
      // --- BUKU LAMA (Existing) ---
      {
        'title': 'Bumi Manusia', 'author': 'Pramoedya Ananta Toer',
        'description': 'Kisah cinta Minke dan Annelies di masa kolonial Belanda yang penuh ketidakadilan.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRb2l3HM86bJegzn5U7ZlCVHQ-Kj3YhYKFNUOiRdYHBMg&s=10',
        'stock': 5, 'category': 'Fiksi'
      },
      {
        'title': 'Laskar Pelangi', 'author': 'Andrea Hirata',
        'description': 'Perjuangan 10 anak Belitung meraih pendidikan di SD Muhammadiyah yang hampir ditutup.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTM8joseg3BAMnVwEg0X5gV6E2zCQ-8RK6WQ6m2-_NAtw&s=10',
        'stock': 3, 'category': 'Fiksi'
      },
      {
        'title': 'Sapiens', 'author': 'Yuval Noah Harari',
        'description': 'Sejarah ringkas umat manusia dari zaman batu hingga abad ke-21.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjQFupRjmvdmWHX4CxKGwNkJVvkARZWnBgzBncSqzc5w&s=10',
        'stock': 7, 'category': 'Sejarah'
      },
      {
        'title': 'Atomic Habits', 'author': 'James Clear',
        'description': 'Cara mudah dan terbukti untuk membentuk kebiasaan baik dan menghilangkan kebiasaan buruk.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZOLof-8iYsYC1wlpBR1xL4lQ3UN0DctXxgoS5ipluvw&s=10',
        'stock': 4, 'category': 'Pengembangan Diri'
      },
      {
        'title': 'Filosofi Teras', 'author': 'Henry Manampiring',
        'description': 'Pengantar filsafat Stoa untuk kehidupan yang lebih tenang di tengah dunia yang kacau.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtj0TPOPmXTK4lN1RZAJj_qt9iZ6ozD-kwklpejz3j-Q&s=10',
        'stock': 8, 'category': 'Filsafat'
      },
      {
        'title': 'Hujan', 'author': 'Tere Liye',
        'description': 'Kisah tentang persahabatan, cinta, dan melupakan di era futuristik yang terdampak bencana alam.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpMZiT12J1AwLn6wgRbYpA7KZFZp8eri3M4MiyzKqCXQ&s=10',
        'stock': 6, 'category': 'Fiksi'
      },
      {
        'title': 'Clean Code', 'author': 'Robert C. Martin',
        'description': 'Panduan kerajinan perangkat lunak yang *agile* untuk menulis kode yang lebih baik.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHMaNmP7RZD_T9kk4MMV8i6VzxA01DSuIe5iBhf6pPgw&s=10',
        'stock': 2, 'category': 'Teknologi'
      },
      {
        'title': 'The Pragmatic Programmer', 'author': 'Andrew Hunt',
        'description': 'Perjalanan seorang programmer dari pemula hingga menjadi ahli.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKUyxNOkx2gPiJQtYzCyrYka7zj1Uryf6WrEoal0wLCw&s=10',
        'stock': 3, 'category': 'Teknologi'
      },
      {
        'title': 'Cantik Itu Luka', 'author': 'Eka Kurniawan',
        'description': 'Sebuah epos surealis tentang tragedi keluarga, sejarah Indonesia, dan kutukan kecantikan.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTO_Cclp3ECAG-xndX6R0zcDrsaql-ndWFfHXZB1Ux1iQ&s=10',
        'stock': 4, 'category': 'Fiksi'
      },
      {
        'title': 'Bumi', 'author': 'Tere Liye',
        'description': 'Petualangan Raib, Seli, dan Ali di dunia paralel yang penuh dengan klan dan kekuatan magis.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTONvAl19RuHIENbfSdtspU_zwC2i0CbmpJDpcOGhndjg&s=10',
        'stock': 5, 'category': 'Fiksi Fantasi'
      },
      {
        'title': 'To Kill a Mockingbird', 'author': 'Harper Lee',
        'description': 'Kisah klasik tentang ketidakadilan rasial di Amerika bagian Selatan.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ50oM6zoDAMBayjZzZ8vQe4agMlXnYywnI51taB74ilA&s=10',
        'stock': 8, 'category': 'Fiksi'
      },
      // --- TAMBAHAN BUKU BARU (~40 BUKU) ---
      // FIKSI INDONESIA
      {
        'title': 'Laut Bercerita', 'author': 'Leila S. Chudori', 'category': 'Fiksi', 'stock': 5,
        'description': 'Kisah persahabatan, cinta, dan pengkhianatan di masa Orde Baru.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ5o64Jwl0ompVW-frNynTuCYSeceokR91j0d4AWyq6A&s=10'
      },
      {
        'title': 'Perahu Kertas', 'author': 'Dee Lestari', 'category': 'Fiksi', 'stock': 4,
        'description': 'Kisah pasang surut hubungan dua anak manusia, Kugy dan Keenan.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQXKx50C08u_s9JYCckaK8hIpFBFHkc-tJNxTSVHZygw&s=10'
      },
      {
        'title': 'Pulang', 'author': 'Tere Liye', 'category': 'Fiksi', 'stock': 6,
        'description': 'Perjalanan Bujang dari pedalaman Sumatera menjadi jagal di shadow economy.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQE6LiRdAhFqzAjRa5LYzf_jkO36mCDoGrIFfFcCOcy6w&s=10'
      },
      {
        'title': 'Negeri 5 Menara', 'author': 'A. Fuadi', 'category': 'Fiksi', 'stock': 7,
        'description': 'Mantra Man Jadda Wajada yang mengubah hidup enam santri.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiTN0JgIjUaDSHJD7rIyOHxIbpY6wdRDlfiwglAW9hsQ&s=10'
      },
      {
        'title': '5 cm', 'author': 'Donny Dhirgantoro', 'category': 'Fiksi', 'stock': 3,
        'description': 'Perjalanan 5 sahabat menaklukkan puncak Mahameru.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJpsp5JZnDkXKaJPip0qW2jXhRc_hgdW48QmCMfU4yQw&s=10'
      },
      // FIKSI INTERNASIONAL
      {
        'title': '1984', 'author': 'George Orwell', 'category': 'Fiksi', 'stock': 8,
        'description': 'Novel distopia tentang pengawasan pemerintah yang ekstrem (Big Brother).',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKUrinprb9eimNxkZEZ2PgcQKo01mEtAFeLSef5acSpw&s=10'
      },
      {
        'title': 'Animal Farm', 'author': 'George Orwell', 'category': 'Fiksi', 'stock': 5,
        'description': 'Alegori politik menggunakan hewan ternak yang memberontak.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYLnKSnhpgzj1-Ovxz73pwrsH1Sidkgwjq50Uzii_lDA&s=10'
      },
      {
        'title': 'The Alchemist', 'author': 'Paulo Coelho', 'category': 'Fiksi', 'stock': 9,
        'description': 'Perjalanan Santiago mencari harta karun di piramida Mesir.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRVFgKIwTT0fNALowNXL92WmE8V1mD3RSLMmKSdHy60xg&s=10'
      },
      // FIKSI FANTASI
      {
        'title': 'Harry Potter and the Sorcerer\'s Stone', 'author': 'J.K. Rowling', 'category': 'Fiksi Fantasi', 'stock': 12,
        'description': 'Awal petualangan Harry di sekolah sihir Hogwarts.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1p2LgU2-KWrgFj1zEIFmy7dQQcDdTjQ3QyKdm1ubpbw&s=10'
      },
      {
        'title': 'The Lord of the Rings', 'author': 'J.R.R. Tolkien', 'category': 'Fiksi Fantasi', 'stock': 6,
        'description': 'Perjalanan epik Frodo Baggins menghancurkan One Ring.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiwf5hFVmiFJ0nhFaqD0Duv5mdIr2PJenbwakAhmYTBA&s=10'
      },
      {
        'title': 'The Hobbit', 'author': 'J.R.R. Tolkien', 'category': 'Fiksi Fantasi', 'stock': 7,
        'description': 'Petualangan Bilbo Baggins merebut kembali Erebor dari naga Smaug.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZL9y3Ejn2BnVDm27YQzzLqdli3gMOemKx_OOk7mxUQw&s=10'
      },
      {
        'title': 'Percy Jackson: The Lightning Thief', 'author': 'Rick Riordan', 'category': 'Fiksi Fantasi', 'stock': 4,
        'description': 'Seorang anak yang menyadari dirinya adalah putra dewa Poseidon.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmmk3Mgoc4rwur7AZoTUNhJMX6ifik-hPL4NrebA194A&s=10'
      },
      // PENGEMBANGAN DIRI
      {
        'title': 'The 7 Habits of Highly Effective People', 'author': 'Stephen R. Covey', 'category': 'Pengembangan Diri', 'stock': 10,
        'description': 'Tujuh kebiasaan yang dimiliki oleh orang-orang sukses.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmo3ZLoM0ljPy8pYSRXJaKjWnEkuaq6h6Af6fYcmHVdg&s=10'
      },
      {
        'title': 'How to Win Friends and Influence People', 'author': 'Dale Carnegie', 'category': 'Pengembangan Diri', 'stock': 8,
        'description': 'Buku legendaris tentang komunikasi dan seni bergaul.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDuAyLfD5E8WqHlZ2nrfNXqJlwWIOc-NXIbGQPSc-IEg&s=10'
      },
      {
        'title': 'Thinking, Fast and Slow', 'author': 'Daniel Kahneman', 'category': 'Pengembangan Diri', 'stock': 5,
        'description': 'Membahas dua sistem berpikir manusia: cepat/emosional dan lambat/logis.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUssQEPJQuVc7FVRYAR6uIE-iUkPrVZT-B6Fcrxs4vIQ&s=10'
      },
      {
        'title': 'The Subtle Art of Not Giving a F*ck', 'author': 'Mark Manson', 'category': 'Pengembangan Diri', 'stock': 7,
        'description': 'Pendekatan waras untuk menjalani kehidupan yang lebih baik.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0AosSh3n4a9XLxkROt3fhgrL5jRm8zqRC0nAPxDribQ&s=10'
      },
      {
        'title': 'Rich Dad Poor Dad', 'author': 'Robert T. Kiyosaki', 'category': 'Pengembangan Diri', 'stock': 15,
        'description': 'Pelajaran tentang literasi keuangan dan investasi.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdl8WJxEskusqrm0JvltoOnit-pfnfEglUZJqFQsGEHQ&s=10'
      },
      {
        'title': 'Start with Why', 'author': 'Simon Sinek', 'category': 'Pengembangan Diri', 'stock': 6,
        'description': 'Cara pemimpin besar menginspirasi orang untuk bertindak.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjkrSqtcPVPetLshsU6mDxKO4N-ohb-iVdYkoMs-y33g&s=10'
      },
      {
        'title': 'Deep Work', 'author': 'Cal Newport', 'category': 'Pengembangan Diri', 'stock': 4,
        'description': 'Aturan meraih kesuksesan terfokus di dunia yang penuh distraksi.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnA-eqxyYiGx81qAC2iovl2L2aerhykAnUapqrAfr2DQ&s'
      },
      {
        'title': 'Mindset', 'author': 'Carol S. Dweck', 'category': 'Pengembangan Diri', 'stock': 5,
        'description': 'Kekuatan psikologi dari growth mindset.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ0mgmEEB89EYxokPrdNJtou_ZeyCnjb_6vns-W3sLvQ&s=10'
      },
      // FILSAFAT
      {
        'title': 'Man\'s Search for Meaning', 'author': 'Viktor E. Frankl', 'category': 'Filsafat', 'stock': 9,
        'description': 'Pencarian makna hidup di kamp konsentrasi Nazi.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrtdPn4CB_7p4mBb00sn93GIi_5RI5T7HW59sFO9C-JQ&s=10'
      },
      {
        'title': 'Meditations', 'author': 'Marcus Aurelius', 'category': 'Filsafat', 'stock': 6,
        'description': 'Catatan harian kaisar Romawi tentang filsafat Stoa.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQc4l82MM3RNwQpPeQ2mh-q0FsPkt9FlAN534T8sWWaTg&s=10'
      },
      {
        'title': 'The Republic', 'author': 'Plato', 'category': 'Filsafat', 'stock': 3,
        'description': 'Diskusi tentang keadilan dan negara ideal.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4v3cDL-ITGh6kexrroAzUOsrSrpSxEnluNhsZLTF0aw&s=10'
      },
      {
        'title': 'Beyond Good and Evil', 'author': 'Friedrich Nietzsche', 'category': 'Filsafat', 'stock': 4,
        'description': 'Kritik terhadap moralitas masa lalu dan modernitas.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiTSdJw35Fof6XWgCm8bYpxroVJbjYvB44hLUr0kXSOQ&s=10'
      },
      {
        'title': 'The Stranger', 'author': 'Albert Camus', 'category': 'Filsafat', 'stock': 7,
        'description': 'Eksplorasi absurdisme lewat tokoh Meursault.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKUrinprb9eimNxkZEZ2PgcQKo01mEtAFeLSef5acSpw&s=10'
      },
      // TEKNOLOGI
      {
        'title': 'Design Patterns', 'author': 'Erich Gamma dkk', 'category': 'Teknologi', 'stock': 2,
        'description': 'Buku fundamental tentang solusi desain software berorientasi objek.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRp6AVB5A7F7UHzGMOwsFXXIhS-pN0j5Z101L-z9Ihhqw&s'
      },
      {
        'title': 'Refactoring', 'author': 'Martin Fowler', 'category': 'Teknologi', 'stock': 3,
        'description': 'Cara memperbaiki desain kode yang sudah ada.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpM75O5RY3JtHEo2xl_QaskefO2Ug4tUaW11r_mvdKYQ&s=10'
      },
      {
        'title': 'Introduction to Algorithms', 'author': 'Thomas H. Cormen', 'category': 'Teknologi', 'stock': 1,
        'description': 'Buku teks standar untuk algoritma komputer.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ22NbmXOv2F9hOZ1xsHjr2-W5hPafplMipqyDx5vRpfA&s=10'
      },
      {
        'title': 'Cracking the Coding Interview', 'author': 'Gayle Laakmann McDowell', 'category': 'Teknologi', 'stock': 5,
        'description': '189 soal programming untuk persiapan wawancara kerja.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSQK5L_dhp02NrdgFMibfYWWPHjjY7r2OLbQs1gTXkSg&s=10'
      },
      {
        'title': 'Eloquent JavaScript', 'author': 'Marijn Haverbeke', 'category': 'Teknologi', 'stock': 6,
        'description': 'Pengenalan modern ke bahasa pemrograman JavaScript.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJ6Udi7HKmQs9CGp1bvuSKgDhQc122Sqmti93E2_A80g&s=10'
      },
      {
        'title': 'You Don\'t Know JS', 'author': 'Kyle Simpson', 'category': 'Teknologi', 'stock': 4,
        'description': 'Menyelami lebih dalam mekanisme inti JavaScript.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdbzYbuv_hBAByF25IqReMEGPTntlLUlAeZ60aquJDcg&s=10'
      },
      {
        'title': 'Head First Java', 'author': 'Kathy Sierra', 'category': 'Teknologi', 'stock': 3,
        'description': 'Panduan belajar Java yang ramah untuk pemula.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ17kAzmYIHJY1T9U8hiz8FcSrN66uSZO32Q8-Z1M1iEg&s=10'
      },
      // SEJARAH / SAINS
      {
        'title': 'The Diary of a Young Girl', 'author': 'Anne Frank', 'category': 'Sejarah', 'stock': 6,
        'description': 'Catatan harian gadis Yahudi yang bersembunyi di masa Holocaust.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-a_sf_rJJoeGXGuyhxwc9FLy-W3PIXjc1_XLC2jnzEQ&s=10'
      },
      {
        'title': 'Guns, Germs, and Steel', 'author': 'Jared Diamond', 'category': 'Sejarah', 'stock': 4,
        'description': 'Bagaimana letak geografis memengaruhi sejarah manusia.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHA4CUSUsjRgYB3neFYmTWCj27Tv-fOR3SC4Eso7J2Ng&s=10'
      },
      {
        'title': 'A Brief History of Time', 'author': 'Stephen Hawking', 'category': 'Sejarah', 'stock': 5,
        'description': 'Penjelasan kosmologi populer dari Big Bang hingga lubang hitam.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQk-dtVkSgQpBTdu4w_xHsA64qSp3uPcprYsOIfIR8EPw&s=10'
      },
      {
        'title': 'Cosmos', 'author': 'Carl Sagan', 'category': 'Sejarah', 'stock': 7,
        'description': 'Buku pendamping serial televisi tentang alam semesta.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSv6s4SC42__owu7Rm3v5zZVS05ygZHyTMRA2r2IApz_w&s=10'
      },
      {
        'title': 'The Selfish Gene', 'author': 'Richard Dawkins', 'category': 'Sejarah', 'stock': 3,
        'description': 'Evolusi dari sudut pandang genosentris.',
        'coverUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoIdVc-ImKVUbElQk2gCCHO9p6QmIYzTtXQAQAEzGwqQ&s=10'
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

  Future<BookModel?> getBook(int id) async {
    final db = await instance.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return BookModel.fromMap(maps.first);
    return null;
  }

  Future<int> updateUserName(int id, String name) async {
    final db = await instance.database;
    return await db.update('users', {'name': name},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> changePassword(
      int userId, String oldPassword, String newPassword) async {
    final db = await instance.database;
    final match = await db.query('users',
        where: 'id = ? AND password = ?', whereArgs: [userId, oldPassword]);
    if (match.isEmpty) return false;
    await db.update('users', {'password': newPassword},
        where: 'id = ?', whereArgs: [userId]);
    return true;
  }

  Future<int> clearReturnedHistory(int userId) async {
    final db = await instance.database;
    return await db.delete('borrowings',
        where: 'userId = ? AND status = ?',
        whereArgs: [userId, 'Dikembalikan']);
  }
}