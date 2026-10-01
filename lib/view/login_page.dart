// lib/view/login_page.dart
//
// VIEW: halaman login. Memanggil AuthController (Controller) untuk
// memvalidasi input, tidak pernah mengakses "database" secara langsung.
//
// Desain: konsep split-panel (foto + teks di kiri, form di kanan).
// Palet warna memakai AppColors (dark + aksen ungu BACAIN).
// Panel foto hanya tampil di layar lebar; di HP tetap 1 kolom.

import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../theme.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authController = AuthController();
  final _idCtrl = TextEditingController(text: 'senkuu');
  final _passCtrl = TextEditingController(text: '123456');

  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = true;
  String? _error;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600)); // simulasi API
    if (!mounted) return;

    final result = _authController.login(_idCtrl.text, _passCtrl.text);
    setState(() => _loading = false);

    if (result != null) {
      setState(() => _error = result);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(authController: _authController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return isWide ? _buildWideLayout() : _buildNarrowLayout();
          },
        ),
      ),
    );
  }

  // ---------------- LAYOUTS ----------------
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildImagePanel()),
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: _buildFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            _logo(centered: true),
            const SizedBox(height: 28),
            _buildFormContent(),
          ],
        ),
      ),
    );
  }

  // ---------------- PANEL FOTO (layar lebar) ----------------
  Widget _buildImagePanel() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/Yaemiko.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: AppColors.surfaceLight),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.10),
                AppColors.background.withValues(alpha: 0.55),
                AppColors.background.withValues(alpha: 0.95),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(top: 32, left: 40, child: _logo(centered: false)),
        Positioned(
          left: 40,
          right: 40,
          bottom: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.primaryLight,
                      size: 15,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'PLATFORM BACA DIGITAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Judul utama
              const Text(
                'Temukan cerita favoritmu.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Deskripsi
              Text(
                'Baca manhwa, manga, dan novel ringan pilihan dalam satu tempat.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              // Info kecil
              Row(
                children: [
                  _infoItem(Icons.menu_book_rounded, 'Manhwa'),
                  const SizedBox(width: 18),
                  _infoItem(Icons.auto_stories_rounded, 'Manga'),
                  const SizedBox(width: 18),
                  _infoItem(Icons.bookmark_rounded, 'Novel'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- FORM ----------------
  Widget _buildFormContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat Datang Kembali',
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masuk untuk lanjut baca manhwa favoritmu tanpa batas.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),

          _label('Email atau Username'),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _idCtrl,
            hint: 'senkuu@baca.in',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),

          _label('Password'),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              child: const Text('Lupa password?',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
            ),
          ),

          Row(
            children: [
              const Expanded(
                child: Text('Ingat info masuk saya',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              Switch(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v),
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                inactiveThumbColor: AppColors.textSecondary,
              ),
            ],
          ),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 6),
          _gradientButton(
            label: _loading ? 'Memproses...' : 'Masuk',
            onTap: _loading ? null : _submit,
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Text('Demo: senkuu / 123456',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),

          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('ATAU',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 0.6)),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 20),

          _googleButton(),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun? ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Daftar sekarang',
                  style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _googleButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.g_mobiledata_rounded, color: Colors.black87, size: 24),
              SizedBox(width: 4),
              Text('Lanjutkan dengan Google',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SHARED WIDGETS ----------------
  Widget _logo({required bool centered}) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/Logo.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox(width: 100, height: 100),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600));

  Widget _gradientButton({required String label, VoidCallback? onTap}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: onTap == null ? AppColors.surfaceLight : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text field dengan border yang menyala warna primary saat difokus.
class _AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  State<_AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<_AppTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.primary : AppColors.border,
          width: _focused ? 1.6 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon:
              Icon(widget.icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: widget.suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        ),
      ),
    );
  }
}