import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Home',
          style: GoogleFonts.medievalSharp(
            fontSize: 32,
            color: AppColors.onBackground,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
