import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'focus_timer_screen.dart';
import 'tourney_screen.dart';

/// Root navigation wrapper that uses an [IndexedStack] to preserve state
/// across the three main screens: Focus Timer, Home, and Tourney Hall.
///
/// The bottom navigation bar uses medieval-themed icons:
///   0 → Clock (Focus Timer)
///   1 → Home
///   2 → Crossed Swords (Tourney)
class MainNavigationScreen extends StatefulWidget {
  final User user;
  final String token;

  /// Which tab to show initially (defaults to 1 = Home).
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.user,
    required this.token,
    this.initialIndex = 1,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0 — Focus Timer
          FocusTimerScreen(
            user: widget.user,
            token: widget.token,
            activeBooks: const [], // will be loaded internally
          ),
          // 1 — Home (Library)
          HomeScreen(user: widget.user, token: widget.token),
          // 2 — Tourney Hall
          TourneyScreen(user: widget.user, token: widget.token),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.shimmer.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.shimmer,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: GoogleFonts.medievalSharp(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.rosarivo(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            activeIcon: Icon(Icons.sports_kabaddi),
            label: 'Tourney',
          ),
        ],
      ),
    );
  }
}
