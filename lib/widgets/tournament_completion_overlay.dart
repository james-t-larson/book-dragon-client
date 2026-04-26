import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/tourney.dart';

enum CelebrationPhase { fireworks, windingDown, bannerRoll }

class TournamentCompletionOverlay extends StatefulWidget {
  final FocusTimerResponse response;
  final VoidCallback onDismiss;

  const TournamentCompletionOverlay({
    super.key,
    required this.response,
    required this.onDismiss,
  });

  @override
  State<TournamentCompletionOverlay> createState() =>
      _TournamentCompletionOverlayState();
}

class _TournamentCompletionOverlayState extends State<TournamentCompletionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fireworkController;
  late AnimationController _bannerController;
  final List<Firework> _fireworks = [];
  final Random _random = Random();
  CelebrationPhase _phase = CelebrationPhase.fireworks;
  Timer? _spawnTimer;

  @override
  void initState() {
    super.initState();
    _fireworkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateFireworks);
    _fireworkController.repeat();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startContinuousFireworks();
  }

  @override
  void dispose() {
    _fireworkController.dispose();
    _bannerController.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startContinuousFireworks() {
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_phase == CelebrationPhase.fireworks) {
        _spawnFirework();
      }
    });
  }

  void _spawnFirework() {
    setState(() {
      _fireworks.add(Firework(
        position: Offset(
          _random.nextDouble() * MediaQuery.of(context).size.width,
          _random.nextDouble() * MediaQuery.of(context).size.height * 0.6,
        ),
        color: _getRandomCelebrationColor(),
      ));
    });
  }

  Color _getRandomCelebrationColor() {
    final colors = [
      AppColors.shimmer, // Gold
      AppColors.primaryLight, // Crimson
      AppColors.secondaryLight, // Teal
      AppColors.tertiaryLight, // Green
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _updateFireworks() {
    if (!mounted) return;
    setState(() {
      for (var firework in _fireworks) {
        firework.update();
      }
      _fireworks.removeWhere((f) => f.isDead);
    });
  }

  void _handleInteraction() {
    if (_phase == CelebrationPhase.fireworks) {
      setState(() {
        _phase = CelebrationPhase.windingDown;
      });
      _spawnTimer?.cancel();
      
      // Spawn a few final ones
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: 200 * i), _spawnFirework);
      }

      // Transition to banner after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _phase = CelebrationPhase.bannerRoll);
          _bannerController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleInteraction,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Stack(
          children: [
            // Fireworks layer
            Positioned.fill(
              child: CustomPaint(
                painter: FireworkPainter(fireworks: _fireworks),
              ),
            ),

            // Interaction hint (only in fireworks phase)
            if (_phase == CelebrationPhase.fireworks)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fireworkController.drive(
                    CurveTween(curve: Curves.easeInOut),
                  ),
                  child: Center(
                    child: Text(
                      "TAP TO CLAIM YOUR REWARDS",
                      style: GoogleFonts.medievalSharp(
                        color: AppColors.onPrimary.withValues(alpha: 0.6),
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

            // Banner layer
            if (_phase == CelebrationPhase.bannerRoll)
              Center(
                child: SlideTransition(
                  position: _bannerController.drive(
                    Tween<Offset>(
                      begin: const Offset(0, -1.5),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.elasticOut)),
                  ),
                  child: _CelebrationBanner(
                    response: widget.response,
                    onDismiss: widget.onDismiss,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Firework {
  final Offset position;
  final Color color;
  final List<Particle> particles = [];
  bool isDead = false;
  int _life = 100;

  Firework({required this.position, required this.color}) {
    final random = Random();
    for (int i = 0; i < 40; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = random.nextDouble() * 4 + 2;
      particles.add(Particle(
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      ));
    }
  }

  void update() {
    _life -= 2;
    if (_life <= 0) isDead = true;
    for (var p in particles) {
      p.position += p.velocity;
      p.velocity += const Offset(0, 0.1); // gravity
    }
  }
}

class Particle {
  Offset position = Offset.zero;
  Offset velocity;
  Particle({required this.velocity});
}

class FireworkPainter extends CustomPainter {
  final List<Firework> fireworks;

  FireworkPainter({required this.fireworks});

  @override
  void paint(Canvas canvas, Size size) {
    for (var firework in fireworks) {
      final paint = Paint()
        ..color = firework.color.withValues(alpha: firework._life / 100)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      for (var p in firework.particles) {
        canvas.drawCircle(firework.position + p.position, 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FireworkPainter oldDelegate) => true;
}

class _CelebrationBanner extends StatelessWidget {
  final FocusTimerResponse response;
  final VoidCallback onDismiss;

  const _CelebrationBanner({
    required this.response,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037), // Dark brown banner base
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.shimmer, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF8D6E63).withValues(alpha: 0.2), // Parchment-like texture
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.shimmer.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "TOURNAMENT COMPLETE",
              textAlign: TextAlign.center,
              style: GoogleFonts.medievalSharp(
                fontSize: 28,
                color: AppColors.shimmer,
                fontWeight: FontWeight.bold,
                shadows: AppTheme.textOutline,
              ),
            ),
            const SizedBox(height: 24),
            _RewardRow(
              label: "Winnings",
              value: "${response.tourneyWinnings}",
              iconPath: 'assets/images/coins.png', // Assuming this exists or using icon
              color: AppColors.shimmer,
            ),
            const SizedBox(height: 12),
            _RewardRow(
              label: "Coins Earned",
              value: "${response.coinsEarned}",
              iconPath: 'assets/images/coins.png',
              color: AppColors.onSurface,
            ),
            const SizedBox(height: 12),
            _RewardRow(
              label: "Total Coins",
              value: "${response.totalCoins}",
              iconPath: 'assets/images/coins.png',
              color: AppColors.shimmer,
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.shimmer),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "COLLECT",
                  style: GoogleFonts.medievalSharp(
                    fontSize: 20,
                    color: AppColors.onPrimary,
                    letterSpacing: 2,
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

class _RewardRow extends StatelessWidget {
  final String label;
  final String value;
  final String? iconPath;
  final Color color;

  const _RewardRow({
    required this.label,
    required this.value,
    this.iconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rosarivo(
            fontSize: 18,
            color: AppColors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.medievalSharp(
                fontSize: 22,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.stars, color: AppColors.shimmer, size: 20),
          ],
        ),
      ],
    );
  }
}
