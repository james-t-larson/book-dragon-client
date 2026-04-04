import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final String token;

  const HomeScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user.username}!',
              style: GoogleFonts.medievalSharp(
                fontSize: 32,
                color: AppColors.onBackground,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your journey begins with ${user.coins} coins.',
              style: GoogleFonts.rosarivo(
                fontSize: 18,
                color: AppColors.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
