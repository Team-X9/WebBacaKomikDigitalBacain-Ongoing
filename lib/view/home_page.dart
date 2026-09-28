// lib/views/home_page.dart
//
// VIEW: halaman utama, dibuat semirip mungkin dengan web referensi
// (hero banner carousel, tab Rekomendasi, section Update, section Populer).
// Semua data diambil dari ComicController (Controller), bukan hardcode di View.

import 'dart:ui';

import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/comic_controller.dart';
import '../model/comic_model.dart';
import '../theme.dart';
import '../widget/comic_card.dart';
import 'profile_page.dart';
import 'reader_page.dart';

class HomePage extends StatefulWidget {
  final AuthController authController;
  const HomePage({super.key, required this.authController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _comicController = ComicController();
  final _bannerPageCtrl = PageController();

  String _rekomendasiType = 'Manhwa';
  String _updateTab = 'Project';
  String _popularRange = 'Harian';
  int _bannerIndex = 0;

  late List<Comic> _banners;
  late List<Comic> _updates;
  late List<Comic> _popular;

  @override
  void initState() {
    super.initState();
    _banners = _comicController.getBanners();
    _updates = _comicController.getUpdates();
    _popular = _comicController.getPopular(range: _popularRange);
  }

  List<Comic> get _recommendations =>
      _comicController.getRecommendations(type: _rekomendasiType);

  void _openReader(Comic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderPage(comic: comic)),
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
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text('BACAIN',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6)),
        ],
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
  // Hero banner: sinopsis + tombol "Mulai Baca" di kiri, poster komik di
  // kanan, dengan latar ambient dari cover yang sama (di-blur & digelapkan)
  // supaya poster tetap jadi fokus tanpa perlu aset background terpisah.
  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _bannerPageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, i) {
              final b = _banners[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // latar ambient: cover yang sama, di-blur + digelapkan
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Image.asset(
                      b.coverUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.45),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Container(color: AppColors.background.withOpacity(0.35)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.background.withOpacity(0.95),
                          AppColors.background.withOpacity(0.55),
                        ],
                        stops: const [0.0, 0.75],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
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
                              const SizedBox(height: 12),
                              Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                b.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton(
                                onPressed: () => _openReader(b),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.primaryLight),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Mulai Baca',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            b.coverUrl,
                            width: 100,
                            height: 148,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
      );

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
    // Satu baris, scroll ke samping (horizontal) — sama seperti web referensi:
    // card tidak wrap ke bawah, tapi digeser ke kiri/kanan. Rasio lebar:tinggi
    // dibuat ~0.55 (lebih ramping/tinggi) supaya mirip cover manhwa asli,
    // dan jumlah item cukup banyak supaya baris selalu penuh sampai tepi layar.
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
    // Grid poster multi-kolom (bukan list baris full-width) — kolom
    // menyesuaikan lebar layar otomatis, sesuai web referensi.
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