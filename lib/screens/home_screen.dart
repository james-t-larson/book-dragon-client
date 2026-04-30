import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../blocs/book/book_bloc.dart';
import '../blocs/book/book_event.dart';
import '../blocs/book/book_state.dart';
import '../widgets/dragon_art.dart';
import '../widgets/button.dart';
import '../widgets/add_book_dialog.dart';

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

  Future<void> _showAddBookDialog(BuildContext context) async {
    final Book? newBook = await showDialog<Book>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddBookDialog(
        themeColor: AppTheme.getDragonColor(widget.user.dragonColor),
      ),
    );

    if (newBook != null && context.mounted) {
      context.read<BookBloc>().add(AddBook(widget.token, newBook));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        bool showAddButton = false;
        if (state is BookLoaded && state.activeBooks.isEmpty) {
          showAddButton = true;
        }

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

          if (showAddButton)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: AppButton(
                  onPressed: () => _showAddBookDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getDragonColor(widget.user.dragonColor),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                  ),
                  child: Text(
                    'Add Scroll',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
      },
    );
  }
}
