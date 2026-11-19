// lib/config.dart
//
// Pengaturan koneksi backend.
//
// MODE DATABASE (default, untuk pengembangan lokal):
//   flutter run
//   -> login diperiksa ke backend Express + MySQL.
//
// MODE DEMO (untuk versi hosting tanpa backend):
//   flutter build web --dart-define=USE_DUMMY_AUTH=true
//   -> login memakai akun demo bawaan, tanpa server/database.
//
// Alamat backend (mode database):
//  - Web / Windows / iOS Simulator : http://localhost:3000
//  - Android Emulator              : http://10.0.2.2:3000
//  - HP fisik / server online      : --dart-define=API_URL=http://IP-ATAU-DOMAIN:3000

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// true jika di-build dengan --dart-define=USE_DUMMY_AUTH=true
  static const bool useDummyAuth = bool.fromEnvironment('USE_DUMMY_AUTH');

  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}