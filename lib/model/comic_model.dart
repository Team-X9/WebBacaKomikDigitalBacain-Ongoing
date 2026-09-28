// lib/models/comic_model.dart
//
// MODEL (bagian "M" dari MVC).
// Menyimpan data satu judul komik/manhwa/manhua beserta getter & setter
// untuk setiap field privat-nya.

class Comic {
  String _id;
  String _title;
  String _coverUrl;
  String _type; // "Manhwa" | "Manga" | "Manhua"
  double _rating;
  int _chapter;
  String _timeAgo; // contoh: "1 hari", "7 jam"
  int _prevChapter; // chapter sebelumnya, ditampilkan sebagai baris ke-2
  String _prevTimeAgo;
  String _countryFlag; // emoji bendera asal
  bool _isNew;
  bool _isHot;
  bool _isUpdate; // badge "UP" pada card update
  String _description; // sinopsis singkat, dipakai di banner hero

  Comic({
    required String id,
    required String title,
    required String coverUrl,
    required String type,
    required double rating,
    required int chapter,
    required String timeAgo,
    required String countryFlag,
    String description = '',
    int? prevChapter,
    String prevTimeAgo = '',
    bool isNew = false,
    bool isHot = false,
    bool isUpdate = false,
  })  : _id = id,
        _title = title,
        _coverUrl = coverUrl,
        _type = type,
        _rating = rating,
        _chapter = chapter,
        _timeAgo = timeAgo,
        _prevChapter = prevChapter ?? (chapter > 1 ? chapter - 1 : chapter),
        _prevTimeAgo = prevTimeAgo,
        _countryFlag = countryFlag,
        _isNew = isNew,
        _isHot = isHot,
        _isUpdate = isUpdate,
        _description = description;

  // ---------- GETTER ----------
  String get id => _id;
  String get title => _title;
  String get coverUrl => _coverUrl;
  String get type => _type;
  double get rating => _rating;
  int get chapter => _chapter;
  String get timeAgo => _timeAgo;
  int get prevChapter => _prevChapter;
  String get prevTimeAgo => _prevTimeAgo;
  String get countryFlag => _countryFlag;
  bool get isNew => _isNew;
  bool get isHot => _isHot;
  bool get isUpdate => _isUpdate;
  String get description => _description;

  // ---------- SETTER ----------
  set title(String value) => _title = value;
  set coverUrl(String value) => _coverUrl = value;
  set type(String value) => _type = value;
  set rating(double value) => _rating = value;
  set chapter(int value) => _chapter = value;
  set timeAgo(String value) => _timeAgo = value;
  set prevChapter(int value) => _prevChapter = value;
  set prevTimeAgo(String value) => _prevTimeAgo = value;
  set countryFlag(String value) => _countryFlag = value;
  set isNew(bool value) => _isNew = value;
  set isHot(bool value) => _isHot = value;
  set isUpdate(bool value) => _isUpdate = value;
  set description(String value) => _description = value;
}