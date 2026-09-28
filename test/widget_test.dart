import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login_page/main.dart';

void main() {
  testWidgets('Login page menampilkan form dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verifikasi halaman login muncul
    expect(find.text('Genshin Team Builder'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);

    // Verifikasi ada field username & password
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Coba submit form kosong -> harus muncul pesan validasi
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Wajib diisi'), findsOneWidget);
  });
}