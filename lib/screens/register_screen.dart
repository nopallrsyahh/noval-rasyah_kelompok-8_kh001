import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/google_auth_service.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const Color kPrimaryPurple = Color(0xFF5546E8);
  static const Color kNavy = Color(0xFF18213F);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kInputFill = Color(0xFFF1F3F9);
  static const Color kPrimaryText = Color(0xFF17213A);
  static const Color kSecondaryText = Color(0xFF7B849B);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonPressed = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.transparent;

  late final AnimationController _entryAnimController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimController,
      curve: Curves.easeOutCubic,
    ));
    _entryAnimController.forward();

    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _entryAnimController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  bool get _busy => _isLoading || _isGoogleLoading;

  void _showMessage(String message, {bool isError = false}) {
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

  void _evaluatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthLabel = '';
        _passwordStrengthColor = Colors.transparent;
      });
      return;
    }

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9!@#\$&*~%^()_\-+=]').hasMatch(password)) score++;

    setState(() {
      switch (score) {
        case 0:
        case 1:
          _passwordStrength = 0.25;
          _passwordStrengthLabel = 'Lemah';
          _passwordStrengthColor = const Color(0xFFE53935);
          break;
        case 2:
          _passwordStrength = 0.50;
          _passwordStrengthLabel = 'Cukup';
          _passwordStrengthColor = const Color(0xFFFB8C00);
          break;
        case 3:
          _passwordStrength = 0.75;
          _passwordStrengthLabel = 'Kuat';
          _passwordStrengthColor = const Color(0xFF1E88E5);
          break;
        default:
          _passwordStrength = 1.0;
          _passwordStrengthLabel = 'Sangat Kuat';
          _passwordStrengthColor = const Color(0xFF2E7D32);
      }
    });
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    try {
      await DatabaseHelper.instance.registerUser(
        UserModel(name: name, email: email, password: password),
      );
      if (!mounted) return;
      _showMessage('Registrasi berhasil, silakan login.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('UNIQUE')) {
        _showMessage('Email sudah terdaftar.', isError: true);
      } else {
        _showMessage('Registrasi gagal: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    try {
      final success = await GoogleAuthService.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
        );
      }
    } catch (e) {
      _showMessage('Daftar dengan Google gagal: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
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
                    // 1. HEADER SECTION (Gaya Jobsly)
                    _buildHeader(),

                    // 2. BOTTOM SHEET WHITE FORM CONTAINER
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
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Mulai Gratis Sekarang.',
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
                                    'Buat akun dan jelajahi ribuan koleksi buku digital',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kSecondaryText,
                                      fontSize: 13.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // Nama Lengkap
                                  _buildFieldLabel('Nama Lengkap'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    focusNode: _nameFocus,
                                    enabled: !_busy,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                    TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Masukkan nama lengkap Anda',
                                      prefixIcon: Icons.person_outline_rounded,
                                      isFocused: _nameFocus.hasFocus,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nama lengkap wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Email
                                  _buildFieldLabel('Alamat Email'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    enabled: !_busy,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
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
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email wajib diisi';
                                      }
                                      if (!RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                          .hasMatch(
                                          value.trim().toLowerCase())) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  _buildFieldLabel('Password'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    enabled: !_busy,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Minimal 6 karakter',
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
                                      if (value.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_passwordController.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildPasswordStrengthIndicator(),
                                  ],
                                  const SizedBox(height: 14),

                                  // Konfirmasi Password
                                  _buildFieldLabel('Konfirmasi Password'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocus,
                                    enabled: !_busy,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _register(),
                                    style: const TextStyle(
                                      color: kPrimaryText,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Ulangi password Anda',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      isFocused:
                                      _confirmPasswordFocus.hasFocus,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _confirmPasswordFocus.hasFocus
                                              ? kPrimaryPurple
                                              : kSecondaryText,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                        _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi password wajib diisi';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Konfirmasi password tidak cocok';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 22),

                                  // Tombol Daftar Utama
                                  _buildSubmitButton(),
                                  const SizedBox(height: 18),

                                  // Divider "atau daftar dengan"
                                  _buildOrDivider('atau daftar dengan'),
                                  const SizedBox(height: 16),

                                  // Tombol Daftar dengan Google
                                  _buildGoogleButton(),
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
        Positioned.fill(
          child: Image.asset(
            'assets/images/perpustakaan.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kNavy),
          ),
        ),
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
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              children: [
                // Top Action Bar ala Jobsly: "[<]   Sudah punya akun? [Masuk]"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: kWhite.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        onTap: _busy ? null : () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: kWhite.withOpacity(0.22),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: kWhite,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                            color: kWhite.withOpacity(0.88),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: kWhite.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _busy ? null : () => Navigator.pop(context),
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
                                'Masuk',
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
                  ],
                ),
                const SizedBox(height: 18),

                // Brand Center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: kWhite.withOpacity(0.24),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: kWhite,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'LibraryKu',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final threshold = (index + 1) * 0.25;
            final isActive = _passwordStrength >= threshold;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? _passwordStrengthColor
                      : kSecondaryText.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kekuatan password',
              style: TextStyle(
                color: kSecondaryText.withOpacity(0.85),
                fontSize: 11.5,
              ),
            ),
            Text(
              _passwordStrengthLabel,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
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
            onPressed: _busy ? null : _register,
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
              'Buat Akun',
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

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _busy ? null : _registerWithGoogle,
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
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleGLogo(size: 20),
            SizedBox(width: 12),
            Text(
              'Daftar dengan Google',
              style: TextStyle(
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

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.75, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.55, 1.33, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.85, 1.7, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.1, 0.95, false, paint);

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