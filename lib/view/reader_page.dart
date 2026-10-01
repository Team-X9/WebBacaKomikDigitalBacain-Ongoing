// lib/view/reader_page.dart
//
// VIEW: tampilan baca webtoon (scroll panjang). Dibuka dari
// ComicDetailPage saat tombol baca atau salah satu chapter ditekan.
// Daftar gambar halaman diambil dari ComicController.getChapterPages().
//
// Lebar gambar dibatasi ke kolom tengah (default 720px, seperti situs
// baca komik umumnya) dan bisa diperbesar/diperkecil lewat tombol zoom.
// Di HP (layar < 720px) kolom otomatis selebar layar.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../controller/comic_controller.dart';
import '../controller/library_controller.dart';
import '../model/comic_model.dart';
import '../theme.dart';

// Pengaturan lebar & zoom
const double _kBaseWidth = 720; // lebar kolom baca pada zoom 100%
const double _kMinZoom = 0.5;
const double _kMaxZoom = 1.5;
const double _kZoomStep = 0.1;

// =====================================================================
// TAMPILAN BACA (webtoon, scroll panjang) — dibuka saat tombol "Baca"
// atau salah satu item chapter di atas ditekan.
// =====================================================================
class ChapterReaderPage extends StatefulWidget {
  final Comic comic;
  final int startChapter;
  const ChapterReaderPage({
    super.key,
    required this.comic,
    required this.startChapter,
  });

  @override
  State<ChapterReaderPage> createState() => _ChapterReaderPageState();
}

class _ChapterReaderPageState extends State<ChapterReaderPage> {
  late int _chapter;
  bool _showControls = true;
  double _zoom = 1.0;
  final ScrollController _scrollCtrl = ScrollController();
  final ComicController _controller = ComicController();

  @override
  void initState() {
    super.initState();
    _chapter = widget.startChapter;
    // ditunda sampai frame selesai supaya tidak memicu rebuild saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LibraryController.instance.recordRead(widget.comic, _chapter);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _changeZoom(double delta) {
    setState(() {
      final next = (_zoom + delta).clamp(_kMinZoom, _kMaxZoom);
      _zoom = (next * 10).round() / 10; // hindari error floating point
    });
  }

  void _resetZoom() => setState(() => _zoom = 1.0);

  void _goToChapter(int chapter) {
    if (chapter < 1 || chapter > widget.comic.chapter) return;
    setState(() => _chapter = chapter);
    if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    LibraryController.instance.recordRead(widget.comic, chapter);
  }

  List<String> _pagesForChapter(int chapter) =>
      _controller.getChapterPages(widget.comic, chapter);

  @override
  Widget build(BuildContext context) {
    final comic = widget.comic;
    final pages = _pagesForChapter(_chapter);
    final maxContentWidth = _kBaseWidth * _zoom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ---------------- KONTEN BACA ----------------
          // ListView tetap selebar layar (scroll & tap berfungsi sampai
          // tepi), sedangkan tiap item dibatasi & ditaruh di tengah.
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.only(top: 0, bottom: 32),
              itemCount: pages.length + 1,
              itemBuilder: (context, i) {
                final Widget child;
                if (i == pages.length) {
                  child = _EndOfChapter(
                    comic: comic,
                    chapter: _chapter,
                    onNextChapter: _chapter < comic.chapter
                        ? () => _goToChapter(_chapter + 1)
                        : null,
                  );
                } else {
                  child = _ReaderPageImage(
                    path: pages[i],
                    pageNumber: i + 1,
                    totalPages: pages.length,
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: child,
                  ),
                );
              },
            ),
          ),

          // ---------------- APP BAR ATAS ----------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showControls ? 0 : -90,
            left: 0,
            right: 0,
            child: _TopBar(
              comic: comic,
              chapter: _chapter,
              zoom: _zoom,
              onZoomOut: _zoom > _kMinZoom ? () => _changeZoom(-_kZoomStep) : null,
              onZoomIn: _zoom < _kMaxZoom ? () => _changeZoom(_kZoomStep) : null,
              onZoomReset: _resetZoom,
            ),
          ),

          // ---------------- BAR BAWAH (navigasi chapter) ----------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showControls ? 0 : -80,
            left: 0,
            right: 0,
            child: _BottomBar(
              chapter: _chapter,
              maxChapter: comic.chapter,
              onPrev: _chapter > 1 ? () => _goToChapter(_chapter - 1) : null,
              onNext: _chapter < comic.chapter
                  ? () => _goToChapter(_chapter + 1)
                  : null,
              onPickChapter: () => _openChapterList(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openChapterList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Daftar Chapter',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Divider(height: 20, color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.comic.chapter,
                    itemBuilder: (context, i) {
                      final chapterNumber = widget.comic.chapter - i;
                      final active = chapterNumber == _chapter;
                      return ListTile(
                        title: Text('Chapter $chapterNumber',
                            style: TextStyle(
                                color: active
                                    ? AppColors.primaryLight
                                    : Colors.white,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                        trailing: active
                            ? const Icon(Icons.check_rounded,
                                color: AppColors.primaryLight, size: 18)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _goToChapter(chapterNumber);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- APP BAR ATAS ----------------
class _TopBar extends StatelessWidget {
  final Comic comic;
  final int chapter;
  final double zoom;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;
  final VoidCallback onZoomReset;

  const _TopBar({
    required this.comic,
    required this.chapter,
    required this.zoom,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onZoomReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(comic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('Chapter $chapter',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11.5)),
                  ],
                ),
              ),
              // ---- kontrol zoom ----
              _zoomButton(Icons.remove_rounded, onZoomOut, 'Perkecil'),
              Tooltip(
                message: 'Reset zoom',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onZoomReset,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(
                      '${(zoom * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              _zoomButton(Icons.add_rounded, onZoomIn, 'Perbesar'),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback? onTap, String tooltip) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon,
          color: onTap != null ? Colors.white : AppColors.textSecondary,
          size: 22),
    );
  }
}

// ---------------- BAR BAWAH ----------------
class _BottomBar extends StatelessWidget {
  final int chapter;
  final int maxChapter;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onPickChapter;

  const _BottomBar({
    required this.chapter,
    required this.maxChapter,
    required this.onPrev,
    required this.onNext,
    required this.onPickChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              _navButton(Icons.skip_previous_rounded, onPrev),
              Expanded(
                child: GestureDetector(
                  onTap: onPickChapter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Chapter $chapter / $maxChapter',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              _navButton(Icons.skip_next_rounded, onNext),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: enabled ? Colors.white : AppColors.textSecondary, size: 26),
    );
  }
}

// ---------------- SATU HALAMAN BACA (gambar asli) ----------------
// Lebar mengikuti kolom (dibatasi induknya), tinggi mengikuti rasio
// gambar, sehingga strip panjang (webtoon) tampil utuh tanpa terpotong.
class _ReaderPageImage extends StatelessWidget {
  final String path;
  final int pageNumber;
  final int totalPages;

  const _ReaderPageImage({
    required this.path,
    required this.pageNumber,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Decode pada lebar maksimum (zoom tertinggi) supaya gambar tidak
    // di-decode ulang setiap kali zoom berubah, tapi tetap hemat memori.
    final decodeWidth =
        (math.min(mq.size.width, _kBaseWidth * _kMaxZoom) * mq.devicePixelRatio)
            .round();

    return Image.asset(
      path,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      gaplessPlayback: true,
      cacheWidth: decodeWidth,
      errorBuilder: (context, error, stackTrace) => AspectRatio(
        aspectRatio: 0.72,
        child: Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Text(
            'Gambar halaman $pageNumber / $totalPages tidak ditemukan.\n'
            'Pastikan berkas $path ada dan terdaftar di pubspec.yaml.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
          ),
        ),
      ),
    );
  }
}

// ---------------- PENANDA AKHIR CHAPTER ----------------
class _EndOfChapter extends StatelessWidget {
  final Comic comic;
  final int chapter;
  final VoidCallback? onNextChapter;

  const _EndOfChapter({
    required this.comic,
    required this.chapter,
    required this.onNextChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.primaryLight, size: 32),
          const SizedBox(height: 10),
          Text('Selesai membaca Chapter $chapter',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(comic.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5)),
          const SizedBox(height: 20),
          if (onNextChapter != null)
            ElevatedButton(
              onPressed: onNextChapter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Lanjut Chapter ${chapter + 1}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          else
            const Text('Ini adalah chapter terbaru yang tersedia',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}