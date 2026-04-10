import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'registration_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;
  late final AnimationController _entryController;

  late final Animation<double> _floatAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  late final String _dragonAsset;

  @override
  void initState() {
    super.initState();

    final dragonColors = ['blue', 'gold', 'moss', 'pink', 'red', 'white'];
    final randomIdx = math.Random().nextInt(dragonColors.length);
    _dragonAsset =
        'assets/images/dragons/Sleeping/${dragonColors[randomIdx]}.png';

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient twinkling particles
          const _AmbientParticles(),

          // Scrollable main content
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── App bar row ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Wordmark
                            Text(
                              'Book Dragon',
                              style: GoogleFonts.medievalSharp(
                                fontSize: 20,
                                color: AppColors.onBackground,
                                letterSpacing: 1.2,
                              ),
                            ),
                            // Tertiary pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.tertiary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Early Access',
                                style: GoogleFonts.rosarivo(
                                  fontSize: 11,
                                  color: AppColors.tertiaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Hero section ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radial glow
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, _) {
                                return Container(
                                  width: size.width * 0.75,
                                  height: size.width * 0.75,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.secondary.withValues(
                                          alpha: 0.14 * _glowAnimation.value,
                                        ),
                                        AppColors.primary.withValues(
                                          alpha: 0.06 * _glowAnimation.value,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Dragon + text hero
                            Column(
                              children: [
                                const SizedBox(height: 24),

                                // Dragon image
                                AnimatedBuilder(
                                  animation: _floatAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _floatAnimation.value),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 176,
                                    height: 176,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 48,
                                          spreadRadius: 8,
                                        ),
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 24,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        _dragonAsset,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Headline (MedievalSharp)
                                Text(
                                  'Your Reading\nCompanion',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.medievalSharp(
                                    fontSize: 40,
                                    color: AppColors.onBackground,
                                    height: 1.15,
                                    letterSpacing: 0.4,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Subline (Rosarivo italic — accent teal)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: Text(
                                    'A loyal dragon grows with every\npage you devour.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rosarivo(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.secondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Reading stats strip ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                        child: _StatsStrip(),
                      ),

                      // ── Feature cards ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Text(
                          'What awaits you',
                          style: GoogleFonts.medievalSharp(
                            fontSize: 18,
                            color: AppColors.onBackground,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _HorizontalFeatureCards(),

                      // ── Current reading preview ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                        child: _CurrentReadCard(),
                      ),

                      // ── CTA buttons ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: Column(
                          children: [
                            // Primary — Maroon
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistrationScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              child: Text(
                                'Begin Your Legend',
                                style: GoogleFonts.medievalSharp(
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Secondary — London Blue outline
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                side: const BorderSide(
                                  color: AppColors.secondary,
                                  width: 1.5,
                                ),
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'I already have an account',
                                style: GoogleFonts.rosarivo(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Body copy sample (Rosarivo)
                            Text(
                              'By continuing you agree to the Scrolls of Service\nand our Privacy Tome.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rosarivo(
                                fontSize: 11,
                                color: AppColors.muted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
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
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: '12', label: 'Books Read', color: AppColors.primary),
          _VerticalDivider(),
          _StatItem(
            value: '347',
            label: 'Pages Today',
            color: AppColors.secondary,
          ),
          _VerticalDivider(),
          _StatItem(
            value: 'Lvl 4',
            label: 'Dragon Rank',
            color: AppColors.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.medievalSharp(
            fontSize: 24,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.rosarivo(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.muted.withValues(alpha: 0.2),
    );
  }
}

// ── Feature cards ─────────────────────────────────────────────────────────────

class _HorizontalFeatureCards extends StatelessWidget {
  final List<FeatureCardData> _features = const [
    FeatureCardData(
      icon: Icons.auto_stories,
      title: 'Track Quests',
      body: 'Log every session. Never lose your page.',
      color: AppColors.primary,
    ),
    FeatureCardData(
      icon: Icons.timer_outlined,
      title: 'Focus Timer',
      body: 'Earn rewards for deep reading streaks.',
      color: AppColors.secondary,
    ),
    FeatureCardData(
      icon: Icons.eco_outlined,
      title: 'Dragon Grows',
      body: 'Level up your companion through books.',
      color: AppColors.tertiary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _features.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _FeatureCard(data: _features[i]),
      ),
    );
  }
}

class FeatureCardData {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const FeatureCardData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final FeatureCardData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.color.withValues(alpha: 0.12), AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: GoogleFonts.medievalSharp(
              fontSize: 15,
              color: AppColors.onBackground,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              data.body,
              style: GoogleFonts.rosarivo(
                fontSize: 11.5,
                color: AppColors.onSurface,
                height: 1.45,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Current reading preview card ──────────────────────────────────────────────

class _CurrentReadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: AppColors.secondary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Currently Reading',
                style: GoogleFonts.rosarivo(
                  fontSize: 12,
                  color: AppColors.secondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Book spine placeholder
              Container(
                width: 52,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    color: AppColors.onPrimary.withValues(alpha: 0.7),
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Name of the Wind',
                      style: GoogleFonts.medievalSharp(
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patrick Rothfuss',
                      style: GoogleFonts.rosarivo(
                        fontSize: 13,
                        color: AppColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.62,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Page 498 of 662',
                          style: GoogleFonts.rosarivo(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          '62%',
                          style: GoogleFonts.rosarivo(
                            fontSize: 11,
                            color: AppColors.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ambient particles ─────────────────────────────────────────────────────────

class _AmbientParticles extends StatefulWidget {
  const _AmbientParticles();

  @override
  State<_AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<_AmbientParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(_controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static const int _count = 22;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(99);

    for (int i = 0; i < _count; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.25 + rng.nextDouble() * 0.6;
      final radius = 0.8 + rng.nextDouble() * 2.2;
      final phase = rng.nextDouble();

      final t = (progress * speed + phase) % 1.0;
      final dy = t * size.height * 0.45;
      final opacity = (math.sin(t * math.pi) * 0.45).clamp(0.0, 0.45);

      final colorIdx = i % 3;
      final color = colorIdx == 0
          ? AppColors.secondary.withValues(alpha: opacity)
          : colorIdx == 1
          ? AppColors.primary.withValues(alpha: opacity * 0.65)
          : AppColors.shimmer.withValues(alpha: opacity * 0.55);

      canvas.drawCircle(
        Offset(baseX, baseY - dy),
        radius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
