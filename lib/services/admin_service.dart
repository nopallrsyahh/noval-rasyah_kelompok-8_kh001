
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/admin_model.dart';

class AdminService {
  static const String fileName = 'admins.json';

  // Mendapatkan file admins.json dari internal storage aplikasi.
  static Future<File> getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  // Menginisialisasi file admins.json jika belum tersedia.
  static Future<File> _ensureFileInitialized() async {
    final file = await getLocalFile();

    if (!await file.exists()) {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_defaultAdmins),
      );
    }

    return file;
  }

  // Membaca seluruh data Admin dari file JSON.
  static Future<List<dynamic>> _readJsonFile() async {
    final file = await _ensureFileInitialized();
    final contents = await file.readAsString();

    final decodedData = jsonDecode(contents);

    if (decodedData is! List) {
      throw const FormatException(
        'Format data Admin tidak valid. Data harus berupa List JSON.',
      );
    }

    return decodedData;
  }

  // Menyimpan perubahan data Admin ke file JSON.
  static Future<void> _writeJsonFile(List<dynamic> admins) async {
    final file = await getLocalFile();

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(admins),
    );
  }

  // GET: Mengambil seluruh data Admin.
  static Future<List<Admin>> getAdmins() async {
    await Future.delayed(const Duration(milliseconds: 250));

    final admins = await _readJsonFile();

    return admins
        .map(
          (json) => Admin.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // GET: Mengambil detail Admin berdasarkan ID.
  static Future<Admin> getAdmin(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final admins = await getAdmins();

    final adminIndex = admins.indexWhere(
      (admin) => admin.id == id,
    );

    if (adminIndex == -1) {
      throw Exception(
        'Data Admin dengan ID $id tidak ditemukan.',
      );
    }

    return admins[adminIndex];
  }

  // DELETE: Menghapus Admin berdasarkan ID.
  static Future<bool> deleteAdmin(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final admins = await _readJsonFile();

    final adminIndex = admins.indexWhere(
      (admin) => int.tryParse(admin['id'].toString()) == id,
    );

    if (adminIndex == -1) {
      return false;
    }

    admins.removeAt(adminIndex);

    await _writeJsonFile(admins);

    return true;
  }

  // Mendapatkan lokasi file JSON untuk keperluan pengujian.
  static Future<String> getJsonFilePath() async {
    final file = await getLocalFile();
    return file.path;
  }

  // Mengembalikan data Admin ke kondisi awal.
  static Future<void> resetToDefault() async {
    final file = await getLocalFile();

    if (await file.exists()) {
      await file.delete();
    }

    await _ensureFileInitialized();
  }

  // Data awal Admin jika file belum tersedia.
  static final List<Map<String, dynamic>> _defaultAdmins = [
    {
      'id': 2001,
      'name': 'Admin One',
      'email': 'admin1@example.com',
      'department': 'IT',
    },
    {
      'id': 2002,
      'name': 'Admin Two',
      'email': 'admin2@example.com',
      'department': 'Finance',
    },
    {
      'id': 2003,
      'name': 'Admin Three',
      'email': 'admin3@example.com',
      'department': 'Human Resources',
    },
  ];
}
