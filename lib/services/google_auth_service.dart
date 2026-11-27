import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/session_manager.dart';
import 'database_helper.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login dengan akun Google dan sinkronkan ke SQLite lokal + SessionManager.
  /// Mengembalikan `true` jika berhasil, `false` jika pengguna membatalkan popup.
  static Future<bool> signInWithGoogle() async {
    // 1. Tampilkan pemilih akun Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false; // User membatalkan login

    // 2. Ambil token autentikasi Google & masuk ke Firebase Auth
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null || firebaseUser.email == null) {
      throw Exception('Gagal mendapatkan data akun Google.');
    }

    final String email = firebaseUser.email!.trim().toLowerCase();
    final String displayName = (firebaseUser.displayName?.trim().isNotEmpty ??
        false)
        ? firebaseUser.displayName!.trim()
        : email.split('@').first;

    // 3. Cek apakah email sudah ada di SQLite lokal
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    int userId;
    String userName;

    if (existing.isNotEmpty) {
      userId = existing.first['id'] as int;
      userName = existing.first['name'] as String;
    } else {
      // Daftarkan otomatis ke SQLite lokal dengan password penanda OAuth
      userId = await DatabaseHelper.instance.registerUser(
        UserModel(
          name: displayName,
          email: email,
          password: 'GOOGLE_OAUTH_${firebaseUser.uid}',
        ),
      );
      userName = displayName;
    }

    // 4. Simpan sesi ke SharedPreferences
    await SessionManager.saveSession(userId, userName);
    return true;
  }

  /// Opsional: panggil saat logout agar user bisa memilih akun Google lain
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}