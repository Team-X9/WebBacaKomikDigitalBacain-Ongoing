import 'package:flutter/material.dart';
import '../controller/comic_controller.dart';
import '../controller/library_controller.dart';
import '../model/chapter_model.dart';
import '../model/comic_model.dart';
import 'reader_page.dart';
import '../theme.dart';

class ComicDetailPage extends StatefulWidget {
  final Comic comic;
  const ComicDetailPage({super.key, required this.comic});

  @override
  State<ComicDetailPage> createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  bool _descExpanded = false;
  int _activeTab = 0; // 0 = Chapters, 1 = Info, 2 = Novel
  final TextEditingController _searchCtrl = TextEditingController();
  final ComicController _controller = ComicController();
  final LibraryController _library = LibraryController.instance;
  late final List<Chapter> _allChapters;
  String _query = '';
  bool _ascending = false; // false = terbaru dulu

  @override
  void initState() {
    super.initState();
    _allChapters = _controller.getChapters(widget.comic);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Chapter> get _filteredChapters {
    final q = _query.trim();
    var list = q.isEmpty
        ? _allChapters
        : _allChapters.where((c) => c.number.toString().contains(q)).toList();
    if (_ascending) list = list.reversed.toList();
    return list;
  }

  /// 12345 -> "12.3K", 1500000 -> "1.5M"
  String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  void _openChapter(int chapterNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterReaderPage(
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
      body: ListenableBuilder(
        listenable: _library,
        builder: (context, _) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderBanner(context, comic)),
          SliverToBoxAdapter(child: _buildInfoSection(comic)),
          SliverToBoxAdapter(child: _buildTabsAndSearch()),
          if (_activeTab == 0)
            _buildChapterList()
          else if (_activeTab == 1)
            SliverToBoxAdapter(child: _buildInfoTab(comic))
          else
            SliverToBoxAdapter(child: _buildComingSoon()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
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
    final last = _library.lastReadChapter(comic.id);
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
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => _openChapter(last ?? 1),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(last == null ? 'Mulai Baca' : 'Lanjut Ch. $last'),
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
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _openChapter(comic.chapter),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.surfaceLight,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Terbaru'),
                ),
              ),
              const SizedBox(width: 8),
              _buildFavoriteButton(comic),
              const SizedBox(width: 8),
              _outlinedIconButton(Icons.playlist_add_rounded, 'Tambah ke Readlist'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(Icons.star_rounded, comic.rating.toStringAsFixed(1), AppColors.gold),
              const SizedBox(width: 16),
              _statChip(Icons.bookmark_rounded, _compact(comic.bookmarkCount), AppColors.primaryLight),
              const SizedBox(width: 16),
              _statChip(Icons.remove_red_eye_rounded, _compact(comic.viewCount),
                  AppColors.textSecondary),
              const SizedBox(width: 16),
              _statChip(Icons.emoji_events_rounded, _compact(comic.voteCount),
                  AppColors.accentPink),
            ],
          ),
          const SizedBox(height: 16),
          _buildDescription(comic),
          const SizedBox(height: 16),
          _buildTagsRow('Genre', comic.genres),
          const SizedBox(height: 10),
          _buildTagsRow('Author', [comic.author]),
          const SizedBox(height: 10),
          _buildTagsRow('Artist', [comic.artist]),
          const SizedBox(height: 10),
          _buildTagsRow('Format', [comic.type]),
          const SizedBox(height: 10),
          _buildTagsRow('Status', [comic.status]),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(Comic comic) {
    final fav = _library.isFavorite(comic.id);
    return Tooltip(
      message: fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
      child: InkWell(
        onTap: () => _library.toggleFavorite(comic),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: fav ? AppColors.accentPink : AppColors.border),
          ),
          child: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: fav ? AppColors.accentPink : Colors.white,
            size: 20,
          ),
        ),
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
                suffixIcon: Tooltip(
                  message: _ascending ? 'Urut: terlama dulu' : 'Urut: terbaru dulu',
                  child: InkWell(
                    onTap: () => setState(() => _ascending = !_ascending),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _ascending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
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

  Widget _chapterTile(Chapter chapter) {
    final isLastRead = _library.lastReadChapter(widget.comic.id) == chapter.number;
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
              child: Text(chapter.label,
                  style: TextStyle(
                      color: isLastRead ? AppColors.primaryLight : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
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

  // ---------------- TAB INFO ----------------
  Widget _buildInfoTab(Comic comic) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Status', comic.status),
      MapEntry('Tipe', '${comic.type} ${comic.countryFlag}'),
      MapEntry('Total Chapter', '${comic.chapter}'),
      MapEntry('Rating', comic.rating.toStringAsFixed(1)),
      MapEntry('Author', comic.author),
      MapEntry('Artist', comic.artist),
      MapEntry('Genre', comic.genres.join(', ')),
      MapEntry('Update Terakhir', comic.timeAgo),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(rows[i].key,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12.5)),
                    ),
                    Expanded(
                      child: Text(rows[i].value,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              if (i != rows.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
          ],
        ),
      ),
    );
  }
}