import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/tourney.dart';
import '../services/tourney_service.dart';

/// ViewModel for the Tourney Hall screen.
///
/// Scoped locally to [TourneyScreen] via a [ChangeNotifierProvider] — it is
/// intentionally NOT injected globally so the taunt timer and polling only run
/// while the screen is visible.
class TourneyViewModel extends ChangeNotifier {
  final TourneyService _service;
  final String userDragonColor;

  TourneyViewModel({
    required TourneyService service,
    required this.userDragonColor,
  }) : _service = service;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Tourney? _activeTourney;
  Tourney? get activeTourney => _activeTourney;

  int _currentTauntIndex = 0;
  int get currentTauntIndex => _currentTauntIndex;

  Timer? _tauntTimer;

  // Draft state for the "Create" form
  String _draftName = '';
  String get draftName => _draftName;

  int? _draftDailyMinutes;
  int? get draftDailyMinutes => _draftDailyMinutes;

  int? _draftOverallDays;
  int? get draftOverallDays => _draftOverallDays;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  bool get hasActiveChallenge => _activeTourney != null;

  bool get isDailyComplete =>
      _activeTourney?.dailyProgress.isComplete ?? false;

  double get overallProgressPercentage {
    final op = _activeTourney?.overallProgress;
    if (op == null || op.daysGoal == 0) return 0.0;
    return (op.daysComplete / op.daysGoal).clamp(0.0, 1.0);
  }

  String get currentTaunt {
    final messages = _activeTourney?.tauntMessages ?? [];
    if (messages.isEmpty) return '';
    return messages[_currentTauntIndex % messages.length];
  }

  /// Returns `true` when name, daily minutes, and overall days are all set.
  bool get isValidDraft =>
      _draftName.trim().isNotEmpty &&
      _draftDailyMinutes != null &&
      _draftOverallDays != null;

  // ---------------------------------------------------------------------------
  // Draft setters (no network calls)
  // ---------------------------------------------------------------------------

  void setDraftName(String name) {
    _draftName = name;
    notifyListeners();
  }

  void setDraftDailyMinutes(int? minutes) {
    _draftDailyMinutes = minutes;
    notifyListeners();
  }

  void setDraftOverallDays(int? days) {
    _draftOverallDays = days;
    notifyListeners();
  }

  void _resetDraft() {
    _draftName = '';
    _draftDailyMinutes = null;
    _draftOverallDays = null;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Loads the active tourney.
  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeTourney = await _service.getActiveTourney();

      if (hasActiveChallenge && !isDailyComplete) {
        startTauntCycle();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Joins a tourney by invite code.
  Future<void> joinChallenge(String inviteCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeTourney = await _service.joinTourney(inviteCode);
      if (!isDailyComplete) startTauntCycle();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new tourney from the draft values.
  Future<void> createChallenge(
      String name, int dailyMins, int overallDays) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeTourney = await _service.createTourney(
        CreateTourneyRequest(
          name: name,
          dailyGoalMinutes: dailyMins,
          overallGoalDays: overallDays,
        ),
      );
      _resetDraft();
      if (!isDailyComplete) startTauntCycle();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the invite-code text so the caller can share it.
  String get inviteLinkText =>
      'Join my reading tourney! Enter code: ${_activeTourney?.inviteCode ?? ''}';

  // ---------------------------------------------------------------------------
  // Taunt cycle
  // ---------------------------------------------------------------------------

  /// Starts a timer that cycles through taunt messages every 5-8 seconds.
  void startTauntCycle() {
    _stopTauntCycle();
    _scheduleTaunt();
  }

  void _scheduleTaunt() {
    final delay = 5 + Random().nextInt(4); // 5-8 seconds
    _tauntTimer = Timer(Duration(seconds: delay), () {
      final messages = _activeTourney?.tauntMessages ?? [];
      if (messages.isEmpty) return;
      _currentTauntIndex = (_currentTauntIndex + 1) % messages.length;
      notifyListeners();
      _scheduleTaunt(); // schedule next cycle
    });
  }

  void _stopTauntCycle() {
    _tauntTimer?.cancel();
    _tauntTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _stopTauntCycle();
    super.dispose();
  }
}
