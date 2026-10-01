import 'package:flutter/material.dart';
import 'theme.dart';
import 'view/login_page.dart';
import 'controller/library_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibraryController.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacain - Baca Manhwa, Manga & Manhua',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: AppScrollBehavior(),
      home: const LoginPage(),
    );
  }
}