// lib/controllers/auth_controller.dart
//
// CONTROLLER untuk logika autentikasi. Di aplikasi nyata, method login()
// akan memanggil API/Firebase, bukan mengecek data statis seperti ini.

import '../model/user_model.dart';

class AuthController {
  // "Database" dummy satu akun untuk keperluan demo.
  final AppUser _demoUser = AppUser(
    username: 'senkuu',
    email: 'senkuu@baca.in',
    password: '123456',
    avatarUrl: 'assets/Yaemiko.png',
    bio: 'Penikmat manhwa aksi & fantasi. Baca sambil ngopi ☕',
    joinDate: 'Bergabung Jan 2024',
    favoriteCount: 128,
    readCount: 3420,
    commentCount: 57,
  );

  AppUser? get currentUser => _isLoggedIn ? _demoUser : null;
  bool _isLoggedIn = false;

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  String? login(String emailOrUsername, String password) {
    final input = emailOrUsername.trim();
    if (input.isEmpty || password.isEmpty) {
      return 'Email/username dan password wajib diisi';
    }
    final match = input == _demoUser.email || input == _demoUser.username;
    if (!match || password != _demoUser.password) {
      return 'Email/username atau password salah';
    }
    _isLoggedIn = true;
    return null;
  }

  void logout() => _isLoggedIn = false;
}