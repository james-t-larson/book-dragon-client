import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../widgets/dragon_art.dart';
import '../widgets/book_stack.dart';
import 'focus_timer_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

  Color _getColorFromTitle(String title) {
    final hash = title.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    // Darken colors slightly so text is readable
    return Color.fromARGB(255, r % 200 + 55, g % 200 + 55, b % 200 + 55);
  }



  Widget _buildBookSpine(Book book) {
    final color = _getColorFromTitle(book.title);
    return Container(
      width: 40,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 0)),
        ],
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              book.title,
              style: GoogleFonts.medievalSharp(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black87, blurRadius: 1)],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShelf(List<Book> shelfBooks) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3E2723), // Dark brown wood background behind shelves
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Shelf Wood Base
          Container(
            height: 20,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              border: Border(
                top: BorderSide(color: Color(0xFF795548), width: 2),
                bottom: BorderSide(color: Color(0xFF3E2723), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          // Books
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: shelfBooks.map((b) => _buildBookSpine(b)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShelf() {
    return _buildShelf([]);
  }

  @override
  Widget build(BuildContext context) {
    final books = user.books;
    List<Widget> shelves = [];

    if (books.isEmpty) {
      shelves = [_buildEmptyShelf(), _buildEmptyShelf(), _buildEmptyShelf()];
    } else {
      // Split books into chunks of 6 (assuming 6 books per shelf roughly fits normal screen)
      for (int i = 0; i < books.length; i += 6) {
        int end = (i + 6 < books.length) ? i + 6 : books.length;
        shelves.add(_buildShelf(books.sublist(i, end)));
      }
      // Ensure at least 3 shelves are drawn for aesthetic
      while (shelves.length < 3) {
        shelves.add(_buildEmptyShelf());
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2E1C15), // Very dark wood/stone color
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
          // Shelves
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: shelves,
          ),

          // Dragon and Books in the center
          Align(
            alignment: const Alignment(0, 0.2), // Slightly lower down
            child: IgnorePointer(
              child: SizedBox(
                height: 350,
                width: 360,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    const Positioned(
                      bottom: 0,
                      child: MessyBookStack(),
                    ),
                    Positioned(
                      bottom: 48, // Sit well into the stack of books
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
