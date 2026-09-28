import '../model/comic_model.dart';

class ComicController {
  // ---------- PETA FOTO PER KOMIK (Cara 1: berdasarkan id) ----------
  // key = id komik (harus sama persis dengan id yang dipakai di getRecommendations/
  // getUpdates/getPopular/getBanners), value = path asset foto.
  static const Map<String, String> _coverMap = {
    // --- Rekomendasi Manhwa (rec_0 .. rec_13) ---
    'rec_0': 'assets/images/1.jpg',
    'rec_1': 'assets/images/2.png',
    'rec_2': 'assets/images/3.jpg',
    'rec_3': 'assets/images/4.jpg',
    'rec_4': 'assets/images/5.jpg',
    'rec_5': 'assets/images/6.jpg',
    'rec_6': 'assets/images/7.jpg',
    'rec_7': 'assets/images/8.jpg',
    'rec_8': 'assets/images/9.jpg',
    'rec_9': 'assets/images/10.jpg',
    'rec_10': 'assets/images/11.jpg',
    'rec_11': 'assets/images/12.png',
    'rec_12': 'assets/images/13.jpg',
    'rec_13': 'assets/images/14.jpg',

    // --- Update (upd_0 .. upd_11) ---
    'upd_0': 'assets/images/15.jpg',
    'upd_1': 'assets/images/16.jpg',
    'upd_2': 'assets/images/17.jpg',
    'upd_3': 'assets/images/18.jpg',
    'upd_4': 'assets/images/19.jpg',
    'upd_5': 'assets/images/20.jpg',
    'upd_6': 'assets/images/21.jpg',
    'upd_7': 'assets/images/22.jpg',
    'upd_8': 'assets/images/23.jpg',
    'upd_9': 'assets/images/24.jpg',
    'upd_10': 'assets/images/25.jpg',
    'upd_11': 'assets/images/26.jpg',

    // --- Populer: id-nya berubah sesuai `range` (Harian/Mingguan/dst),
    // jadi dipetakan lewat _popularCovers di bawah, bukan di sini.
  };

  // Foto khusus untuk section Populer, dipetakan berdasarkan index judul
  // (bukan lewat _coverMap karena id-nya berubah-ubah sesuai `range`).
  static const List<String> _popularCovers = [
    'assets/images/27.jpg',
    'assets/images/28.jpg',
    'assets/images/29.jpg',
    'assets/images/30.jpg',
    'assets/images/31.jpg',
    'assets/images/32.jpg',
    'assets/images/33.jpg',
    'assets/images/34.jpg',
    'assets/images/35.jpg',
    'assets/images/36.jpg',
    'assets/images/37.jpg',
    'assets/images/38.jpg',
  ];

  // Foto banner (banner_0 .. banner_4)
  static const List<String> _bannerCovers = [
    'assets/images/1.jpg',
    'assets/images/2.png',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
  ];

  // Dipakai kalau id tidak ketemu di map manapun, supaya tidak error.
  static const String _defaultCover = 'assets/images/default_cover.jpg';

  /// Ambil path foto tetap berdasarkan id komik.
  String _coverForId(String id) => _coverMap[id] ?? _defaultCover;

  List<Comic> getRecommendations({String type = 'Manhwa'}) {
    final titles = [
      'Demon Life Starting From A Baby',
      'The Genius Professor Wants To Take It Easy',
      'Got Dropped Into A Ghost Story, Still Gotta Work',
      'Hell Login',
      'Immortals Way Of Life',
      'Heavenly Demon Apocalypse',
      'The Lord Who Levels Up By Devouring',
      'Goblin Inc',
      'Survival Supremacy',
      'Sword Devouring Swordmaster',
      'Became The Patron Of Villains',
      'The Academy’s Weapon Replicator',
      'The Demon King Overrun By Heroes',
      'Terminally-Ill Genius Dark Knight',
    ];
    return List.generate(titles.length, (i) {
      final id = 'rec_$i';
      return Comic(
        id: id,
        title: titles[i],
        coverUrl: _coverForId(id),
        type: type,
        rating: 7.5 + (i % 5) * 0.3,
        chapter: 40 + i * 6,
        timeAgo: '${i + 1}d',
        countryFlag: i.isEven ? '🇰🇷' : '🇨🇳',
        isNew: i < 2,
        isHot: i % 3 == 0,
      );
    });
  }

  List<Comic> getUpdates() {
    final titles = [
      'Demonic Emperor',
      'Noble Lady Reformation Guide',
      'Reincarnation Of The Fist King',
      'Reincarnator’s Stream',
      'Academy’s Genius Swordmaster',
      'The Martial Genius Who Remembers Everything',
      'Chronicles Of The Lazy Sovereign',
      'Ode Of The Brave',
      '30 Years Have Passed Since The Prologue',
      'The Immortal Genius Spearman',
      'The Player Hides His Past',
      'The Return Of the Crazy Demon',
    ];
    return List.generate(titles.length, (i) {
      final id = 'upd_$i';
      return Comic(
        id: id,
        title: titles[i],
        coverUrl: _coverForId(id),
        type: 'Manhwa',
        rating: 8.0 + (i % 4) * 0.2,
        chapter: 900 - i * 60 > 0 ? 900 - i * 60 : 8 + i,
        timeAgo: '${i + 1} jam',
        prevTimeAgo: '${i + 7} hari',
        countryFlag: i % 2 == 0 ? '🇰🇷' : '🇨🇳',
        isUpdate: i % 2 == 0,
      );
    });
  }

  List<Comic> getPopular({String range = 'Harian'}) {
    final titles = [
      'Elegeed',
      'Kebangkitan Sekte Gunung Hua',
      'Sang Swordmaster Bintang',
      'Balas Dendam Sang Anjing Klan Pedang',
      'Aku Merawat Para Villain',
      'Aku Seorang Max Level Pemula',
      'Kaisar Demonic',
      'Nanomashin',
      'Elixir Sang Alkemis',
      'Bayangan Sang Pembunuh',
      'Klan Naga Yang Terlupakan',
      'Guru Bela Diri Bawah Tanah',
    ];
    return List.generate(titles.length, (i) {
      // Foto diambil berdasarkan index judul (tetap), bukan berdasarkan
      // `range`, supaya "Elegeed" selalu pakai foto yang sama walau
      // range-nya Harian/Mingguan/Bulanan.
      final cover = i < _popularCovers.length ? _popularCovers[i] : _defaultCover;
      return Comic(
        id: 'pop_${range}_$i',
        title: titles[i],
        coverUrl: cover,
        type: 'Manhwa',
        rating: 8.2 + (i % 3) * 0.2,
        chapter: 60 + i * 3,
        timeAgo: '${i + 2}d',
        countryFlag: i % 2 == 0 ? '🇰🇷' : '🇨🇳',
        isHot: true,
      );
    });
  }

  /// Mencari komik berdasarkan judul (case-insensitive), digabung dari
  /// semua sumber (Rekomendasi 3 tipe, Update, Populer) lalu di-dedupe
  /// berdasarkan id supaya tidak ada judul yang muncul dobel.
  List<Comic> searchComics(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final Map<String, Comic> combined = {};
    for (final c in [
      ...getRecommendations(type: 'Manhwa'),
      ...getRecommendations(type: 'Manga'),
      ...getRecommendations(type: 'Manhua'),
      ...getUpdates(),
      ...getPopular(),
    ]) {
      combined[c.id] = c;
    }

    return combined.values
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  List<Comic> getBanners() {
    // Setiap banner punya judul singkat + sinopsis sendiri (bukan satu
    // paragraf yang sama diulang), dipasangkan dengan banner_1..5.jpg.
    final data = [
      (
        title: 'Demon Life Starting From A Baby',
        desc: 'Terlahir kembali sebagai bayi dari klan iblis paling '
            'lemah, ia harus bertahan hidup di tengah persaingan darah '
            'yang tidak kenal ampun sejak dari buaian.',
      ),
      (
        title: 'Heavenly Demon Apocalypse',
        desc: 'Sang penguasa iblis terkuat bangkit kembali di zaman yang '
            'sudah sepenuhnya berubah, dan kali ini ia bersumpah tidak '
            'akan mengulang kesalahan yang membawanya pada kehancuran.',
      ),
      (
        title: 'Survival Supremacy',
        desc: 'Terjebak dalam permainan bertahan hidup yang tidak punya '
            'aturan, satu-satunya cara untuk pulang adalah menjadi yang '
            'paling kuat di antara semua pemain.',
      ),
      (
        title: 'The Demon King Overrun By Heroes',
        desc: 'Dikepung oleh pahlawan dari segala penjuru dunia, sang '
            'raja iblis harus mencari cara untuk membalikkan keadaan '
            'sebelum kerajaannya benar-benar runtuh.',
      ),
      (
        title: 'Terminally-Ill Genius Dark Knight',
        desc: 'Divonis hidupnya tak akan lama lagi, seorang ksatria '
            'jenius memutuskan menghabiskan sisa waktunya untuk '
            'menyelesaikan satu misi yang selama ini ia hindari.',
      ),
    ];

    return List.generate(data.length, (i) {
      final cover = i < _bannerCovers.length ? _bannerCovers[i] : _defaultCover;
      return Comic(
        id: 'banner_$i',
        title: data[i].title,
        description: data[i].desc,
        coverUrl: cover,
        type: 'Manhwa',
        rating: 8.6,
        chapter: 42,
        timeAgo: 'New',
        countryFlag: '🇰🇷',
        isNew: true,
        isHot: true,
      );
    });
  }
}