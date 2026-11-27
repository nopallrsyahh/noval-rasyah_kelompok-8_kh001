
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppButton extends StatefulWidget {
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

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  Future<void> _handlePressed(BuildContext context) async {
    // Jika ada aksi internal, jalankan aksi tersebut.
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    // Jika ada URL, buka aplikasi eksternal.
    if (widget.url != null) {
      final Uri uri = Uri.parse(widget.url!);

      final bool success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handlePressed(context),
        icon: Icon(widget.icon),
        label: Text(widget.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
