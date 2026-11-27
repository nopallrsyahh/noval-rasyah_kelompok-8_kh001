import 'package:flutter/material.dart';
import 'library_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: const FavoriteBooksList(),
    );
  }
}
