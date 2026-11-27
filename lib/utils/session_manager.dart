import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan status login di perangkat.
class SessionManager {
  static const _keyUserId = 'userId';
  static const _keyUserName = 'userName';

  static Future<void> saveSession(int userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<bool> isLoggedIn() async {
    return (await getUserId()) != null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
  }
}