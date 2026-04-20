import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/tourney.dart';
import '../../repositories/tourney_repository.dart';
import 'tourney_event.dart';
import 'tourney_state.dart';

class TourneyBloc extends Bloc<TourneyEvent, TourneyState> {
  final TourneyRepository _repository;
  Timer? _tauntTimer;

  TourneyBloc({required TourneyRepository repository})
      : _repository = repository,
        super(const TourneyState()) {
    on<FetchInitialData>(_onFetchInitialData);
    on<JoinChallenge>(_onJoinChallenge);
    on<CreateChallenge>(_onCreateChallenge);
    on<CycleTaunt>(_onCycleTaunt);
  }

  Future<void> _onFetchInitialData(
    FetchInitialData event,
    Emitter<TourneyState> emit,
  ) async {
    emit(state.copyWithClearError(status: TourneyStatus.loading));
    try {
      final activeTourney = await _repository.getActiveTourney();
      emit(state.copyWithClearError(
        status: TourneyStatus.loaded,
        activeTourney: activeTourney,
      ));
      _manageTauntCycle(state, activeTourney);
    } catch (e) {
      emit(state.copyWith(
        status: TourneyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onJoinChallenge(
    JoinChallenge event,
    Emitter<TourneyState> emit,
  ) async {
    emit(state.copyWithClearError(status: TourneyStatus.loading));
    try {
      final activeTourney = await _repository.joinTourney(event.inviteCode);
      emit(state.copyWithClearError(
        status: TourneyStatus.loaded,
        activeTourney: activeTourney,
      ));
      _manageTauntCycle(state, activeTourney);
    } catch (e) {
      emit(state.copyWith(
        status: TourneyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateChallenge(
    CreateChallenge event,
    Emitter<TourneyState> emit,
  ) async {
    emit(state.copyWithClearError(status: TourneyStatus.loading));
    try {
      final request = CreateTourneyRequest(
        name: event.name,
        dailyGoalMinutes: event.dailyMins,
        overallGoalDays: event.overallDays,
      );
      final activeTourney = await _repository.createTourney(request);
      emit(state.copyWithClearError(
        status: TourneyStatus.loaded,
        activeTourney: activeTourney,
      ));
      _manageTauntCycle(state, activeTourney);
    } catch (e) {
      emit(state.copyWith(
        status: TourneyStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCycleTaunt(
    CycleTaunt event,
    Emitter<TourneyState> emit,
  ) {
    emit(state.copyWith(
      currentTauntIndex: state.currentTauntIndex + 1,
    ));
    _scheduleTaunt();
  }

  void _manageTauntCycle(TourneyState currentState, Tourney? tourney) {
    final isDailyComplete = tourney?.dailyProgress.isComplete ?? false;
    if (tourney != null && !isDailyComplete) {
      if (_tauntTimer == null) { // Only start if not already running
        _scheduleTaunt();
      }
    } else {
      _stopTauntCycle();
    }
  }

  void _scheduleTaunt() {
    _tauntTimer?.cancel();
    final delay = 5 + Random().nextInt(4); // 5-8 seconds
    _tauntTimer = Timer(Duration(seconds: delay), () {
      if (!isClosed) {
        add(CycleTaunt());
      }
    });
  }

  void _stopTauntCycle() {
    _tauntTimer?.cancel();
    _tauntTimer = null;
  }

  @override
  Future<void> close() {
    _stopTauntCycle();
    return super.close();
  }
}
