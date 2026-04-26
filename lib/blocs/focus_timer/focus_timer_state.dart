import 'package:equatable/equatable.dart';
import '../../models/tourney.dart';

abstract class FocusTimerState extends Equatable {
  final int remainingSeconds;
  final int selectedMinutes;

  const FocusTimerState({
    this.remainingSeconds = 900,
    this.selectedMinutes = 15,
  });

  @override
  List<Object?> get props => [remainingSeconds, selectedMinutes];
}

class FocusTimerInitial extends FocusTimerState {
  const FocusTimerInitial({super.remainingSeconds, super.selectedMinutes});
}

class FocusTimerRunning extends FocusTimerState {
  const FocusTimerRunning({required super.remainingSeconds, required super.selectedMinutes});
}

class FocusTimerPromptingProgress extends FocusTimerState {
  const FocusTimerPromptingProgress({required super.selectedMinutes});
}

class FocusTimerCompleting extends FocusTimerState {
  const FocusTimerCompleting({required super.selectedMinutes});
}

class FocusTimerSuccess extends FocusTimerState {
  final FocusTimerResponse response;

  const FocusTimerSuccess({
    required this.response,
    required super.selectedMinutes,
  });

  @override
  List<Object?> get props => [response, selectedMinutes];
}

class FocusTimerFailure extends FocusTimerState {
  final String error;

  const FocusTimerFailure({
    required this.error,
    required super.remainingSeconds,
    required super.selectedMinutes,
  });

  @override
  List<Object?> get props => [error, remainingSeconds, selectedMinutes];
}
