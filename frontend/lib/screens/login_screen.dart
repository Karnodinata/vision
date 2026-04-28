import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isObscure = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // ── Warm Aqua Palette ───────────────────────────────────────────────────
  static const _teal50  = Color(0xFFEFFCF9);
  static const _teal100 = Color(0xFFCCF5EC);
  static const _teal400 = Color(0xFF2CB89E);
  static const _teal500 = Color(0xFF14A085);
  static const _teal600 = Color(0xFF0E8A72);
  static const _teal700 = Color(0xFF0A6E5B);
  static const _slate50 = Color(0xFFF8FAFB);
  static const _slate100 = Color(0xFFF1F5F9);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate400 = Color(0xFF94A3B8);
  static const _slate600 = Color(0xFF475569);
  static const _slate800 = Color(0xFF1E293B);

  // ── Animation Controllers ────────────────────────────────────────────────
  late AnimationController _masterFadeController;
  late AnimationController _scanController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _shakeController;
  late AnimationController _logoRevealController;
  late AnimationController _cardSlideController;
  late AnimationController _blobMorphController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _shakeAnimation;

  // Staggered reveal animations
  late Animation<Offset> _logoSlideAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<double> _footerFadeAnim;

  // Blob morph animation
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();

    // Focus listeners
    _emailFocusNode.addListener(() {
      setState(() => _emailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });

    // Master fade (overall screen)
    _masterFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _masterFadeController,
      curve: Curves.easeOut,
    );

    // Scan line
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    );

    // Float
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Shimmer on button
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    );

    // Shake (for error feedback)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Logo staggered reveal
    _logoRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoRevealController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));
    _logoFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoRevealController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Card staggered reveal
    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardSlideController,
      curve: Curves.easeOutCubic,
    ));
    _cardFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardSlideController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _footerFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardSlideController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Blob morph
    _blobMorphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _blobAnim = CurvedAnimation(
      parent: _blobMorphController,
      curve: Curves.easeInOut,
    );

    // Start staggered sequence
    _masterFadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoRevealController.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _cardSlideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _masterFadeController.dispose();
    _scanController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _shakeController.dispose();
    _logoRevealController.dispose();
    _cardSlideController.dispose();
    _blobMorphController.dispose();
    super.dispose();
  }

  // ── Login logic — UNCHANGED ───────────────────────────────────────────────
  Future<void> _handleLogin() async {
    String rawEmail = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (rawEmail.isEmpty || password.isEmpty) {
      // Shake animation for empty fields
      _shakeController.forward(from: 0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email/Username dan password tidak boleh kosong!',
            style: TextStyle(color: Color(0xFF0F172A)),
          ),
          backgroundColor: const Color(0xFFFEF9C3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    String finalEmail = rawEmail;
    if (!rawEmail.contains('@')) {
      finalEmail = '$rawEmail@gmail.com';
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(finalEmail, password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Otentikasi berhasil. Mengakses sistem...',
            style: TextStyle(color: Color(0xFF0D3D33)),
          ),
          backgroundColor: const Color(0xFFD0F5EE),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFE63946),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      body: Stack(
        children: [
          // Animated morphing background blobs
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (context, _) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _OrganicBlobPainter(morphT: _blobAnim.value),
                ),
              );
            },
          ),

          // Noise texture overlay
          Positioned.fill(
            child: CustomPaint(painter: _NoisePainter()),
          ),

          // Floating accent circles
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) {
              final t = _floatController.value;
              return Stack(
                children: [
                  Positioned(
                    top: 70 + (t * 22),
                    right: 24 + (t * 10),
                    child: _GlowBubble(size: 72, color: _teal400, opacity: 0.10),
                  ),
                  Positioned(
                    top: 180 - (t * 16),
                    left: 14 + (t * 12),
                    child: _GlowBubble(size: 44, color: _teal500, opacity: 0.07),
                  ),
                  Positioned(
                    bottom: 160 + (t * 24),
                    right: 44 - (t * 8),
                    child: _GlowBubble(size: 60, color: _teal100, opacity: 0.55),
                  ),
                  Positioned(
                    bottom: 90 - (t * 14),
                    left: 54 + (t * 18),
                    child: _GlowBubble(size: 36, color: _teal400, opacity: 0.08),
                  ),
                  // Extra decorative rings
                  Positioned(
                    top: 130 + (t * 10),
                    right: 80 - (t * 5),
                    child: _RingBubble(size: 90, color: _teal400),
                  ),
                  Positioned(
                    bottom: 230 - (t * 8),
                    left: 30 + (t * 6),
                    child: _RingBubble(size: 56, color: _teal600),
                  ),
                ],
              );
            },
          ),

          // Scan line (more refined)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, _) {
              final screenHeight = MediaQuery.of(context).size.height;
              return Positioned(
                top: _scanAnimation.value * screenHeight,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      height: 1.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _teal400.withOpacity(0.04),
                            _teal400.withOpacity(0.10),
                            _teal400.withOpacity(0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _teal400.withOpacity(0.015),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SlideTransition(
                        position: _logoSlideAnim,
                        child: FadeTransition(
                          opacity: _logoFadeAnim,
                          child: _buildHeader(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SlideTransition(
                        position: _cardSlideAnim,
                        child: FadeTransition(
                          opacity: _cardFadeAnim,
                          child: AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              final shakeOffset = _shakeController.isAnimating
                                  ? math.sin(_shakeAnimation.value * math.pi * 5) * 8.0
                                  : 0.0;
                              return Transform.translate(
                                offset: Offset(shakeOffset, 0),
                                child: child,
                              );
                            },
                            child: _buildFormCard(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _footerFadeAnim,
                        child: _buildFooter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.035);
            final glowRadius = 28.0 + (_pulseController.value * 14.0);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 82 + glowRadius,
                  height: 82 + glowRadius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _teal400.withOpacity(0.08 + _pulseController.value * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Mid glow ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _teal500.withOpacity(0.06 + _pulseController.value * 0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ],
            );
          },
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [_teal400, _teal600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _teal500.withOpacity(0.38),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: _teal400.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shine overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 41,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Inner decorative ring
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.22),
                      width: 1.5,
                    ),
                  ),
                ),
                const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 34),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),

        // App Name with letter spacing reveal feel
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_slate800, _teal700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'VISION',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle with decorative lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _decorLine(reverse: true),
            const SizedBox(width: 14),
            const Text(
              'Monitoring Empang Lele',
              style: TextStyle(
                fontSize: 12.5,
                color: _slate400,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 14),
            _decorLine(reverse: false),
          ],
        ),
      ],
    );
  }

  Widget _decorLine({bool reverse = false}) {
    return Container(
      width: 30,
      height: 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        gradient: LinearGradient(
          begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
          end: reverse ? Alignment.centerLeft : Alignment.centerRight,
          colors: [_teal400.withOpacity(0.6), _teal400.withOpacity(0.0)],
        ),
      ),
    );
  }

  // ── Form Card ──────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: _slate200.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: _teal500.withOpacity(0.07),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          // Inner light top
          const BoxShadow(
            color: Colors.white,
            blurRadius: 0,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card top accent stripe — animated shimmer
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, _) {
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [_teal400, _teal600, _teal700],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          alignment: Alignment(
                            -1.5 + (_shimmerAnimation.value * 3.5),
                            0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.45),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  const Text(
                    'Masuk ke Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _slate800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Silakan masukkan kredensial Anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: _slate400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Email / Username field
                  _buildAnimatedLabel('Username atau Email', _emailFocused),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    hint: 'contoh@email.com',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    isFocused: _emailFocused,
                  ),
                  const SizedBox(height: 18),

                  // Password field
                  _buildAnimatedLabel('Password', _passwordFocused),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _isObscure,
                    isFocused: _passwordFocused,
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _isObscure = !_isObscure),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            _isObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey(_isObscure),
                            color: _passwordFocused ? _teal500 : _slate400,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: _isLoading
                        ? _buildLoadingButton()
                        : _buildSubmitButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLabel(String text, bool focused) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: focused ? _teal600 : _slate600,
      ),
      child: Text(text),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    bool isFocused = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _teal400.withOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: _slate800,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _teal500,
        cursorWidth: 1.8,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _slate400.withOpacity(0.55),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: isFocused ? _teal50.withOpacity(0.7) : _slate100,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isFocused ? _teal500 : _slate400,
                size: 20,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: _slate200.withOpacity(0.8),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _teal400, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      key: const ValueKey('loading'),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _teal100,
        border: Border.all(color: _teal400.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(_teal500),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Mengautentikasi...',
            style: TextStyle(
              color: _teal600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _PressableButton(
      key: const ValueKey('submit'),
      onTap: _handleLogin,
      shimmerAnimation: _shimmerAnimation,
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing status dot
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 14 + (_pulseController.value * 6),
                      height: 14 + (_pulseController.value * 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _teal400.withOpacity(
                            0.15 * (1 - _pulseController.value)),
                      ),
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _teal400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              'Sistem Aktif  ·  v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: _slate400.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Pressable button with spring + shimmer ────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final VoidCallback onTap;
  final Animation<double> shimmerAnimation;

  const _PressableButton({
    super.key,
    required this.onTap,
    required this.shimmerAnimation,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  static const _teal500 = Color(0xFF14A085);
  static const _teal600 = Color(0xFF0E8A72);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_teal500, _teal600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _teal500.withOpacity(0.38),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: _teal500.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Shimmer sweep
              AnimatedBuilder(
                animation: widget.shimmerAnimation,
                builder: (context, _) {
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: 0.45,
                      alignment: Alignment(
                        -2.0 + (widget.shimmerAnimation.value * 4.5),
                        0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Top shine
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Label
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glow bubble widget ────────────────────────────────────────────────────────
class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowBubble({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.5),
            blurRadius: size * 0.6,
            spreadRadius: -size * 0.1,
          ),
        ],
      ),
    );
  }
}

// ── Ring bubble widget ────────────────────────────────────────────────────────
class _RingBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _RingBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.08),
          width: 1.2,
        ),
      ),
    );
  }
}

// ── Organic blob background painter (morphing) ───────────────────────────────
class _OrganicBlobPainter extends CustomPainter {
  final double morphT;

  const _OrganicBlobPainter({this.morphT = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Top-right warm blob — morphs shape
    final p1 = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 1.0,
        colors: [
          const Color(0xFF2CB89E).withOpacity(0.12),
          const Color(0xFF2CB89E).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final ctrlX1 = size.width * (1.05 + morphT * 0.08);
    final ctrlY1 = size.height * (0.04 + morphT * 0.06);
    final endX1 = size.width * (1.0 + morphT * 0.02);
    final endY1 = size.height * (0.30 + morphT * 0.05);

    final path1 = Path()
      ..moveTo(size.width * 0.50, 0)
      ..quadraticBezierTo(ctrlX1, ctrlY1, endX1, endY1)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path1, p1);

    // Bottom-left blob — morphs
    final p2 = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomLeft,
        radius: 1.3,
        colors: [
          const Color(0xFF2CB89E).withOpacity(0.09),
          const Color(0xFF2CB89E).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final ctrlX2 = size.width * (0.18 + morphT * 0.06);
    final ctrlY2 = size.height * (1.06 + morphT * 0.04);
    final endX2 = size.width * (0.52 + morphT * 0.06);

    final path2 = Path()
      ..moveTo(0, size.height * (0.70 - morphT * 0.04))
      ..quadraticBezierTo(ctrlX2, ctrlY2, endX2, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, p2);

    // Center-right accent blob (new)
    final p3 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, 0.0),
        radius: 0.8,
        colors: [
          const Color(0xFF14A085).withOpacity(0.05 + morphT * 0.02),
          const Color(0xFF14A085).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path3 = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * (0.78 + morphT * 0.04),
            size.height * (0.42 - morphT * 0.06)),
        width: size.width * 0.55,
        height: size.height * 0.30,
      ));
    canvas.drawPath(path3, p3);

    // Dot grid — very subtle
    final dotPaint = Paint()
      ..color = const Color(0xFF2CB89E).withOpacity(0.028);
    const spacing = 32.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrganicBlobPainter oldDelegate) =>
      oldDelegate.morphT != morphT;
}

// ── Noise texture painter ────────────────────────────────────────────────────
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final noisePaint = Paint()..color = Colors.black.withOpacity(0.012);
    for (int i = 0; i < 1800; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}