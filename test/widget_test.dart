import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_page/controller/auth_controller.dart';
import 'package:login_page/main.dart';

void main() {
  testWidgets('Login page menampilkan form dengan benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(startLoggedIn: false, authController: AuthController()),
    );

    // Halaman login muncul
    expect(find.text('Selamat Datang Kembali'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // Ada field email/username & password
    expect(find.byType(TextField), findsNWidgets(2));

    // Submit form kosong -> muncul pesan error (tanpa memanggil server,
    // karena validasi dilakukan di AuthController sebelum request)
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email/username dan password wajib diisi'),
        findsOneWidget);
  });
}