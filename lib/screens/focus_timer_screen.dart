import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../widgets/button.dart';
import '../widgets/add_book_dialog.dart';

class FocusTimerScreen extends StatefulWidget {
  final User user;
  final String token;

  /// Called when the user should be navigated away from this screen
  /// (e.g., dismissed the add-book dialog without adding a scroll).
  final VoidCallback? onNavigateBack;

  /// Whether this tab is currently the active view (for dialog triggering).
  final bool isActive;

  /// Optional HTTP client for dependency injection (testing).
  final http.Client? httpClient;

  const FocusTimerScreen({
    super.key,
    required this.user,
    required this.token,
    this.onNavigateBack,
    this.isActive = true,
    this.httpClient,
  });

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _selectedMinutes = 15;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  late int _currentCoins;
  Book? _selectedBook;
  List<Book> _activeBooks = [];
  bool _isFetchingBooks = true;

  final List<int> _presetMinutes = [1, 5, 15, 30, 45, 60];
  final TextEditingController _customTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentCoins = widget.user.coins;
    _remainingSeconds = _selectedMinutes * 60;
    _fetchActiveBooks(promptIfEmpty: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _customTimeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        _isRunning) {
      _cancelTimer(lostFocus: true);
    }
  }

  Future<void> _startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final hideWarning = prefs.getBool('hide_focus_loss_warning') ?? false;

    if (!hideWarning && mounted) {
      final shouldStart = await showDialog<bool>(
        context: context,
        builder: (context) {
          bool dontShowAgain = false;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text(
                  'Focus Warning',
                  style: GoogleFonts.medievalSharp(color: AppColors.onSurface),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'If you leave the page for any reason, the timer will stop and any coins will be lost.',
                      style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              dontShowAgain = value ?? false;
                            });
                          },
                          activeColor: AppTheme.getDragonColor(widget.user.dragonColor),
                        ),
                        Expanded(
                          child: Text(
                            'Do not remind me again',
                            style: GoogleFonts.rosarivo(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  AppButton.text(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.rosarivo(
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ),
                  AppButton(
                    onPressed: () async {
                      if (dontShowAgain) {
                        await prefs.setBool('hide_focus_loss_warning', true);
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getDragonColor(widget.user.dragonColor),
                    ),
                    child: Text(
                      'Start Timer',
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

      if (shouldStart != true) {
        return;
      }
    }

    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _cancelTimer({bool lostFocus = false}) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });

    if (lostFocus && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The dragon vanished! You lost focus and your progress was reset.',
            style: GoogleFonts.rosarivo(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _completeTimer() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    final int? newPage = await _promptForProgress();
    if (newPage == null) return;

    try {
      final client = widget.httpClient ?? http.Client();
      final response = await client.post(
        Uri.parse('${AppConfig.baseUrl}/focus_timer_complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'book_id': _selectedBook?.id ?? 0,
          'minutes': _selectedMinutes,
          'current_page': newPage,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final coinsEarned = data['coins_earned'];
        final totalCoins = data['total_coins'];

        setState(() {
          _currentCoins = totalCoins;
          _remainingSeconds = _selectedMinutes * 60;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Focus complete! You earned $coinsEarned coins!',
              style: GoogleFonts.rosarivo(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.tertiary,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        _showError('Failed to complete focus session. Please try again.');
        setState(() {
          _remainingSeconds = _selectedMinutes * 60;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Network error occurred.');
        setState(() {
          _remainingSeconds = _selectedMinutes * 60;
        });
      }
    }
  }

  Future<int?> _promptForProgress() async {
    final controller = TextEditingController(
      text: _selectedBook?.currentPage.toString() ?? '0',
    );
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Record Your Progress',
            style: GoogleFonts.medievalSharp(color: AppColors.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Great focus! What is your current page in "${_selectedBook?.title ?? "Unknown Scroll"}"?',
                style: GoogleFonts.rosarivo(color: AppColors.onSurface),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Current Page',
                  labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.background.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            AppButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                Navigator.of(context).pop(val ?? _selectedBook?.currentPage ?? 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Confirm Progress',
                style: GoogleFonts.medievalSharp(color: AppColors.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.rosarivo(color: AppColors.onPrimary),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Book fetching & first-book flow
  // ---------------------------------------------------------------------------

  /// Fetches the user's currently-reading books from the API.
  ///
  /// When [promptIfEmpty] is true and no books are returned, the
  /// "Add a Scroll to Begin" dialog is shown automatically.
  Future<void> _fetchActiveBooks({bool promptIfEmpty = false}) async {
    setState(() => _isFetchingBooks = true);
    try {
      final client = widget.httpClient ?? http.Client();
      final response = await client.get(
        Uri.parse('${AppConfig.baseUrl}/books?currently_reading=true'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final books = data.map((b) => Book.fromJson(b)).toList();
        setState(() {
          _activeBooks = books;
          if (books.isNotEmpty && _selectedBook == null) {
            _selectedBook = books.first;
          }
          _isFetchingBooks = false;
        });

        if (promptIfEmpty && books.isEmpty && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showAddFirstBookDialog();
          });
        }
      } else {
        setState(() => _isFetchingBooks = false);
      }
    } catch (e) {
      setState(() => _isFetchingBooks = false);
    }
  }

  /// POSTs a new book to the server and re-fetches the active books list.
  Future<bool> _addFirstBook(Book book) async {
    try {
      final client = widget.httpClient ?? http.Client();
      final response = await client.post(
        Uri.parse('${AppConfig.baseUrl}/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(book.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _fetchActiveBooks();
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        _showError('Failed to add scroll. Please try again.');
      }
      return false;
    }
  }

  /// Handles the 'Start Focus' button click, checking for an active book.
  void _handleStartFocus() {
    if (_selectedBook != null) {
      _startTimer();
    } else {
      _showAddFirstBookDialog();
    }
  }

  /// Shows the add book dialog and handles the result.
  Future<void> _showAddFirstBookDialog() async {
    final Book? newBook = await showDialog<Book>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddBookDialog(themeColor: AppTheme.getDragonColor(widget.user.dragonColor)),
    );

    if (newBook != null && mounted) {
      final success = await _addFirstBook(newBook);
      if (success && mounted) {
        // Automatically start the timer after successful addition
        _startTimer();
      }
    } else if (mounted && _activeBooks.isEmpty) {
      // If they cancelled and still have no books, navigate back
      widget.onNavigateBack?.call();
    }
  }


  String? get _dragonSpritePath {
    final color = widget.user.dragonColor?.toLowerCase();
    switch (color) {
      case 'red':
        return 'assets/images/dragons/sleeping/red.png';
      case 'blue':
        return 'assets/images/dragons/sleeping/blue.png';
      case 'green':
        return 'assets/images/dragons/sleeping/moss.png';
      case 'gold':
        return 'assets/images/dragons/sleeping/gold.png';
      case 'pink':
        return 'assets/images/dragons/sleeping/pink.png';
      case 'white':
        return 'assets/images/dragons/sleeping/white.png';
      default:
        return null;
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Focus Timer',
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
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/rooms/reading-nook.png',
                fit: BoxFit.cover,
              ),
            ),

            if (_dragonSpritePath != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.7,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Image.asset(
                  _dragonSpritePath!,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            if (_isFetchingBooks)
              const Center(
                child: CircularProgressIndicator(color: AppColors.shimmer),
              )
            else
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 150),

                      // Book Selector (only show if not running)
                      if (!_isRunning) ...[
                        Text(
                          'Chosen Scroll',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rosarivo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDragonColor(widget.user.dragonColor),
                            shadows: AppTheme.textOutline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_activeBooks.length > 1)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.getDragonColor(widget.user.dragonColor)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Book>(
                                  value: _selectedBook,
                                  dropdownColor: AppColors.surface,
                                  style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                                  items: _activeBooks.map((book) {
                                    return DropdownMenuItem(
                                      value: book,
                                      child: Text(book.title),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedBook = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              _selectedBook?.title ?? 'No Scroll Selected',
                              style: GoogleFonts.medievalSharp(
                                fontSize: 24,
                                color: AppTheme.getDragonColor(widget.user.dragonColor),
                                shadows: AppTheme.textOutline,
                              ),
                            ),
                          ),
                      ] else ...[
                         // Show current book being read
                         Center(
                            child: Text(
                              'Studying: ${_selectedBook?.title ?? "Unknown Scroll"}',
                              style: GoogleFonts.medievalSharp(
                                fontSize: 20,
                                color: AppTheme.getDragonColor(widget.user.dragonColor),
                                shadows: AppTheme.textOutline,
                              ),
                            ),
                         ),
                      ],

                      const SizedBox(height: 40),

                      Center(
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: GoogleFonts.medievalSharp(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDragonColor(widget.user.dragonColor),
                            shadows: AppTheme.textOutline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (!_isRunning) ...[
                        Text(
                          'Select Duration',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rosarivo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDragonColor(widget.user.dragonColor),
                            shadows: AppTheme.textOutline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: _presetMinutes
                              .map(
                                (mins) => ChoiceChip(
                                  label: Text(
                                    '$mins m',
                                    style: GoogleFonts.rosarivo(),
                                  ),
                                  selected: _selectedMinutes == mins,
                                  selectedColor: AppTheme.getDragonColor(widget.user.dragonColor),
                                  backgroundColor: AppColors.surface,
                                  labelStyle: TextStyle(
                                    color: _selectedMinutes == mins
                                        ? AppColors.onPrimary
                                        : AppColors.onSurface,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedMinutes = mins;
                                        _remainingSeconds = mins * 60;
                                        _customTimeController.clear();
                                      });
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              child: TextField(
                                controller: _customTimeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rosarivo(
                                  color: AppColors.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Custom',
                                  hintStyle: GoogleFonts.rosarivo(
                                    color: AppColors.muted,
                                  ),
                                  suffixText: 'm',
                                  suffixStyle: GoogleFonts.rosarivo(
                                    color: AppColors.onSurface,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (val) {
                                  final customVal = int.tryParse(val);
                                  if (customVal != null && customVal > 0) {
                                    setState(() {
                                      _selectedMinutes = customVal;
                                      _remainingSeconds = customVal * 60;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (_isRunning)
                        const SizedBox(
                          height: 180,
                        ), 

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),

            if (!_isFetchingBooks)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: AppButton(
                  onPressed: _isRunning
                      ? () => _cancelTimer()
                      : _handleStartFocus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning
                        ? AppColors.primary
                        : AppTheme.getDragonColor(widget.user.dragonColor),
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
                  child: Text(
                    _isRunning ? 'Surrender' : 'Start Focus',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
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
