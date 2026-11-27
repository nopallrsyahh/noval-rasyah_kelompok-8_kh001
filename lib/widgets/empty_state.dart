import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppTheme.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}