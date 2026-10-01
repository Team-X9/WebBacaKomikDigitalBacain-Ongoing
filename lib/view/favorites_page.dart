// lib/view/favorites_page.dart
//
// VIEW: daftar komik favorit. Otomatis update lewat ListenableBuilder.

import 'package:flutter/material.dart';
import '../controller/library_controller.dart';
import '../theme.dart';
import '../widget/comic_card.dart';
import 'comic_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = LibraryController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Komik Favorit',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListenableBuilder(
        listenable: library,
        builder: (context, _) {
          final items = library.favorites;

          if (items.isEmpty) {
            return const _EmptyState(
              icon: Icons.favorite_border_rounded,
              message: 'Belum ada komik favorit.\n'
                  'Tekan ikon hati di halaman detail untuk menambahkan.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.62,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final comic = items[i];
              return ComicCard(
                comic: comic,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    // sesuaikan jika constructor ComicDetailPage Anda berbeda
                    builder: (_) => ComicDetailPage(comic: comic),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}