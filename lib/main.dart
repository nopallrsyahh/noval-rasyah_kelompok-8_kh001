
import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Aplikasi Noval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Noval Rasyah Kurnia Putra',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tekan tombol di bawah untuk melihat akun github saya.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Tombol untuk membuka Github
            AppButton(
              label: 'Buka Github Saya',
              icon: Icons.code,
              url: 'https://github.com',
            ),

            const SizedBox(height: 16),

            // Tombol untuk menguji aksi internal
            AppButton(
              label: 'Tes Tombol',
              icon: Icons.touch_app,
              onPressed: () {
                debugPrint('Tombol berhasil ditekan!');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tombol berhasil ditekan!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
