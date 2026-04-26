import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'focus_timer_event.dart';
import 'focus_timer_state.dart';
import '../../repositories/focus_timer_repository.dart';

class FocusTimerBloc extends Bloc<FocusTimerEvent, FocusTimerState> {
  final FocusTimerRepository _repository;
  Timer? _timer;

  FocusTimerBloc({required FocusTimerRepository repository})
      : _repository = repository,
        super(const FocusTimerInitial()) {
    on<StartTimer>(_onStartTimer);
    on<TimerTicked>(_onTimerTicked);
    on<CancelTimer>(_onCancelTimer);
    on<CompleteTimer>(_onCompleteTimer);
    on<SubmitProgress>(_onSubmitProgress);
    on<ResetTimer>(_onResetTimer);
    on<SetDuration>(_onSetDuration);
  }

  void _onStartTimer(StartTimer event, Emitter<FocusTimerState> emit) {
    _timer?.cancel();
    final remainingSeconds = event.minutes * 60;
    emit(FocusTimerRunning(
      remainingSeconds: remainingSeconds,
      selectedMinutes: event.minutes,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentRemaining = state.remainingSeconds - 1;
      if (currentRemaining >= 0) {
        add(TimerTicked(currentRemaining));
      } else {
        add(const CompleteTimer());
      }
    });
  }

  void _onTimerTicked(TimerTicked event, Emitter<FocusTimerState> emit) {
    if (state is FocusTimerRunning) {
      emit(FocusTimerRunning(
        remainingSeconds: event.remainingSeconds,
        selectedMinutes: state.selectedMinutes,
      ));
    }
  }

  void _onCancelTimer(CancelTimer event, Emitter<FocusTimerState> emit) {
    _timer?.cancel();
    emit(FocusTimerInitial(
      remainingSeconds: state.selectedMinutes * 60,
      selectedMinutes: state.selectedMinutes,
    ));
  }

  void _onCompleteTimer(CompleteTimer event, Emitter<FocusTimerState> emit) {
    _timer?.cancel();
    emit(FocusTimerPromptingProgress(selectedMinutes: state.selectedMinutes));
  }

  Future<void> _onSubmitProgress(
      SubmitProgress event, Emitter<FocusTimerState> emit) async {
    emit(FocusTimerCompleting(selectedMinutes: state.selectedMinutes));

    try {
      final response = await _repository.completeSession(
        token: event.token,
        bookId: event.bookId,
        minutes: state.selectedMinutes,
        currentPage: event.currentPage,
      );
      emit(FocusTimerSuccess(
        response: response,
        selectedMinutes: state.selectedMinutes,
      ));
    } catch (e) {
      emit(FocusTimerFailure(
        error: e.toString(),
        remainingSeconds: state.selectedMinutes * 60,
        selectedMinutes: state.selectedMinutes,
      ));
    }
  }

  void _onResetTimer(ResetTimer event, Emitter<FocusTimerState> emit) {
    _timer?.cancel();
    emit(FocusTimerInitial(
      remainingSeconds: state.selectedMinutes * 60,
      selectedMinutes: state.selectedMinutes,
    ));
  }

  void _onSetDuration(SetDuration event, Emitter<FocusTimerState> emit) {
    emit(FocusTimerInitial(
      remainingSeconds: event.minutes * 60,
      selectedMinutes: event.minutes,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
