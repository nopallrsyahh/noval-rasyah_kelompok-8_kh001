import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  // Definisi nama konstanta rute
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Pengatur navigasi berbasis nama rute
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      default:
      // Halaman fallback jika rute tidak ditemukan
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Tidak ada rute yang terdefinisi untuk ${settings.name}'),
            ),
          ),
        );
    }
  }
}