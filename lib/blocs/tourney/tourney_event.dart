import 'package:equatable/equatable.dart';

abstract class TourneyEvent extends Equatable {
  const TourneyEvent();

  @override
  List<Object?> get props => [];
}

class FetchInitialData extends TourneyEvent {}

class JoinChallenge extends TourneyEvent {
  final String inviteCode;

  const JoinChallenge(this.inviteCode);

  @override
  List<Object?> get props => [inviteCode];
}

class CreateChallenge extends TourneyEvent {
  final String name;
  final int dailyMins;
  final int overallDays;

  const CreateChallenge({
    required this.name,
    required this.dailyMins,
    required this.overallDays,
  });

  @override
  List<Object?> get props => [name, dailyMins, overallDays];
}

class CycleTaunt extends TourneyEvent {}
