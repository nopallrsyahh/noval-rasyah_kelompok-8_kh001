import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? url;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    required this.icon,
    this.url,
    this.onPressed,
  });

  Future<void> _handlePressed(BuildContext context) async {
    // Jika ada aksi internal, jalankan aksi tersebut.
    if (onPressed != null) {
      onPressed!();
      return;
    }

    // Jika ada URL, buka aplikasi eksternal.
    if (url != null) {
      final Uri uri = Uri.parse(url!);

      final bool success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal membuka URL.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handlePressed(context),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Warna latar tombol
          foregroundColor: AppColors.textPrimary, // Warna teks tombol
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
