import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../widgets/button.dart';
import 'home_screen.dart';

class DragonSelectionScreen extends StatefulWidget {
  final String token;
  final User user;
  const DragonSelectionScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<DragonSelectionScreen> createState() => _DragonSelectionScreenState();
}

class _DragonSelectionScreenState extends State<DragonSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  bool _isSubmitting = false;

  static const List<_DragonSlide> _dragons = [
    _DragonSlide('dragon_red.png', 'Red Dragon', 'red', Color(0xFFCC3333)),
    _DragonSlide('dragon_blue.png', 'Blue Dragon', 'blue', Color(0xFF3388CC)),
    _DragonSlide(
      'dragon_green.png',
      'Green Dragon',
      'green',
      Color(0xFF408000),
    ),
    _DragonSlide('dragon_gold.png', 'Gold Dragon', 'gold', Color(0xFFD4AF37)),
    _DragonSlide('dragon_pink.png', 'Pink Dragon', 'pink', Color(0xFFCC6699)),
    _DragonSlide(
      'dragon_purple.png',
      'Purple Dragon',
      'purple',
      Color(0xFF8844AA),
    ),
    _DragonSlide('dragon_teal.png', 'Teal Dragon', 'teal', Color(0xFF008080)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDragon() async {
    final dragon = _dragons[_currentPage];
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/dragon'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'color': dragon.colorName, 'name': dragon.name}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final updatedUser = widget.user.copyWith(
          dragonColor: dragon.colorName,
          dragonName: dragon.name,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(user: updatedUser, token: widget.token),
          ),
          (_) => false,
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['error'] ?? 'Failed to create dragon.'),
            backgroundColor: AppColors.primaryLight,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect to server. Please try again.'),
          backgroundColor: AppColors.primaryLight,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),

            // Heading
            Text(
              'Choose Your Dragon',
              style: GoogleFonts.medievalSharp(
                fontSize: 28,
                color: AppColors.onBackground,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Swipe or tap the arrows to browse.',
              style: GoogleFonts.rosarivo(
                fontSize: 14,
                color: AppColors.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 24),

            // PageView carousel with arrow buttons
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _dragons.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = (_pageController.page! - index).abs().clamp(
                              0.0,
                              1.0,
                            );
                          }
                          final scale = 1.0 - (value * 0.15);
                          final opacity = 1.0 - (value * 0.4);

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(opacity: opacity, child: child),
                          );
                        },
                        child: _DragonCard(dragon: _dragons[index]),
                      );
                    },
                  ),

                  // Left arrow
                  Positioned(
                    left: 4,
                    child: AnimatedOpacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.25,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        onPressed: _currentPage > 0
                            ? () => _goToPage(_currentPage - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 36),
                        color: AppColors.onBackground,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(
                            alpha: 0.85,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),

                  // Right arrow
                  Positioned(
                    right: 4,
                    child: AnimatedOpacity(
                      opacity: _currentPage < _dragons.length - 1 ? 1.0 : 0.25,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        onPressed: _currentPage < _dragons.length - 1
                            ? () => _goToPage(_currentPage + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 36),
                        color: AppColors.onBackground,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withValues(
                            alpha: 0.85,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
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

            // Selection button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: AppButton(
                onPressed: _isSubmitting ? null : _selectDragon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _dragons[_currentPage].color,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: _dragons[_currentPage].color
                      .withValues(alpha: 0.5),
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: _dragons[_currentPage].color.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        'Choose ${_dragons[_currentPage].name}',
                        style: GoogleFonts.medievalSharp(
                          fontSize: 18,
                          letterSpacing: 1.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DragonSlide {
  final String asset;
  final String name;
  final String colorName;
  final Color color;
  const _DragonSlide(this.asset, this.name, this.colorName, this.color);
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
