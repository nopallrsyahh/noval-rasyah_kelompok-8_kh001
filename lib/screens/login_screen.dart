import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_helper.dart';
import '../services/google_auth_service.dart';
import '../utils/app_routes.dart';
import '../utils/session_manager.dart';
import 'admin_dashboard_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const String _adminEmail = 'admin@libraryku.com';
  static const String _adminPassword = 'admin123';

  static const Color kPrimaryPurple = Color(0xFF5546E8);
  static const Color kNavy = Color(0xFF18213F);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kInputFill = Color(0xFFF1F3F9);
  static const Color kPrimaryText = Color(0xFF17213A);
  static const Color kSecondaryText = Color(0xFF7B849B);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();

    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _busy => _isLoading || _isGoogleLoading;

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor:
        isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    try {
      if (email == _adminEmail && password == _adminPassword) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
        return;
      }

      final user = await DatabaseHelper.instance.loginUser(email, password);
      if (!mounted) return;

      if (user != null) {
        await SessionManager.saveSession(user.id!, user.name);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        _showMessage('Email atau password tidak sesuai.');
      }
    } catch (e) {
      _showMessage('Gagal memproses login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    try {
      final success = await GoogleAuthService.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      _showMessage('Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Untuk mengatur ulang kata sandi akun lokal LibraryKu, silakan hubungi pustakawan/admin atau masuk langsung menggunakan akun Google.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: kSecondaryText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryPurple,
                  foregroundColor: kWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kPrimaryPurple,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. HEADER SECTION (Gaya Jobsly dengan Top Bar + Brand Center)
                    _buildHeader(),

                    // 2. BOTTOM SHEET WHITE CONTAINER
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Selamat Datang Kembali!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Masuk untuk melanjutkan membaca koleksi favoritmu',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kSecondaryText,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Input Email
                                  _buildFieldLabel('Alamat Email'),
                                  const SizedBox(height: 7),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    enabled: !_busy,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) =>
                                        _passwordFocus.requestFocus(),
                                    style: const TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'nama@email.com',
                                      prefixIcon: Icons.email_outlined,
                                      isFocused: _emailFocus.hasFocus,
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty) return 'Email wajib diisi';
                                      if (!v.contains('@')) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Input Password
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildFieldLabel('Password'),
                                      GestureDetector(
                                        onTap: _busy
                                            ? null
                                            : _showForgotPasswordSheet,
                                        child: const Text(
                                          'Lupa Password?',
                                          style: TextStyle(
                                            color: kPrimaryPurple,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    enabled: !_busy,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _login(),
                                    style: const TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Masukkan password Anda',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      isFocused: _passwordFocus.hasFocus,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _passwordFocus.hasFocus
                                              ? kPrimaryPurple
                                              : kSecondaryText,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                        _obscurePassword =
                                        !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 26),

                                  // Tombol Primary Login
                                  _buildLoginButton(),
                                  const SizedBox(height: 22),

                                  // Divider "atau masuk dengan"
                                  _buildOrDivider('atau masuk dengan'),
                                  const SizedBox(height: 18),

                                  // Tombol Google Sign-In
                                  _buildGoogleButton(
                                      label: 'Masuk dengan Google'),

                                  const Spacer(),
                                  const SizedBox(height: 20),

                                  // Footer
                                  Text(
                                    '© 2026 LibraryKu • Perpustakaan Digital',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kSecondaryText.withOpacity(0.75),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background Foto Rak Buku Lokal
        Positioned.fill(
          child: Image.asset(
            'assets/images/perpustakaan.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kNavy),
          ),
        ),
        // Gradient Overlay Navy & Ungu
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kNavy.withOpacity(0.88),
                  const Color(0xFF2B246D).withOpacity(0.90),
                  kPrimaryPurple.withOpacity(0.88),
                ],
              ),
            ),
          ),
        ),
        // Konten Header
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
            child: Column(
              children: [
                // Top Action Bar ala Jobsly: "Belum punya akun? [Daftar]"
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        color: kWhite.withOpacity(0.88),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: kWhite.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: _busy
                            ? null
                            : () => Navigator.pushNamed(
                            context, AppRoutes.register),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kWhite.withOpacity(0.22),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Brand Center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kWhite.withOpacity(0.24),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: kWhite,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'LibraryKu',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Perpustakaan digital di genggamanmu',
                  style: TextStyle(
                    color: kWhite.withOpacity(0.85),
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: kPrimaryText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isFocused,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: kSecondaryText.withOpacity(0.75),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: isFocused ? kWhite : kInputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      prefixIcon: Icon(
        prefixIcon,
        color: isFocused ? kPrimaryPurple : kSecondaryText,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: kSecondaryText.withOpacity(0.14),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryPurple, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.6),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFD32F2F),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: (_) {
        if (!_busy) setState(() => _isButtonPressed = true);
      },
      onTapUp: (_) {
        if (!_busy) setState(() => _isButtonPressed = false);
      },
      onTapCancel: () {
        if (!_busy) setState(() => _isButtonPressed = false);
      },
      child: AnimatedScale(
        scale: _isButtonPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryPurple,
              disabledBackgroundColor: kPrimaryPurple.withOpacity(0.55),
              foregroundColor: kWhite,
              elevation: _busy ? 0 : 4,
              shadowColor: kPrimaryPurple.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(kWhite),
              ),
            )
                : const Text(
              'Masuk',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: kSecondaryText.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: TextStyle(
              color: kSecondaryText.withOpacity(0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: kSecondaryText.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton({required String label}) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _busy ? null : _loginWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: kWhite,
          foregroundColor: kPrimaryText,
          side: BorderSide(
            color: kSecondaryText.withOpacity(0.24),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryPurple),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleGLogo(size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: kPrimaryText,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo 'G' Google 4 warna tanpa butuh file aset eksternal
class _GoogleGLogo extends StatelessWidget {
  final double size;
  const _GoogleGLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = w * 0.42;
    final double strokeWidth = w * 0.18;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Merah (atas)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.75, false, paint);

    // Kuning (kiri)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.55, 1.33, false, paint);

    // Hijau (bawah)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.85, 1.7, false, paint);

    // Biru (kanan)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.1, 0.95, false, paint);

    // Garis horizontal huruf G
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth / 2,
        radius + strokeWidth / 2,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}