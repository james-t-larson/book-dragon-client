import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../widgets/dragon_art.dart';
import 'focus_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _activeBooks = [];
  bool _isLoading = true;
  late int _currentCoins;

  @override
  void initState() {
    super.initState();
    _currentCoins = widget.user.coins;
    _fetchActiveBooks();
  }

  Future<void> _fetchActiveBooks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/books?currently_reading=true'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _activeBooks = data.map((b) => Book.fromJson(b)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final totalPagesController = TextEditingController();
    final currentPageController = TextEditingController();
    final genreController = TextEditingController();
    bool isCurrentlyReading = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              insetPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Scroll',
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.onSurface,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(titleController, 'Title', Icons.book),
                      _buildTextField(authorController, 'Author', Icons.person),
                      _buildTextField(
                        genreController,
                        'Genre',
                        Icons.category,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              totalPagesController,
                              'Total Pages',
                              Icons.pages,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              currentPageController,
                              'Current Page',
                              Icons.edit_note,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: isCurrentlyReading,
                            onChanged: (val) {
                              setDialogState(() {
                                isCurrentlyReading = val ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              'Mark as "Currently Reading"',
                              style: GoogleFonts.rosarivo(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final newBook = Book(
                        id: 0,
                        title: titleController.text,
                        author: authorController.text,
                        genre: genreController.text,
                        totalPages: int.tryParse(totalPagesController.text) ?? 0,
                        currentPage: int.tryParse(currentPageController.text) ?? 0,
                        reading: isCurrentlyReading,
                      );
                      final navigator = Navigator.of(context);
                      await _addBook(newBook);
                      if (navigator.mounted) {
                        navigator.pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Add Book',
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.rosarivo(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
          prefixIcon: Icon(icon, color: AppColors.secondaryLight),
          filled: true,
          fillColor: AppColors.background.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Future<void> _addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchActiveBooks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${book.title}" to your library!'),
              backgroundColor: AppColors.tertiary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add book.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1C15), 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Library',
          style: GoogleFonts.medievalSharp(color: AppColors.onBackground),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 28),
            onPressed: _showAddBookDialog,
            tooltip: 'Add Book',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Coins: $_currentCoins',
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

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _isLoading 
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton.icon(
                    onPressed: () {
                      if (_activeBooks.isEmpty) {
                        _showAddBookDialog();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FocusTimerScreen(
                              user: widget.user,
                              token: widget.token,
                              activeBooks: _activeBooks,
                            ),
                          ),
                        ).then((_) => _fetchActiveBooks());
                      }
                    },
                    icon: Icon(
                      _activeBooks.isEmpty ? Icons.add : Icons.play_arrow,
                      size: 32,
                      color: AppColors.onPrimary,
                    ),
                    label: Text(
                      _activeBooks.isEmpty ? 'Add Book' : 'Focus Time',
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
