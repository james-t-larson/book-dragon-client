import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'dragon_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final AnimationController _glowController;
  late final Animation<double> _breatheAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _checkAuthStatus();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Simulate some extra loading time for the beautiful splash
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        _navigateToWelcome();
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final user = User.fromJson(body);

        if (user.dragonId == null || user.dragonId == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DragonSelectionScreen(user: user, token: token),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: user, token: token),
            ),
          );
        }
      } else {
        await prefs.remove('auth_token');
        if (!mounted) return;
        _navigateToWelcome();
      }
    } catch (e) {
      if (!mounted) return;
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.surface,
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Glow behind dragon
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shimmer.withValues(
                                alpha: _glowAnimation.value,
                              ),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Scaling Dragon
                  Transform.translate(
                    offset: const Offset(0, -100), // Adjust glow position
                    child: Center(
                      child: ScaleTransition(
                        scale: _breatheAnimation,
                        child: Image.asset(
                          'assets/images/dragons/sleeping/gold.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Book Dragon',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 42,
                      color: AppColors.shimmer,
                      letterSpacing: 2,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading message at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Waking the dragon...',
                  style: GoogleFonts.rosarivo(
                    fontSize: 16,
                    color: AppColors.onBackground.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
