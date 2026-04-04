import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'dragon_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
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
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authResponse.token);

        final dragonResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/dragon'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${authResponse.token}',
          },
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (dragonResponse.statusCode == 200) {
          // Dragon exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                user: authResponse.user,
                token: authResponse.token,
              ),
            ),
          );
        } else {
          // No dragon or error, go to dragon selection screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DragonSelectionScreen(
                user: authResponse.user,
                token: authResponse.token,
              ),
            ),
          );
        }

      } else {
        final body = jsonDecode(response.body);
        setState(() {
          _errorMessage = body['error'] ?? 'Login failed. Please try again.';
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
            child: _buildForm(),
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
            'Welcome Back',
            style: GoogleFonts.medievalSharp(
              fontSize: 32,
              color: AppColors.onBackground,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Continue your adventure.',
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
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
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
                    'Login',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 17,
                      letterSpacing: 1.2,
                      color: AppColors.onPrimary,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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
