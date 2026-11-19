import 'package:flutter/material.dart';
import 'theme.dart';
import 'controller/auth_controller.dart';
import 'controller/library_controller.dart';
import 'view/home_page.dart';
import 'view/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibraryController.instance.load();

  // Masuk otomatis jika ada sesi tersimpan yang masih berlaku.
  final auth = AuthController();
  final loggedIn = await auth.restoreSession();

  runApp(MyApp(startLoggedIn: loggedIn, authController: auth));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;
  final AuthController authController;

  const MyApp({
    super.key,
    required this.startLoggedIn,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacain - Baca Manhwa, Manga & Manhua',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: AppScrollBehavior(),
      home: startLoggedIn
          ? HomePage(authController: authController)
          : const LoginPage(),
    );
  }
}