// lib/widgets/comic_card.dart
//
// VIEW helper: kartu komik yang dipakai berulang kali di dalam
// GridView/ListView pada HomePage. Menerima objek Comic (Model) lalu
// membacanya lewat getter.

import 'package:flutter/material.dart';
import '../model/comic_model.dart';
import '../theme.dart';

class ComicCard extends StatelessWidget {
  final Comic comic;
  final VoidCallback? onTap;
  const ComicCard({super.key, required this.comic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(comic.coverUrl, fit: BoxFit.cover),

          // gradient supaya tulisan tetap terbaca
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.85),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

          // badge waktu update (kiri atas)
          Positioned(
            top: 6,
            left: 6,
            child: _pill(
              comic.timeAgo,
              color: AppColors.primary,
              icon: Icons.access_time_rounded,
            ),
          ),

          // badge bendera negara (kanan atas)
          Positioned(
            top: 6,
            right: 6,
            child: Text(comic.countryFlag, style: const TextStyle(fontSize: 16)),
          ),

          // badge UP (opsional)
          if (comic.isUpdate)
            const Positioned(
              top: 30,
              left: 6,
              child: _SmallTag(text: 'UP', color: Colors.redAccent),
            ),

          // judul + rating di bawah
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      comic.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Ch. ${comic.chapter}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _pill(String text, {required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 10, color: Colors.white),
          if (icon != null) const SizedBox(width: 2),
          Text(text,
              style: const TextStyle(
                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

/// Kartu komik bergaya "Update": poster besar di atas, judul di bawahnya,
/// lalu 2 baris chapter terbaru (chapter + waktu). Dipakai di dalam
/// GridView.builder pada HomePage, persis seperti web referensi.
class ComicUpdateGridCard extends StatelessWidget {
  final Comic comic;
  final VoidCallback? onTap;
  const ComicUpdateGridCard({super.key, required this.comic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(comic.coverUrl, fit: BoxFit.cover),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('BACAIN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Text(comic.countryFlag,
                      style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (comic.isUpdate)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: _SmallTag(text: 'UP', color: Colors.redAccent),
          ),
        Text(
          comic.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        _chapterRow('Chapter ${comic.chapter}', comic.timeAgo, emphasize: true),
        const SizedBox(height: 2),
        _chapterRow(
            'Chapter ${comic.prevChapter}', comic.prevTimeAgo, emphasize: false),
      ],
      ),
    );
  }

  Widget _chapterRow(String chapter, String time, {required bool emphasize}) {
    final color = emphasize ? Colors.white : AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(chapter,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(time, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}