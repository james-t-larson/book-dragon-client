// Models for the Tourney Hall (Challenges) feature.
//
// Corresponds to the backend API endpoints:
// - GET /constants → TourneyConfig
// - GET /tourney → Tourney
// - POST /tourney → Tourney
// - POST /join_tourney → Tourney

export 'app_constants.dart';

// ---------------------------------------------------------------------------
// Tourney state (from GET /tourney)
// ---------------------------------------------------------------------------

/// Daily reading progress within an active tourney.
class DailyProgress {
  final bool isComplete;
  final int minuteGoal;
  final int minutesComplete;

  const DailyProgress({
    required this.isComplete,
    required this.minuteGoal,
    required this.minutesComplete,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      isComplete: json['is_complete'] as bool,
      minuteGoal: json['minute_goal'] as int,
      minutesComplete: json['minutes_complete'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'is_complete': isComplete,
        'minute_goal': minuteGoal,
        'minutes_complete': minutesComplete,
      };
}

/// Overall (multi-day) progress for the active tourney.
class OverallProgress {
  final int dayNumber;
  final int daysComplete;
  final int daysGoal;
  final bool isComplete;

  const OverallProgress({
    required this.dayNumber,
    required this.daysComplete,
    required this.daysGoal,
    required this.isComplete,
  });

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    return OverallProgress(
      dayNumber: json['day_number'] as int,
      daysComplete: json['days_complete'] as int,
      daysGoal: json['days_goal'] as int,
      isComplete: json['is_complete'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_number': dayNumber,
        'days_complete': daysComplete,
        'days_goal': daysGoal,
        'is_complete': isComplete,
      };
}

/// The active tourney entity returned by `GET /tourney`.
class Tourney {
  final int id;
  final String inviteCode;
  final String name;
  final DateTime? startTime;
  final int? potTotal;
  final int? challengerCount;
  final int? completedCount;
  final DailyProgress dailyProgress;
  final OverallProgress overallProgress;
  final List<String> tauntMessages;

  const Tourney({
    required this.id,
    required this.inviteCode,
    required this.name,
    this.startTime,
    this.potTotal,
    this.challengerCount,
    this.completedCount,
    required this.dailyProgress,
    required this.overallProgress,
    required this.tauntMessages,
  });

  factory Tourney.fromJson(Map<String, dynamic> json) {
    return Tourney(
      id: json['id'] as int,
      inviteCode: json['invite_code'] as String,
      name: json['name'] as String,
      startTime: json['starttime'] != null
          ? DateTime.parse(json['starttime'] as String)
          : null,
      potTotal: json['pot_total'] as int?,
      challengerCount: json['challenger_count'] as int?,
      completedCount: json['completed_count'] as int?,
      dailyProgress:
          DailyProgress.fromJson(json['daily_progress'] as Map<String, dynamic>),
      overallProgress: OverallProgress.fromJson(
          json['overall_progress'] as Map<String, dynamic>),
      tauntMessages: json['taunt_messages'] != null
          ? (json['taunt_messages'] as List).map((e) => e as String).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invite_code': inviteCode,
        'name': name,
        'starttime': startTime?.toIso8601String(),
        'pot_total': potTotal,
        'challenger_count': challengerCount,
        'completed_count': completedCount,
        'daily_progress': dailyProgress.toJson(),
        'overall_progress': overallProgress.toJson(),
        'taunt_messages': tauntMessages,
      };
}

/// Response returned by the `/focus_timer_complete` endpoint.
class FocusTimerResponse {
  final int coinsEarned;
  final int tourneyWinnings;
  final bool tourneyCompleted;
  final int totalCoins;
  final Tourney? tourney;

  const FocusTimerResponse({
    required this.coinsEarned,
    required this.tourneyWinnings,
    required this.tourneyCompleted,
    required this.totalCoins,
    this.tourney,
  });

  factory FocusTimerResponse.fromJson(Map<String, dynamic> json) {
    return FocusTimerResponse(
      coinsEarned: json['coins_earned'] ?? 0,
      tourneyWinnings: json['tourney_winnings'] ?? 0,
      tourneyCompleted: json['tourney_completed'] ?? false,
      totalCoins: json['total_coins'] ?? 0,
      tourney: json['tourney'] != null
          ? Tourney.fromJson(json['tourney'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Request bodies
// ---------------------------------------------------------------------------

/// Body for `POST /tourney`.
class CreateTourneyRequest {
  final String name;
  final int dailyGoalMinutes;
  final int overallGoalDays;

  const CreateTourneyRequest({
    required this.name,
    required this.dailyGoalMinutes,
    required this.overallGoalDays,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'daily_goal_minutes': dailyGoalMinutes,
        'overall_goal_days': overallGoalDays,
      };
}

/// Body for `POST /join_tourney`.
class JoinTourneyRequest {
  final String inviteCode;

  const JoinTourneyRequest({required this.inviteCode});

  Map<String, dynamic> toJson() => {'invite_code': inviteCode};
}
