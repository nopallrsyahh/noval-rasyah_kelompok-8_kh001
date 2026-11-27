import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BookTile extends StatelessWidget {
  final String title;
  final String author;
  final String coverUrl;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const BookTile({
    Key? key,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            BookCover(url: coverUrl, width: 60, height: 86),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMuted)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const BookCover({
    Key? key,
    required this.url,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppTheme.primarySoft,
      child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (ctx, child, progress) =>
        progress == null ? child : placeholder,
      ),
    );
  }
}
