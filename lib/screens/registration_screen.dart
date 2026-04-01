import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _registered = false;
  String? _errorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _entryController;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        setState(() {
          _registered = true;
          _isLoading = false;
        });
      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage = body['error'] ?? 'Registration failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not connect to server. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: _registered ? const _DragonCarousel() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.onBackground,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Join the Guild',
            style: GoogleFonts.medievalSharp(
              fontSize: 32,
              color: AppColors.onBackground,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Create your account and hatch your dragon.',
            style: GoogleFonts.rosarivo(
              fontSize: 15,
              color: AppColors.secondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Error banner
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.rosarivo(
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.person_outline_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    final emailRegex =
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  toggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  toggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(
                    'Hatch Your Dragon',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 17,
                      letterSpacing: 1.2,
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // Footer
          Center(
            child: Text(
              'By registering you agree to the\nScrolls of Service and our Privacy Tome.',
              textAlign: TextAlign.center,
              style: GoogleFonts.rosarivo(
                fontSize: 11,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.rosarivo(
        fontSize: 15,
        color: AppColors.onBackground,
      ),
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.rosarivo(
          fontSize: 14,
          color: AppColors.muted,
          fontStyle: FontStyle.italic,
        ),
        prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
                onPressed: toggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.muted.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.7),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorStyle: GoogleFonts.rosarivo(
          fontSize: 11,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

// ── Dragon Carousel (shown after successful registration) ─────────────────────

class _DragonCarousel extends StatefulWidget {
  const _DragonCarousel();

  @override
  State<_DragonCarousel> createState() => _DragonCarouselState();
}

class _DragonCarouselState extends State<_DragonCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  static const List<_DragonSlide> _dragons = [
    _DragonSlide('dragon_red.png', 'Red Dragon', Color(0xFFCC3333)),
    _DragonSlide('dragon_blue.png', 'Blue Dragon', Color(0xFF3388CC)),
    _DragonSlide('dragon_green.png', 'Green Dragon', Color(0xFF408000)),
    _DragonSlide('dragon_gold.png', 'Gold Dragon', Color(0xFFD4AF37)),
    _DragonSlide('dragon_pink.png', 'Pink Dragon', Color(0xFFCC6699)),
    _DragonSlide('dragon_purple.png', 'Purple Dragon', Color(0xFF8844AA)),
    _DragonSlide('dragon_teal.png', 'Teal Dragon', Color(0xFF008080)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),

        // Heading
        Text(
          'Your Dragon Awaits!',
          style: GoogleFonts.medievalSharp(
            fontSize: 28,
            color: AppColors.onBackground,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Meet the legendary dragons of the realm.',
          style: GoogleFonts.rosarivo(
            fontSize: 14,
            color: AppColors.secondary,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 32),

        // PageView carousel
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _dragons.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs().clamp(0.0, 1.0);
                  }
                  final scale = 1.0 - (value * 0.15);
                  final opacity = 1.0 - (value * 0.4);

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: _DragonCard(dragon: _dragons[index]),
              );
            },
          ),
        ),

        // Dot indicators
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_dragons.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? _dragons[_currentPage].color
                      : AppColors.muted.withValues(alpha: 0.35),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _DragonSlide {
  final String asset;
  final String name;
  final Color color;
  const _DragonSlide(this.asset, this.name, this.color);
}

class _DragonCard extends StatelessWidget {
  final _DragonSlide dragon;
  const _DragonCard({required this.dragon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dragon.color.withValues(alpha: 0.4)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dragon.color.withValues(alpha: 0.12),
            AppColors.surface,
            AppColors.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: dragon.color.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dragon image
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dragon.color.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/${dragon.asset}',
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Dragon name
          Text(
            dragon.name,
            style: GoogleFonts.medievalSharp(
              fontSize: 22,
              color: dragon.color,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'A companion for your journey',
            style: GoogleFonts.rosarivo(
              fontSize: 13,
              color: AppColors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
