import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Menyimpan salinan akun user di Firestore (collection `users`)
/// supaya akun tidak hilang saat aplikasi di-uninstall.
class UserCloudService {
  UserCloudService._();
  static final UserCloudService instance = UserCloudService._();

  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('users');

  static String hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  String _key(String email) =>
      email.trim().toLowerCase().replaceAll('/', '_');

  /// Backup akun. Aman dipanggil berulang (tiap login berhasil).
  Future<void> simpan({
    required int id,
    required String name,
    required String email,
    required String password,
  }) async {
    final ref = _col.doc(_key(email));
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'localId': id,
        'name': name,
        'email': email.trim().toLowerCase(),
        'passwordHash': hash(password),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'name': name,
        'passwordHash': hash(password),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Cari akun berdasarkan email + password. Null jika tidak ada atau
  /// password salah.
  Future<Map<String, dynamic>?> cari(String email, String password) async {
    final doc = await _col.doc(_key(email)).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    if (data['passwordHash'] != hash(password)) return null;
    return data;
  }
}