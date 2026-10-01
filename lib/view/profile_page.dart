// lib/views/profile_page.dart
//
// VIEW: halaman profil. Membaca data AppUser (Model) lewat getter dari
// AuthController (Controller) — tidak pernah menulis data langsung di View.

import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../controller/library_controller.dart';
import '../model/user_model.dart';
import '../theme.dart';
import 'login_page.dart';
import 'history_page.dart';
import 'favorites_page.dart';

class ProfilePage extends StatelessWidget {
  final AuthController authController;
  const ProfilePage({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = authController.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Belum login', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, user),
          ListenableBuilder(
            listenable: LibraryController.instance,
            builder: (context, _) => _buildStats(user),
          ),
          const SizedBox(height: 20),
          _buildMenuSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  // Avatar & identitas ditaruh langsung di dalam area gradient (tidak lagi
  // dibuat overlap keluar dengan Positioned+Stack), supaya tidak ada
  // ruang gradient kosong yang berlebihan di bawah tombol back/settings.
  Widget _buildHeader(BuildContext context, AppUser user) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: CircleAvatar(
                      radius: 31,
                      backgroundColor: AppColors.surface,
                      backgroundImage: AssetImage(user.avatarUrl),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.username,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(user.email,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  user.bio,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                      height: 1.4),
                ),
              ],
              const SizedBox(height: 6),
              Text(user.joinDate,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- STATS ----------------
  // Baris statistik dibuat menyatu dengan latar (tanpa kartu bulat
  // berbayang terpisah) supaya tidak terasa seperti "kartu di dalam kartu".
  Widget _buildStats(AppUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _statItem('Favorit', LibraryController.instance.favoriteCount.toString(),
              Icons.favorite_rounded, AppColors.accentPink),
          _divider(),
          _statItem('Dibaca', LibraryController.instance.historyCount.toString(),
              Icons.menu_book_rounded, AppColors.primaryLight),
          _divider(),
          _statItem('Komentar', user.commentCount.toString(),
              Icons.chat_bubble_rounded, AppColors.gold),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 34, color: AppColors.border);

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  // ---------------- MENU ----------------
  // Ikon tidak lagi dibungkus kotak berwarna-warni per baris (efek
  // "candy") — cukup satu warna netral, kecuali item "Keluar" yang
  // memang perlu menonjol sebagai aksi destruktif.
  Widget _buildMenuSection(BuildContext context) {
    final items = [
      _MenuData(Icons.download_rounded, 'Unduhan'),
      _MenuData(Icons.notifications_none_rounded, 'Notifikasi'),
      _MenuData(Icons.settings_outlined, 'Pengaturan Akun'),
      _MenuData(Icons.help_outline_rounded, 'Bantuan'),
    ];

    return Column(
      children: [
        _menuTile(
          _MenuData(Icons.history_rounded, 'Riwayat Baca'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HistoryPage())),
        ),
        _menuTile(
          _MenuData(Icons.bookmark_rounded, 'Komik Favorit'),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FavoritesPage())),
        ),
        for (int i = 0; i < items.length; i++) _menuTile(items[i]),
        _menuTile(
          _MenuData(Icons.logout_rounded, 'Keluar', color: Colors.redAccent),
          onTap: () {
            authController.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _menuTile(_MenuData data, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Icon(data.icon, color: data.color ?? AppColors.textSecondary, size: 22),
      title: Text(data.label,
          style: TextStyle(
              color: data.color ?? Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String label;
  final Color? color;
  _MenuData(this.icon, this.label, {this.color});
}