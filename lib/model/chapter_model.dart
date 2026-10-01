// lib/model/chapter_model.dart
//
// MODEL untuk satu chapter komik. Dipisah dari Comic supaya nanti mudah
// ditambah field seperti judul chapter, jumlah halaman, atau status "sudah
// dibaca" (dipakai fitur riwayat baca di langkah berikutnya).

class Chapter {
  final int number;
  final String timeAgo; // contoh: "8 jam", "3 hari lalu"

  const Chapter({required this.number, required this.timeAgo});

  String get label => 'Chapter $number';
}
