// lib/models/user_model.dart
//
// MODEL untuk data akun pengguna, dipakai oleh LoginPage & ProfilePage.

class AppUser {
  String _username;
  String _email;
  String _password;
  String _avatarUrl;
  String _bio;
  String _joinDate;
  int _favoriteCount;
  int _readCount;
  int _commentCount;

  AppUser({
    required String username,
    required String email,
    required String password,
    required String avatarUrl,
    String bio = '',
    String joinDate = '',
    int favoriteCount = 0,
    int readCount = 0,
    int commentCount = 0,
  })  : _username = username,
        _email = email,
        _password = password,
        _avatarUrl = avatarUrl,
        _bio = bio,
        _joinDate = joinDate,
        _favoriteCount = favoriteCount,
        _readCount = readCount,
        _commentCount = commentCount;

  // ---------- GETTER ----------
  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get avatarUrl => _avatarUrl;
  String get bio => _bio;
  String get joinDate => _joinDate;
  int get favoriteCount => _favoriteCount;
  int get readCount => _readCount;
  int get commentCount => _commentCount;

  // ---------- SETTER ----------
  set username(String value) => _username = value;
  set email(String value) => _email = value;
  set password(String value) => _password = value;
  set avatarUrl(String value) => _avatarUrl = value;
  set bio(String value) => _bio = value;
  set joinDate(String value) => _joinDate = value;
  set favoriteCount(int value) => _favoriteCount = value;
  set readCount(int value) => _readCount = value;
  set commentCount(int value) => _commentCount = value;
}
