import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../widgets/dragon_art.dart';
import 'focus_timer_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1C15), // Very dark wood/stone color
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Library',
          style: GoogleFonts.medievalSharp(color: AppColors.onBackground),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Coins: ${user.coins}',
                style: GoogleFonts.rosarivo(
                  color: AppColors.shimmer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Library Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/rooms/library.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dragon on Table
          Align(
            alignment: const Alignment(
              0,
              0.4,
            ), // Positioned roughly on the table
            child: IgnorePointer(
              child: SizedBox(
                height: 350,
                width: 360,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 48,
                      child: DragonArt(colorName: user.dragonColor),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Play button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FocusTimerScreen(user: user, token: token),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_arrow,
                  size: 32,
                  color: AppColors.onPrimary,
                ),
                label: Text(
                  'Focus Time',
                  style: GoogleFonts.medievalSharp(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
