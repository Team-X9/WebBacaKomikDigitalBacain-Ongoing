// lib/view/history_page.dart
//
// VIEW: riwayat baca. Ketuk baris untuk melanjutkan dari chapter terakhir,
// geser ke samping untuk menghapus satu entri.

import 'package:flutter/material.dart';
import '../controller/library_controller.dart';
import '../model/history_entry_model.dart';
import '../theme.dart';
import 'reader_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = LibraryController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Baca',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          ListenableBuilder(
            listenable: library,
            builder: (context, _) => IconButton(
              tooltip: 'Hapus semua',
              onPressed: library.historyCount == 0
                  ? null
                  : () => _confirmClear(context, library),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: library,
        builder: (context, _) {
          final items = library.history;

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded,
                        size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 12),
                    Text('Belum ada riwayat baca.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final entry = items[i];
              return Dismissible(
                key: ValueKey('history_${entry.comic.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => library.removeHistory(entry.comic.id),
                child: _HistoryTile(entry: entry),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, LibraryController library) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus semua riwayat?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok == true) library.clearHistory();
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final comic = entry.comic;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChapterReaderPage(comic: comic, startChapter: entry.chapter),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(comic.coverUrl,
                  width: 52, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Terakhir dibaca: Chapter ${entry.chapter}',
                      style: const TextStyle(
                          color: AppColors.primaryLight, fontSize: 12.5)),
                  const SizedBox(height: 2),
                  Text(_relative(entry.readAt),
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11.5)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  static String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Baru saja';
    if (d.inMinutes < 60) return '${d.inMinutes} menit lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    if (d.inDays < 30) return '${d.inDays} hari lalu';
    return '${(d.inDays / 30).floor()} bulan lalu';
  }
}