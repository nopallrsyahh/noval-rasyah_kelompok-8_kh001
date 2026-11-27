import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String fileName = 'users.json';

  // Identitas NIM untuk menentukan ID User POST.
  static const int nimLastThreeDigits = 60; // tiga digit terakhir NIM: 060
  static const int userIdFromNim = 1000 + nimLastThreeDigits;

  // Mendapatkan file users.json di internal storage perangkat.
  static Future<File> getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  // Mendapatkan path lengkap file JSON.
  static Future<String> getJsonFilePath() async {
    final file = await getLocalFile();
    return file.path;
  }

  // Inisialisasi users.json jika belum tersedia.
  static Future<File> _ensureFileInitialized() async {
    final file = await getLocalFile();

    if (!await file.exists()) {
      List<dynamic> initialData = [];

      try {
        final response = await http
            .get(Uri.parse('$baseUrl/users'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as List<dynamic>;

          // Menyesuaikan struktur JSONPlaceholder dengan model User.
          initialData = responseData.map((user) {
            return {
              'id': user['id'],
              'name': user['name'],
              'email': user['email'],
              'city': user['address']?['city'] ?? 'Unknown',
            };
          }).toList();
        }
      } catch (_) {
        // Menggunakan data default jika tidak ada koneksi internet.
        initialData = _defaultUsers;
      }

      if (initialData.isEmpty) {
        initialData = _defaultUsers;
      }

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(initialData),
      );
    }

    return file;
  }

  // Membaca seluruh data User dari file JSON lokal.
  static Future<List<dynamic>> _readJsonFile() async {
    final file = await _ensureFileInitialized();
    final contents = await file.readAsString();

    return jsonDecode(contents) as List<dynamic>;
  }

  // Menyimpan seluruh data User ke file JSON lokal.
  static Future<void> _writeJsonFile(List<dynamic> users) async {
    final file = await getLocalFile();

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(users));
  }

  // GET: Mengambil seluruh data User.
  static Future<List<dynamic>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return await _readJsonFile();
  }

  // GET: Mengambil detail User berdasarkan ID.
  static Future<Map<String, dynamic>> getUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final users = await _readJsonFile();

    final index = users.indexWhere(
      (user) => user['id'].toString() == id.toString(),
    );

    if (index == -1) {
      throw Exception('Data User dengan ID $id tidak ditemukan.');
    }

    return Map<String, dynamic>.from(users[index]);
  }

  // POST: Menambahkan User baru menggunakan ID berdasarkan NIM.
  static Future<Map<String, dynamic>> createUser({
    required String nim,
    required String name,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final users = await _readJsonFile();

    if (nim.length < 3 || !RegExp(r'^\d+$').hasMatch(nim)) {
      throw Exception('NIM harus berupa angka dan minimal 3 digit.');
    }

    final lastThreeDigits = int.parse(nim.substring(nim.length - 3));
    final newUserId = 1000 + lastThreeDigits;

    final isIdExists = users.any(
      (user) => user['id'].toString() == newUserId.toString(),
    );

    if (isIdExists) {
      throw Exception('User dengan ID $newUserId sudah tersedia.');
    }

    final newUser = {
      'id': newUserId,
      'name': name,
      'email': email,
      'city': 'Unknown',
    };

    users.add(newUser);
    await _writeJsonFile(users);

    return newUser;
  }

  // PUT: Memperbarui nama dan email User.
  static Future<Map<String, dynamic>> updateUser(
    int id,
    String name,
    String email,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final users = await _readJsonFile();

    final index = users.indexWhere(
      (user) => user['id'].toString() == id.toString(),
    );

    if (index == -1) {
      throw Exception('Gagal memperbarui User: ID $id tidak ditemukan.');
    }

    final existing = Map<String, dynamic>.from(users[index]);

    existing['name'] = name;
    existing['email'] = email;

    users[index] = existing;

    await _writeJsonFile(users);

    return existing;
  }

  // PATCH: Memperbarui sebagian data User, yaitu nama.
  static Future<Map<String, dynamic>> patchUser(int id, String name) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final users = await _readJsonFile();

    final index = users.indexWhere(
      (user) => user['id'].toString() == id.toString(),
    );

    if (index == -1) {
      throw Exception('Gagal mengubah nama User: ID $id tidak ditemukan.');
    }

    final existing = Map<String, dynamic>.from(users[index]);

    existing['name'] = name;

    users[index] = existing;

    await _writeJsonFile(users);

    return existing;
  }

  // DELETE: Menghapus User berdasarkan ID.
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final users = await _readJsonFile();

    final index = users.indexWhere(
      (user) => user['id'].toString() == id.toString(),
    );

    if (index == -1) {
      return false;
    }

    users.removeAt(index);

    await _writeJsonFile(users);

    return true;
  }

  // Reset users.json ke data awal.
  static Future<void> resetToDefault() async {
    final file = await getLocalFile();

    if (await file.exists()) {
      await file.delete();
    }

    await _ensureFileInitialized();
  }

  // Data default jika API tidak dapat diakses.
  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'city': 'Gwenborough',
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'city': 'Wisokyburgh',
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'city': 'McKenziehaven',
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'city': 'South Elvis',
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'city': 'Roscoeview',
    },
    {
      'id': 6,
      'name': 'Mrs. Dennis Schulist',
      'email': 'Karley_Dach@jasper.info',
      'city': 'South Christy',
    },
    {
      'id': 7,
      'name': 'Kurtis Weissnat',
      'email': 'Telly.Hoeger@billy.biz',
      'city': 'Howemouth',
    },
    {
      'id': 8,
      'name': 'Nicholas Runolfsdottir V',
      'email': 'Sherwood@rosamond.me',
      'city': 'Aliyaview',
    },
    {
      'id': 9,
      'name': 'Glenna Reichert',
      'email': 'Chaim_McDermott@dana.io',
      'city': 'Bartholomebury',
    },
    {
      'id': 10,
      'name': 'Clementina DuBuque',
      'email': 'Rey.Padberg@dana.io',
      'city': 'Lebsackbury',
    },
  ];
}
