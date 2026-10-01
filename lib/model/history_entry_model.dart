// lib/model/history_entry_model.dart
//
// MODEL untuk satu entri riwayat baca + helper JSON untuk Comic
// (supaya favorit & riwayat bisa disimpan ke penyimpanan lokal tanpa
// mengubah comic_model.dart).

import 'comic_model.dart';

Map<String, dynamic> comicToJson(Comic c) => {
      'id': c.id,
      'title': c.title,
      'coverUrl': c.coverUrl,
      'type': c.type,
      'rating': c.rating,
      'chapter': c.chapter,
      'timeAgo': c.timeAgo,
      'prevChapter': c.prevChapter,
      'prevTimeAgo': c.prevTimeAgo,
      'countryFlag': c.countryFlag,
      'isNew': c.isNew,
      'isHot': c.isHot,
      'isUpdate': c.isUpdate,
      'description': c.description,
      'genres': c.genres,
      'author': c.author,
      'artist': c.artist,
      'status': c.status,
      'viewCount': c.viewCount,
      'bookmarkCount': c.bookmarkCount,
      'voteCount': c.voteCount,
    };

Comic comicFromJson(Map<String, dynamic> j) => Comic(
      id: j['id'] as String,
      title: j['title'] as String,
      coverUrl: j['coverUrl'] as String,
      type: j['type'] as String,
      rating: (j['rating'] as num).toDouble(),
      chapter: j['chapter'] as int,
      timeAgo: j['timeAgo'] as String,
      countryFlag: j['countryFlag'] as String,
      prevChapter: j['prevChapter'] as int?,
      prevTimeAgo: (j['prevTimeAgo'] ?? '') as String,
      isNew: (j['isNew'] ?? false) as bool,
      isHot: (j['isHot'] ?? false) as bool,
      isUpdate: (j['isUpdate'] ?? false) as bool,
      description: (j['description'] ?? '') as String,
      genres: List<String>.from(j['genres'] ?? const []),
      author: (j['author'] ?? '-') as String,
      artist: (j['artist'] ?? '-') as String,
      status: (j['status'] ?? 'Ongoing') as String,
      viewCount: (j['viewCount'] ?? 0) as int,
      bookmarkCount: (j['bookmarkCount'] ?? 0) as int,
      voteCount: (j['voteCount'] ?? 0) as int,
    );

class HistoryEntry {
  final Comic comic;
  final int chapter; // chapter terakhir yang dibuka
  final DateTime readAt;

  const HistoryEntry({
    required this.comic,
    required this.chapter,
    required this.readAt,
  });

  Map<String, dynamic> toJson() => {
        'comic': comicToJson(comic),
        'chapter': chapter,
        'readAt': readAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        comic: comicFromJson(Map<String, dynamic>.from(j['comic'] as Map)),
        chapter: j['chapter'] as int,
        readAt: DateTime.parse(j['readAt'] as String),
      );
}