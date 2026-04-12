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

class FocusTimerScreen extends StatefulWidget {
  final User user;
  final String token;
  final List<Book> activeBooks;

  const FocusTimerScreen({
    super.key,
    required this.user,
    required this.token,
    required this.activeBooks,
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

  final List<int> _presetMinutes = [1, 5, 15, 30, 45, 60];
  final TextEditingController _customTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentCoins = widget.user.coins;
    _remainingSeconds = _selectedMinutes * 60;
    if (widget.activeBooks.isNotEmpty) {
      _selectedBook = widget.activeBooks.first;
    }
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
                          activeColor: _dragonThemeColor,
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
                      backgroundColor: _dragonThemeColor,
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
      final response = await http.post(
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

  Color get _dragonThemeColor {
    final color = widget.user.dragonColor?.toLowerCase();
    switch (color) {
      case 'red':
        return const Color(0xFFCC3333);
      case 'blue':
        return const Color(0xFF3388CC);
      case 'green':
        return const Color(0xFF408000);
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'pink':
        return const Color(0xFFCC6699);
      case 'purple':
        return const Color(0xFF8844AA);
      case 'teal':
        return const Color(0xFF008080);
      default:
        return AppColors.tertiary; 
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
          style: GoogleFonts.medievalSharp(color: AppColors.onBackground),
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
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 80),

                      // Book Selector (only show if not running)
                      if (!_isRunning) ...[
                        Text(
                          'Chosen Scroll',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rosarivo(
                            fontSize: 18,
                            color: AppColors.secondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.activeBooks.length > 1)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _dragonThemeColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Book>(
                                  value: _selectedBook,
                                  dropdownColor: AppColors.surface,
                                  style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                                  items: widget.activeBooks.map((book) {
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
                                color: AppColors.onBackground,
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
                                color: _dragonThemeColor,
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
                            color: _isRunning
                                ? _dragonThemeColor
                                : AppColors.onBackground,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.5,
                                ),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
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
                            color: AppColors.secondaryLight,
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
                                  selectedColor: _dragonThemeColor,
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

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: AppButton(
                  onPressed: _isRunning ? () => _cancelTimer() : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning
                        ? AppColors.primary
                        : _dragonThemeColor,
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
