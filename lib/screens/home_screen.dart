import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../widgets/dragon_art.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentCoins;

  @override
  void initState() {
    super.initState();
    _currentCoins = widget.user.coins;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1C15), 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Library',
          style: GoogleFonts.medievalSharp(
            color: AppTheme.getDragonColor(widget.user.dragonColor),
            shadows: AppTheme.textOutline,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Coins: $_currentCoins',
                style: GoogleFonts.rosarivo(
                  color: AppColors.shimmer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: AppTheme.textOutline,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/rooms/library.png',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: const Alignment(0, 0.4),
            child: IgnorePointer(
              child: SizedBox(
                height: 350,
                width: 360,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 48,
                      child: DragonArt(colorName: widget.user.dragonColor),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
