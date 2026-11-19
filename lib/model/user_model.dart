// lib/model/user_model.dart
//
// MODEL untuk data akun pengguna, dipakai oleh LoginPage & ProfilePage.
// Data berasal dari tabel `users` di MySQL (lewat API). Password TIDAK
// pernah dikirim ke aplikasi, hanya disimpan sebagai hash di database.

class AppUser {
  String _username;
  String _email;
  String _avatarUrl;
  String _bio;
  String _joinDate;
  int _favoriteCount;
  int _readCount;
  int _commentCount;

  AppUser({
    required String username,
    required String email,
    required String avatarUrl,
    String bio = '',
    String joinDate = '',
    int favoriteCount = 0,
    int readCount = 0,
    int commentCount = 0,
  })  : _username = username,
        _email = email,
        _avatarUrl = avatarUrl,
        _bio = bio,
        _joinDate = joinDate,
        _favoriteCount = favoriteCount,
        _readCount = readCount,
        _commentCount = commentCount;

  /// Membuat AppUser dari JSON hasil API (`user` pada respons login / me).
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: (json['avatarUrl'] as String?)?.isNotEmpty == true
          ? json['avatarUrl'] as String
          : 'assets/Yaemiko.png',
      bio: json['bio'] as String? ?? '',
      joinDate: _formatJoinDate(json['createdAt'] as String?),
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }

  static const List<String> _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _formatJoinDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return 'Bergabung ${_bulan[d.month - 1]} ${d.year}';
  }

  // ---------- GETTER ----------
  String get username => _username;
  String get email => _email;
  String get avatarUrl => _avatarUrl;
  String get bio => _bio;
  String get joinDate => _joinDate;
  int get favoriteCount => _favoriteCount;
  int get readCount => _readCount;
  int get commentCount => _commentCount;

  // ---------- SETTER ----------
  set username(String value) => _username = value;
  set email(String value) => _email = value;
  set avatarUrl(String value) => _avatarUrl = value;
  set bio(String value) => _bio = value;
  set joinDate(String value) => _joinDate = value;
  set favoriteCount(int value) => _favoriteCount = value;
  set readCount(int value) => _readCount = value;
  set commentCount(int value) => _commentCount = value;
}