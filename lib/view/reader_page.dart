// lib/views/reader_page.dart
//
// VIEW: halaman detail komik (mirip referensi web) yang menampilkan
// banner, poster, tombol aksi, statistik, sinopsis, tag genre/author/dll,
// serta daftar chapter dalam bentuk ListView polos (tanpa thumbnail).
//
// Saat sebuah chapter (atau tombol "Baca") ditekan, aplikasi berpindah ke
// _ChapterReadingView, yaitu tampilan baca webtoon (scroll panjang).
//
// CATATAN DATA: untuk contoh, gambar chapter diambil dari satu berkas
// aset lokal (assets/images/01.jpg) yang dipakai untuk semua chapter.
// Saat backend/API sudah ada, ganti `_pagesForChapter()` supaya mengambil
// daftar gambar chapter yang sesungguhnya.

import 'package:flutter/material.dart';
import '../model/comic_model.dart';
import '../theme.dart';

class ReaderPage extends StatefulWidget {
  final Comic comic;
  const ReaderPage({super.key, required this.comic});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _descExpanded = false;
  int _activeTab = 0; // 0 = Chapters, 1 = Info, 2 = Novel
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Daftar chapter (nomor + label waktu), dari yang terbaru ke terlama.
  /// Belum ada data waktu asli per-chapter, jadi label dihasilkan secara
  /// sederhana supaya tetap terlihat masuk akal (mis. "8 jam lalu",
  /// "1 hari lalu", dst).
  List<_ChapterItem> get _chapters {
    final total = widget.comic.chapter;
    return List.generate(total, (i) {
      final number = total - i;
      String time;
      if (i == 0) {
        time = widget.comic.timeAgo;
      } else if (i < 6) {
        time = '$i hari lalu';
      } else {
        time = '${i * 2} hari lalu';
      }
      return _ChapterItem(number: number, timeAgo: time);
    });
  }

  List<_ChapterItem> get _filteredChapters {
    final q = _query.trim();
    if (q.isEmpty) return _chapters;
    return _chapters.where((c) => c.number.toString().contains(q)).toList();
  }

  void _openChapter(int chapterNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChapterReadingView(
          comic: widget.comic,
          startChapter: chapterNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comic = widget.comic;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderBanner(context, comic)),
          SliverToBoxAdapter(child: _buildInfoSection(comic)),
          SliverToBoxAdapter(child: _buildTabsAndSearch()),
          if (_activeTab == 0)
            _buildChapterList()
          else
            SliverToBoxAdapter(child: _buildComingSoon()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ---------------- BANNER ----------------
  Widget _buildHeaderBanner(BuildContext context, Comic comic) {
    return SizedBox(
      height: 230,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(comic.coverUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    AppColors.background,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(
                    Icons.arrow_back_rounded,
                    () => Navigator.pop(context),
                  ),
                  _circleIconButton(
                    Icons.home_rounded,
                    () => Navigator.popUntil(context, (r) => r.isFirst),
                  ),
                ],
              ),
            ),
          ),
          // poster kecil, overlap ke bawah banner
          Positioned(
            left: 16,
            bottom: -46,
            child: Container(
              width: 96,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(comic.coverUrl, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ---------------- INFO KOMIK ----------------
  Widget _buildInfoSection(Comic comic) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comic.title,
            style: const TextStyle(
                color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${comic.type} ${comic.countryFlag}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openChapter(comic.chapter),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Baca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _outlinedIconButton(Icons.bookmark_border_rounded, 'Bookmark'),
              const SizedBox(width: 8),
              _outlinedIconButton(Icons.playlist_add_rounded, 'Tambah ke Readlist'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(Icons.star_rounded, comic.rating.toStringAsFixed(1), AppColors.gold),
              const SizedBox(width: 16),
              _statChip(Icons.bookmark_rounded, '${comic.chapter * 37}', AppColors.primaryLight),
              const SizedBox(width: 16),
              _statChip(Icons.remove_red_eye_rounded, '${comic.chapter * 84}',
                  AppColors.textSecondary),
              const SizedBox(width: 16),
              _statChip(Icons.emoji_events_rounded, '${comic.chapter * 11}',
                  AppColors.accentPink),
            ],
          ),
          const SizedBox(height: 16),
          _buildDescription(comic),
          const SizedBox(height: 16),
          _buildTagsRow('Genre', const ['Action', 'Adventure', 'Fantasy']),
          const SizedBox(height: 10),
          _buildTagsRow('Author', const ['Wuer Manhua']),
          const SizedBox(height: 10),
          _buildTagsRow('Artist', const ['Wuer Manhua']),
          const SizedBox(height: 10),
          _buildTagsRow('Format', [comic.type]),
          const SizedBox(height: 10),
          _buildTagsRow('Type', const ['Project']),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildDescription(Comic comic) {
    final text =
        comic.description.isNotEmpty ? comic.description : 'Belum ada sinopsis untuk komik ini.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _descExpanded ? null : 3,
          overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        GestureDetector(
          onTap: () => setState(() => _descExpanded = !_descExpanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _descExpanded ? 'Tutup' : 'Baca Selengkapnya',
              style: const TextStyle(
                  color: AppColors.primaryLight, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(String label, List<String> tags) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 66,
          child: Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map(_tagChip).toList(),
          ),
        ),
      ],
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
    );
  }

  Widget _statChip(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _outlinedIconButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ---------------- TAB + PENCARIAN CHAPTER ----------------
  Widget _buildTabsAndSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tabButton('Chapters', Icons.menu_book_rounded, 0),
              const SizedBox(width: 20),
              _tabButton('Info', Icons.info_outline_rounded, 1),
              const SizedBox(width: 20),
              _tabButton('Novel', Icons.description_outlined, 2),
            ],
          ),
          const SizedBox(height: 14),
          if (_activeTab == 0)
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari Chapter, Contoh: 1',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, IconData icon, int index) {
    final active = _activeTab == index;
    final color = active ? AppColors.primaryLight : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 2, width: 50, color: active ? AppColors.primaryLight : Colors.transparent),
        ],
      ),
    );
  }

  // ---------------- DAFTAR CHAPTER (ListView polos, tanpa gambar) ----------------
  Widget _buildChapterList() {
    final chapters = _filteredChapters;
    if (chapters.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('Chapter tidak ditemukan',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _chapterTile(chapters[i]),
          childCount: chapters.length,
        ),
      ),
    );
  }

  Widget _chapterTile(_ChapterItem chapter) {
    return InkWell(
      onTap: () => _openChapter(chapter.number),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Chapter ${chapter.number}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Text(chapter.timeAgo,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoon() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text('Belum tersedia', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}

class _ChapterItem {
  final int number;
  final String timeAgo;
  _ChapterItem({required this.number, required this.timeAgo});
}

// =====================================================================
// TAMPILAN BACA (webtoon, scroll panjang) — dibuka saat tombol "Baca"
// atau salah satu item chapter di atas ditekan.
// =====================================================================
class _ChapterReadingView extends StatefulWidget {
  final Comic comic;
  final int startChapter;
  const _ChapterReadingView({required this.comic, required this.startChapter});

  @override
  State<_ChapterReadingView> createState() => _ChapterReadingViewState();
}

class _ChapterReadingViewState extends State<_ChapterReadingView> {
  late int _chapter;
  bool _showControls = true;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _chapter = widget.startChapter;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _goToChapter(int chapter) {
    if (chapter < 1 || chapter > widget.comic.chapter) return;
    setState(() => _chapter = chapter);
    _scrollCtrl.jumpTo(0);
  }

  /// Daftar path gambar untuk chapter yang sedang dibaca.
  ///
  /// CONTOH: semua chapter memakai satu gambar yang sama dari
  /// assets/images/01.jpg. Jika nanti ada gambar per chapter, tinggal
  /// ganti isi list ini, misalnya:
  ///   ['assets/images/${widget.comic.id}_ch$chapter/01.jpg', ...]
  /// atau ambil dari API (ComicController.getChapterPages()).
  List<String> _pagesForChapter(int chapter) => const [
        'assets/images/01.jpg',
      ];

  @override
  Widget build(BuildContext context) {
    final comic = widget.comic;
    final pages = _pagesForChapter(_chapter);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ---------------- KONTEN BACA ----------------
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.only(top: 0, bottom: 32),
              itemCount: pages.length + 1,
              itemBuilder: (context, i) {
                if (i == pages.length) {
                  return _EndOfChapter(
                    comic: comic,
                    chapter: _chapter,
                    onNextChapter: _chapter < comic.chapter
                        ? () => _goToChapter(_chapter + 1)
                        : null,
                  );
                }
                return _ReaderPageImage(
                  path: pages[i],
                  pageNumber: i + 1,
                  totalPages: pages.length,
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
            child: _TopBar(comic: comic, chapter: _chapter),
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
                                color:
                                    active ? AppColors.primaryLight : Colors.white,
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
  const _TopBar({required this.comic, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
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
          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
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
// Lebar mengikuti layar, tinggi mengikuti rasio gambar, sehingga strip
// panjang (webtoon) tampil utuh tanpa terpotong.
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
    return Image.asset(
      path,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      gaplessPlayback: true,
      // batasi resolusi decode agar hemat memori pada gambar yang sangat tinggi
      cacheWidth: (mq.size.width * mq.devicePixelRatio).round(),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 12),
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