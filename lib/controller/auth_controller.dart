// lib/controller/auth_controller.dart
//
// CONTROLLER untuk logika autentikasi. Berbicara dengan backend (Express +
// MySQL) lewat HTTP; Flutter tidak pernah terhubung langsung ke database.
//
// Singleton: `AuthController()` di mana pun mengembalikan instance yang
// sama, jadi status login terbagi ke semua halaman tanpa mengubah View lain.
//
// Mode demo: jika di-build dengan --dart-define=USE_DUMMY_AUTH=true, login
// memakai satu akun bawaan di bawah (tanpa backend/database). Catatan:
// kredensial ini ikut terkirim ke browser, jadi hanya untuk demo publik.
//
// Dibutuhkan: flutter pub add http shared_preferences

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../model/user_model.dart';

class AuthController {
  AuthController._();
  static final AuthController _instance = AuthController._();
  factory AuthController() => _instance;

  static const _tokenKey = 'auth_token';
  static const _timeout = Duration(seconds: 10);

  // ---- akun demo (hanya dipakai saat USE_DUMMY_AUTH=true) ----
  static const _dummyToken = 'dummy-session';
  static const _dummyUsername = 'senkuu';
  static const _dummyEmail = 'senkuu@baca.in';
  static const _dummyPassword = '123456';

  AppUser _buildDummyUser() => AppUser.fromJson({
        'username': _dummyUsername,
        'email': _dummyEmail,
        'avatarUrl': 'assets/Yaemiko.png',
        'bio': 'Penikmat manhwa aksi & fantasi. Baca sambil ngopi ☕',
        'createdAt': '2024-01-15T00:00:00Z',
        'favoriteCount': 128,
        'readCount': 3420,
        'commentCount': 57,
      });

  AppUser? _user;
  String? _token;

  AppUser? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  /// Token untuk header `Authorization: Bearer <token>` pada request lain.
  String? get token => _token;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}/api/auth$path');

  Map<String, dynamic> _decode(String body) {
    try {
      final data = jsonDecode(body);
      return data is Map<String, dynamic> ? data : {};
    } catch (_) {
      return {};
    }
  }

  static const _networkError =
      'Tidak dapat terhubung ke server. Pastikan backend sudah berjalan.';

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  Future<String?> login(
    String emailOrUsername,
    String password, {
    bool remember = true,
  }) async {
    final input = emailOrUsername.trim();
    if (input.isEmpty || password.isEmpty) {
      return 'Email/username dan password wajib diisi';
    }

    if (ApiConfig.useDummyAuth) {
      return _dummyLogin(input, password, remember);
    }

    try {
      final res = await http
          .post(
            _uri('/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': input,
              'password': password,
              'remember': remember,
            }),
          )
          .timeout(_timeout);

      final body = _decode(res.body);
      if (res.statusCode == 200 && body['user'] is Map<String, dynamic>) {
        _token = body['token'] as String?;
        _user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
        await _saveToken(remember);
        return null;
      }
      return body['message'] as String? ??
          'Terjadi kesalahan (kode ${res.statusCode})';
    } on TimeoutException {
      return 'Server tidak merespons. Coba lagi.';
    } catch (_) {
      return _networkError;
    }
  }

  /// Mendaftarkan akun baru lalu langsung masuk. Null jika berhasil.
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (ApiConfig.useDummyAuth) {
      return 'Pendaftaran belum tersedia pada versi demo.';
    }
    try {
      final res = await http
          .post(
            _uri('/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      final body = _decode(res.body);
      if (res.statusCode == 201 && body['user'] is Map<String, dynamic>) {
        _token = body['token'] as String?;
        _user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
        await _saveToken(true);
        return null;
      }
      return body['message'] as String? ??
          'Terjadi kesalahan (kode ${res.statusCode})';
    } on TimeoutException {
      return 'Server tidak merespons. Coba lagi.';
    } catch (_) {
      return _networkError;
    }
  }

  /// Dipanggil saat aplikasi dibuka: masuk otomatis jika ada token tersimpan
  /// ("Ingat info masuk saya") yang masih berlaku. True jika berhasil.
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_tokenKey);
      if (saved == null || saved.isEmpty) return false;

      if (ApiConfig.useDummyAuth) {
        if (saved != _dummyToken) return false;
        _token = saved;
        _user = _buildDummyUser();
        return true;
      }

      final res = await http.get(
        _uri('/me'),
        headers: {'Authorization': 'Bearer $saved'},
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final body = _decode(res.body);
        if (body['user'] is Map<String, dynamic>) {
          _token = saved;
          _user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
          return true;
        }
      } else if (res.statusCode == 401) {
        await prefs.remove(_tokenKey); // token kedaluwarsa / tidak valid
      }
    } catch (_) {
      // server tidak terjangkau -> tampilkan halaman login (token tetap disimpan)
    }
    return false;
  }

  void logout() {
    _user = null;
    _token = null;
    _clearSavedToken();
  }

  // ---------------- mode demo ----------------
  Future<String?> _dummyLogin(
      String input, String password, bool remember) async {
    await Future.delayed(const Duration(milliseconds: 400)); // terasa seperti API
    final match = input.toLowerCase() == _dummyUsername ||
        input.toLowerCase() == _dummyEmail;
    if (!match || password != _dummyPassword) {
      return 'Email/username atau password salah';
    }
    _token = _dummyToken;
    _user = _buildDummyUser();
    await _saveToken(remember);
    return null;
  }

  // ---------------- penyimpanan token ----------------
  Future<void> _saveToken(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember && _token != null) {
      await prefs.setString(_tokenKey, _token!);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Future<void> _clearSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}