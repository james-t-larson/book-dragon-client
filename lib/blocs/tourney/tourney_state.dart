import 'package:equatable/equatable.dart';
import '../../models/tourney.dart';

enum TourneyStatus { initial, loading, loaded, error }

class TourneyState extends Equatable {
  final TourneyStatus status;
  final Tourney? activeTourney;
  final String? errorMessage;
  final int currentTauntIndex;

  const TourneyState({
    this.status = TourneyStatus.initial,
    this.activeTourney,
    this.errorMessage,
    this.currentTauntIndex = 0,
  });

  TourneyState copyWith({
    TourneyStatus? status,
    Tourney? activeTourney,
    String? errorMessage,
    int? currentTauntIndex,
  }) {
    return TourneyState(
      status: status ?? this.status,
      activeTourney: activeTourney ?? this.activeTourney,
      /// Intentionally overriding errorMessage with null if not provided and status changing to non-error.
      /// But typical copyWith doesn't allow nullable reset. Let's just do standard copyWith,
      /// or pass a wrapper. Since this is simple, we check status.
      errorMessage: errorMessage, 
      currentTauntIndex: currentTauntIndex ?? this.currentTauntIndex,
    );
  }

  /// Override to allow clearing error message explicitly
  TourneyState copyWithClearError({
    TourneyStatus? status,
    Tourney? activeTourney,
    int? currentTauntIndex,
  }) {
    return TourneyState(
      status: status ?? this.status,
      activeTourney: activeTourney ?? this.activeTourney,
      errorMessage: null,
      currentTauntIndex: currentTauntIndex ?? this.currentTauntIndex,
    );
  }

  bool get isLoading => status == TourneyStatus.loading;
  bool get hasActiveChallenge => activeTourney != null;
  bool get isDailyComplete => activeTourney?.dailyProgress.isComplete ?? false;

  double get overallProgressPercentage {
    final op = activeTourney?.overallProgress;
    if (op == null || op.daysGoal == 0) return 0.0;
    return (op.daysComplete / op.daysGoal).clamp(0.0, 1.0);
  }

  String get currentTaunt {
    final messages = activeTourney?.tauntMessages ?? [];
    if (messages.isEmpty) return '';
    return messages[currentTauntIndex % messages.length];
  }

  String get inviteLinkText =>
      'Join my reading tourney! Enter code: ${activeTourney?.inviteCode ?? ''}';

  @override
  List<Object?> get props => [
        status,
        activeTourney,
        errorMessage,
        currentTauntIndex,
      ];
}
