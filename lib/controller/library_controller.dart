// lib/controller/library_controller.dart
//
// CONTROLLER + state global untuk Favorit & Riwayat Baca.
// Memakai ChangeNotifier: widget yang membungkus dirinya dengan
// ListenableBuilder(listenable: LibraryController.instance, ...) akan
// otomatis rebuild setiap kali favorit/riwayat berubah, di halaman mana pun.
//
// Dibutuhkan: flutter pub add shared_preferences

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/comic_model.dart';
import '../model/history_entry_model.dart';

class LibraryController extends ChangeNotifier {
  LibraryController._();
  static final LibraryController instance = LibraryController._();

  static const _favKey = 'library_favorites';
  static const _historyKey = 'library_history';
  static const _maxHistory = 100;

  // Map biasa menjaga urutan penambahan (LinkedHashMap).
  final Map<String, Comic> _favorites = {};
  final List<HistoryEntry> _history = []; // index 0 = paling baru

  // ---------------- FAVORIT ----------------
  /// Favorit terbaru di paling atas.
  List<Comic> get favorites => _favorites.values.toList().reversed.toList();
  int get favoriteCount => _favorites.length;
  bool isFavorite(String comicId) => _favorites.containsKey(comicId);

  void toggleFavorite(Comic comic) {
    if (_favorites.containsKey(comic.id)) {
      _favorites.remove(comic.id);
    } else {
      _favorites[comic.id] = comic;
    }
    notifyListeners();
    _save();
  }

  // ---------------- RIWAYAT ----------------
  List<HistoryEntry> get history => List.unmodifiable(_history);
  int get historyCount => _history.length;

  /// Chapter terakhir yang dibaca untuk satu komik (null jika belum pernah).
  int? lastReadChapter(String comicId) {
    for (final e in _history) {
      if (e.comic.id == comicId) return e.chapter;
    }
    return null;
  }

  /// Panggil setiap kali reader membuka sebuah chapter.
  void recordRead(Comic comic, int chapter) {
    _history.removeWhere((e) => e.comic.id == comic.id);
    _history.insert(
      0,
      HistoryEntry(comic: comic, chapter: chapter, readAt: DateTime.now()),
    );
    if (_history.length > _maxHistory) {
      _history.removeRange(_maxHistory, _history.length);
    }
    notifyListeners();
    _save();
  }

  void removeHistory(String comicId) {
    _history.removeWhere((e) => e.comic.id == comicId);
    notifyListeners();
    _save();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
    _save();
  }

  // ---------------- PENYIMPANAN LOKAL ----------------
  /// Panggil sekali di main() sebelum runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final favRaw = prefs.getString(_favKey);
      if (favRaw != null) {
        for (final item in jsonDecode(favRaw) as List) {
          final c = comicFromJson(Map<String, dynamic>.from(item as Map));
          _favorites[c.id] = c;
        }
      }

      final histRaw = prefs.getString(_historyKey);
      if (histRaw != null) {
        for (final item in jsonDecode(histRaw) as List) {
          _history.add(
              HistoryEntry.fromJson(Map<String, dynamic>.from(item as Map)));
        }
      }
    } catch (e) {
      // Data rusak / format lama: mulai dari kosong daripada crash.
      debugPrint('LibraryController.load gagal: $e');
      _favorites.clear();
      _history.clear();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _favKey,
        jsonEncode(_favorites.values.map(comicToJson).toList()),
      );
      await prefs.setString(
        _historyKey,
        jsonEncode(_history.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('LibraryController._save gagal: $e');
    }
  }
}