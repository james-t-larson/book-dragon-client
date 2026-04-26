import 'package:equatable/equatable.dart';

abstract class FocusTimerEvent extends Equatable {
  const FocusTimerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends FocusTimerEvent {
  final int minutes;
  const StartTimer(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class TimerTicked extends FocusTimerEvent {
  final int remainingSeconds;
  const TimerTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class CancelTimer extends FocusTimerEvent {
  const CancelTimer();
}

class CompleteTimer extends FocusTimerEvent {
  const CompleteTimer();
}

class SubmitProgress extends FocusTimerEvent {
  final int currentPage;
  final int bookId;
  final String token;

  const SubmitProgress({
    required this.currentPage,
    required this.bookId,
    required this.token,
  });

  @override
  List<Object?> get props => [currentPage, bookId, token];
}

class ResetTimer extends FocusTimerEvent {
  const ResetTimer();
}

class SetDuration extends FocusTimerEvent {
  final int minutes;
  const SetDuration(this.minutes);

  @override
  List<Object?> get props => [minutes];
}
