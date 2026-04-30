import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../blocs/navigation/navigation_bloc.dart';
import '../blocs/navigation/navigation_event.dart';
import '../blocs/navigation/navigation_state.dart';
import '../blocs/book/book_bloc.dart';
import '../blocs/book/book_event.dart';
import '../repositories/book_repository.dart';
import '../widgets/low_coins_dialog.dart';
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
  late final NavigationBloc _navBloc;
  late final BookBloc _bookBloc;

  @override
  void initState() {
    super.initState();
    _navBloc = NavigationBloc(initialIndex: widget.initialIndex);
    _bookBloc = BookBloc(
      repository: BookRepository(),
      initialBooks: widget.user.books,
    );
    
    // Initial check if starting on Tourney Hall
    if (widget.initialIndex == 2 && widget.user.coins < 50) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navBloc.add(TabSelected(2, widget.user.coins));
      });
    }
  }

  @override
  void dispose() {
    _navBloc.close();
    _bookBloc.close();
    super.dispose();
  }

  void _showLowCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LowCoinsDialog(),
    ).then((_) {
      _navBloc.add(DismissRestriction());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _navBloc),
        BlocProvider.value(value: _bookBloc),
      ],
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state.isRestricted) {
            _showLowCoinsDialog(context);
          } else {
            // Fetch active books when navigating between tabs
            _bookBloc.add(FetchActiveBooks(widget.token));
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Scaffold(
              body: IndexedStack(
                index: state.currentIndex,
                children: [
                  // 0 — Focus Timer
                  FocusTimerScreen(
                    user: widget.user,
                    token: widget.token,
                    isActive: state.currentIndex == 0,
                    onNavigateBack: () => _navBloc.add(TabSelected(1, widget.user.coins)),
                  ),
                  // 1 — Home (Library)
                  HomeScreen(user: widget.user, token: widget.token),
                  // 2 — Tourney Hall
                  TourneyScreen(user: widget.user, token: widget.token),
                ],
              ),
              bottomNavigationBar: _buildBottomNav(state.currentIndex),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
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
        currentIndex: currentIndex,
        onTap: (index) => _navBloc.add(TabSelected(index, widget.user.coins)),
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
