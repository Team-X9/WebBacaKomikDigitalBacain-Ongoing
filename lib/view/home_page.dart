// lib/views/home_page.dart
//
// VIEW: halaman utama, dibuat semirip mungkin dengan web referensi
// (hero banner carousel, tab Rekomendasi, section Update, section Populer).
// Semua data diambil dari ComicController (Controller), bukan hardcode di View.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/comic_controller.dart';
import '../controller/library_controller.dart';
import '../model/comic_model.dart';
import '../theme.dart';
import '../widget/comic_card.dart';
import 'profile_page.dart';
import 'comic_detail_page.dart';
import 'reader_page.dart';

class HomePage extends StatefulWidget {
  final AuthController authController;
  const HomePage({super.key, required this.authController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _comicController = ComicController();

  // ---- banner ----
  static const Duration _autoScrollInterval = Duration(seconds: 5);
  static const Duration _slideDuration = Duration(milliseconds: 650);
  late final PageController _bannerPageCtrl;
  late final int _bannerStartPage;
  Timer? _bannerTimer;
  bool _bannerHovering = false;
  bool _bannerPressing = false;
  int _bannerPage = 0; // index mentah (tak terbatas); tampilkan dengan % jumlah banner

  String _rekomendasiType = 'Manhwa';
  String _updateTab = 'Project';
  String _popularRange = 'Harian';

  late List<Comic> _banners;
  late List<Comic> _updates;
  late List<Comic> _popular;

  int get _bannerIndex =>
      _banners.isEmpty ? 0 : _bannerPage % _banners.length;

  @override
  void initState() {
    super.initState();
    _banners = _comicController.getBanners();
    _updates = _comicController.getUpdates();
    _popular = _comicController.getPopular(range: _popularRange);

    // Mulai dari halaman besar supaya PageView "tak terbatas": setelah
    // banner terakhir otomatis lanjut ke banner pertama tanpa rewind.
    _bannerStartPage = _banners.length * 1000;
    _bannerPage = _bannerStartPage;
    _bannerPageCtrl = PageController(initialPage: _bannerStartPage);
    // Dengarkan controller langsung supaya titik indikator selalu ikut
    // bergerak (tidak hanya bergantung pada onPageChanged).
    _bannerPageCtrl.addListener(_onBannerScroll);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageCtrl.removeListener(_onBannerScroll);
    _bannerPageCtrl.dispose();
    super.dispose();
  }

  // ---------------- AUTO SCROLL BANNER ----------------
  void _onBannerScroll() {
    final p = _bannerPageCtrl.page?.round();
    if (p != null && p != _bannerPage && mounted) {
      setState(() => _bannerPage = p);
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    if (_banners.length < 2) return;
    _bannerTimer = Timer.periodic(_autoScrollInterval, (_) {
      // jeda saat kursor di atas banner atau banner sedang disentuh/digeser
      if (_bannerHovering || _bannerPressing) return;
      _nextBanner();
    });
  }

  void _nextBanner() {
    if (!mounted || !_bannerPageCtrl.hasClients) return;
    _bannerPageCtrl.nextPage(
        duration: _slideDuration, curve: Curves.easeInOutCubic);
  }

  void _prevBanner() {
    if (!mounted || !_bannerPageCtrl.hasClients) return;
    _bannerPageCtrl.previousPage(
        duration: _slideDuration, curve: Curves.easeInOutCubic);
  }

  void _goToBanner(int index) {
    if (!mounted || !_bannerPageCtrl.hasClients) return;
    final base = _bannerPage - _bannerIndex;
    _bannerPageCtrl.animateToPage(base + index,
        duration: _slideDuration, curve: Curves.easeInOutCubic);
    _startBannerTimer(); // reset hitung mundur setelah klik manual
  }

  List<Comic> get _recommendations =>
      _comicController.getRecommendations(type: _rekomendasiType);

  void _openReader(Comic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComicDetailPage(comic: comic)),
    );
  }

  void _startReading(Comic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterReaderPage(comic: comic, startChapter: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _buildBanner(),
            _buildContinueReading(),
            const SizedBox(height: 28),
            _sectionTitle('Rekomendasi'),
            const SizedBox(height: 12),
            _buildTypeTabs(),
            const SizedBox(height: 14),
            _buildRecommendationGrid(),
            const SizedBox(height: 28),
            _sectionTitle('Update'),
            const SizedBox(height: 12),
            _buildUpdateTabs(),
            const SizedBox(height: 14),
            _buildUpdateList(),
            const SizedBox(height: 28),
            _sectionTitle('Populer'),
            const SizedBox(height: 12),
            _buildPopularTabs(),
            const SizedBox(height: 14),
            _buildPopularList(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 10,
      title: Image.asset(
        'assets/images/Logo.png',
        height: 50,
        width: 60,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text(
          'BACAIN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
      actions: [
        SearchAnchor(
          isFullScreen: false,
          viewHintText: 'Cari judul manhwa, manga, manhua...',
          viewBackgroundColor: AppColors.surface,
          viewElevation: 8,
          dividerColor: AppColors.border,
          viewConstraints: const BoxConstraints(
            minWidth: 300,
            maxWidth: 340,
            maxHeight: 360,
          ),
          viewShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          headerTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          headerHintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          builder: (context, controller) {
            return IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.white),
              onPressed: () => controller.openView(),
            );
          },
          suggestionsBuilder: (context, controller) {
            final query = controller.text;
            if (query.trim().isEmpty) {
              return [_suggestionMessage('Ketik judul komik untuk mencari')];
            }
            final results = _comicController.searchComics(query);
            if (results.isEmpty) {
              return [_suggestionMessage('Tidak ada hasil untuk "$query"')];
            }
            return results
                .map((c) => _searchResultTile(context, controller, c))
                .toList();
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded,
              color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 2),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfilePage(authController: widget.authController),
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              backgroundImage: widget.authController.currentUser != null
                  ? AssetImage(widget.authController.currentUser!.avatarUrl)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SEARCH ----------------
  Widget _suggestionMessage(String text) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      );

  Widget _searchResultTile(
      BuildContext context, SearchController controller, Comic c) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          c.coverUrl,
          width: 42,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        c.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${c.type} • ★ ${c.rating.toStringAsFixed(1)} • Ch. ${c.chapter}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      onTap: () {
        controller.closeView(c.title);
        _openReader(c);
      },
    );
  }

  // ---------------- BANNER ----------------
  // Hero banner auto-scroll: tiap 5 detik pindah ke banner berikutnya dan
  // kembali ke banner pertama setelah yang terakhir. Berhenti sementara saat
  // kursor di atas banner atau saat disentuh/digeser. Responsif: layout
  // ringkas di HP, layout lebar (poster besar + tombol panah) di layar besar.
  Widget _buildBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final compact = w < 600;
        final showArrows = w >= 800;
        final height = compact ? 270.0 : (w < 1000 ? 310.0 : 350.0);

        return Column(
          children: [
            MouseRegion(
              onEnter: (_) => _bannerHovering = true,
              onExit: (_) => _bannerHovering = false,
              child: Listener(
                onPointerDown: (_) => _bannerPressing = true,
                onPointerUp: (_) => _bannerPressing = false,
                onPointerCancel: (_) => _bannerPressing = false,
                child: SizedBox(
                  height: height,
                  child: Stack(
                    children: [
                      // izinkan geser dengan mouse/trackpad juga (untuk web/desktop)
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: PageView.builder(
                          controller: _bannerPageCtrl,
                          onPageChanged: (p) {
                            if (p != _bannerPage) {
                              setState(() => _bannerPage = p);
                            }
                          },
                          itemBuilder: (context, page) {
                            final b = _banners[page % _banners.length];
                            return _bannerSlide(b, compact);
                          },
                        ),
                      ),
                      if (showArrows) ...[
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _arrowButton(
                                Icons.chevron_left_rounded, _prevBanner),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _arrowButton(
                                Icons.chevron_right_rounded, _nextBanner),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                final active = i == _bannerIndex;
                return GestureDetector(
                  onTap: () => _goToBanner(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: active ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _bannerSlide(Comic b, bool compact) {
    final posterW = compact ? 100.0 : 160.0;
    final posterH = compact ? 148.0 : 236.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // latar ambient: cover yang sama, di-blur + sedikit digelapkan
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Image.asset(
            b.coverUrl,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.30),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surfaceLight),
          ),
        ),
        // gradasi kiri -> kanan agar teks terbaca
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.background.withValues(alpha: 0.92),
                AppColors.background.withValues(alpha: 0.45),
                AppColors.background.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // gradasi bawah menyatu dengan latar halaman
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.85),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 72, vertical: compact ? 18 : 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _chip('★ ${b.rating}', AppColors.gold),
                            const SizedBox(width: 6),
                            _chip('New', AppColors.primary),
                            const SizedBox(width: 6),
                            _chip('Popular', Colors.redAccent),
                          ],
                        ),
                        SizedBox(height: compact ? 10 : 14),
                        Text(
                          b.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 19 : 32,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3),
                        ),
                        if (!compact && b.genres.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final g in b.genres.take(3)) _genreTag(g),
                              _genreTag('Ch. ${b.chapter}', highlight: true),
                            ],
                          ),
                        ],
                        SizedBox(height: compact ? 8 : 12),
                        Text(
                          b.description,
                          maxLines: compact ? 3 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: compact ? 12 : 14,
                              height: 1.5),
                        ),
                        SizedBox(height: compact ? 12 : 18),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _startReading(b),
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 20),
                              label: const Text('Mulai Baca'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 14 : 20,
                                    vertical: compact ? 10 : 14),
                                textStyle: TextStyle(
                                    fontSize: compact ? 13 : 14,
                                    fontWeight: FontWeight.w700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () => _openReader(b),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.white
                                        .withValues(alpha: 0.35)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 14 : 20,
                                    vertical: compact ? 10 : 14),
                                textStyle: TextStyle(
                                    fontSize: compact ? 13 : 14,
                                    fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Detail'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 14 : 40),
                  GestureDetector(
                    onTap: () => _openReader(b),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 1,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          b.coverUrl,
                          width: posterW,
                          height: posterH,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: posterW,
                            height: posterH,
                            color: AppColors.surfaceLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          onTap();
          _startBannerTimer(); // reset hitung mundur setelah klik manual
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _genreTag(String text, {bool highlight = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight
                ? AppColors.primaryLight.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      );

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
      );

  // ---------------- LANJUTKAN MEMBACA ----------------
  // Diambil dari riwayat baca; disembunyikan jika belum ada riwayat.
  Widget _buildContinueReading() {
    return ListenableBuilder(
      listenable: LibraryController.instance,
      builder: (context, _) {
        final items = LibraryController.instance.history.take(10).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Lanjutkan Membaca'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final e = items[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterReaderPage(
                              comic: e.comic, startChapter: e.chapter),
                        ),
                      ),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(e.comic.coverUrl,
                                        fit: BoxFit.cover),
                                    Positioned(
                                      left: 6,
                                      bottom: 6,
                                      child: _chip('Ch. ${e.chapter}',
                                          AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(e.comic.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- SHARED ----------------
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
      );

  Widget _tabButton(String label, String groupValue, ValueChanged<String> onTap) {
    final active = label == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTap(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }

  // ---------------- REKOMENDASI ----------------
  Widget _buildTypeTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Manhwa', 'Manga', 'Manhua']
            .map((t) => _tabButton(
                t, _rekomendasiType, (v) => setState(() => _rekomendasiType = v)))
            .toList(),
      ),
    );
  }

  Widget _buildRecommendationGrid() {
    final list = _recommendations;
    // Satu baris, scroll ke samping (horizontal) — sama seperti web referensi.
    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 150,
            child: ComicCard(
                comic: list[i], onTap: () => _openReader(list[i])),
          ),
        ),
      ),
    );
  }

  // ---------------- UPDATE ----------------
  Widget _buildUpdateTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Project', 'Mirror']
            .map((t) =>
                _tabButton(t, _updateTab, (v) => setState(() => _updateTab = v)))
            .toList(),
      ),
    );
  }

  Widget _buildUpdateList() {
    // Grid poster multi-kolom — kolom menyesuaikan lebar layar otomatis.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _updates.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: 20,
        crossAxisSpacing: 12,
        childAspectRatio: 0.47,
      ),
      itemBuilder: (context, i) => ComicUpdateGridCard(
          comic: _updates[i], onTap: () => _openReader(_updates[i])),
    );
  }

  // ---------------- POPULER ----------------
  Widget _buildPopularTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['Harian', 'Mingguan', 'Semua']
            .map((t) => _tabButton(t, _popularRange, (v) {
                  setState(() {
                    _popularRange = v;
                    _popular = _comicController.getPopular(range: v);
                  });
                }))
            .toList(),
      ),
    );
  }

  Widget _buildPopularList() {
    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _popular.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 150,
            child: ComicCard(
                comic: _popular[i], onTap: () => _openReader(_popular[i])),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_rounded,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              const Text('BACAIN',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Copyright © 2026 Bacain. All rights reserved.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}