import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:book_dragon_client/models/tourney.dart';
import 'package:book_dragon_client/services/tourney_service.dart';
import 'package:book_dragon_client/repositories/tourney_repository.dart';
import 'package:book_dragon_client/blocs/tourney/tourney_bloc.dart';
import 'package:book_dragon_client/blocs/tourney/tourney_event.dart';
import 'package:book_dragon_client/blocs/tourney/tourney_state.dart';
import 'package:mocktail/mocktail.dart';

class MockTourneyRepository extends Mock implements TourneyRepository {}

// ---------------------------------------------------------------------------
// Shared test fixtures
// ---------------------------------------------------------------------------

const _token = 'test_token_abc';

Map<String, dynamic> _tourneyJson({
  bool dailyComplete = false,
  int daysComplete = 3,
  int daysGoal = 10,
}) =>
    {
      'id': 42,
      'invite_code': 'ABC123',
      'name': 'Summer Readers',
      'daily_progress': {
        'is_complete': dailyComplete,
        'minute_goal': 15,
        'minutes_complete': dailyComplete ? 15 : 5,
      },
      'overall_progress': {
        'day_number': daysComplete + 1,
        'days_complete': daysComplete,
        'days_goal': daysGoal,
        'is_complete': daysComplete >= daysGoal,
      },
      'taunt_messages': [
        'Get reading, squire!',
        'Thy pages await!',
        'A dragon reads more than thee!',
      ],
    };

Map<String, dynamic> _constantsJson() => {
      'tourney_config': {
        'overall_goal_days': [
          {'label': '3 days', 'value': 3},
          {'label': '1 week', 'value': 7},
          {'label': '2 weeks', 'value': 14},
        ],
        'daily_goal_minutes': [
          {'label': '15 minutes', 'value': 15},
          {'label': '30 minutes', 'value': 30},
          {'label': '60 minutes', 'value': 60},
        ],
      }
    };

TourneyService _buildService(MockClient mockClient) =>
    TourneyService(token: _token, client: mockClient);

// ---------------------------------------------------------------------------
// Model tests
// ---------------------------------------------------------------------------

void main() {
  group('Model layer – fromJson / toJson round-trip', () {
    test('ConfigOption round-trip', () {
      const json = {'label': '3 days', 'value': 3};
      final opt = ConfigOption.fromJson(json);
      expect(opt.label, '3 days');
      expect(opt.value, 3);
      expect(opt.toJson(), json);
    });

    test('TourneyConfig parses both lists', () {
      final configJson = _constantsJson()['tourney_config'] as Map<String, dynamic>;
      final config = TourneyConfig.fromJson(configJson);
      expect(config.overallGoalDays.length, 3);
      expect(config.dailyGoalMinutes.length, 3);
      expect(config.overallGoalDays.first.label, '3 days');
      expect(config.dailyGoalMinutes.last.value, 60);
    });

    test('AppConstants parses from root JSON', () {
      final constants = AppConstants.fromJson(_constantsJson());
      expect(constants.tourneyConfig.overallGoalDays.length, 3);
      expect(constants.tourneyConfig.dailyGoalMinutes.first.value, 15);
    });

    test('DailyProgress round-trip', () {
      const json = {
        'is_complete': false,
        'minute_goal': 15,
        'minutes_complete': 5,
      };
      final dp = DailyProgress.fromJson(json);
      expect(dp.isComplete, false);
      expect(dp.minuteGoal, 15);
      expect(dp.minutesComplete, 5);
      expect(dp.toJson(), json);
    });

    test('OverallProgress round-trip', () {
      const json = {
        'day_number': 4,
        'days_complete': 3,
        'days_goal': 10,
        'is_complete': false,
      };
      final op = OverallProgress.fromJson(json);
      expect(op.dayNumber, 4);
      expect(op.daysComplete, 3);
      expect(op.daysGoal, 10);
      expect(op.isComplete, false);
      expect(op.toJson(), json);
    });

    test('Tourney round-trip', () {
      final json = _tourneyJson();
      final tourney = Tourney.fromJson(json);
      expect(tourney.id, 42);
      expect(tourney.inviteCode, 'ABC123');
      expect(tourney.name, 'Summer Readers');
      expect(tourney.tauntMessages.length, 3);
      // Round-trip
      final out = tourney.toJson();
      expect(out['name'], 'Summer Readers');
      expect(out['invite_code'], 'ABC123');
    });

    test('CreateTourneyRequest toJson', () {
      const req = CreateTourneyRequest(
        name: 'My Tourney',
        dailyGoalMinutes: 15,
        overallGoalDays: 7,
      );
      final json = req.toJson();
      expect(json['name'], 'My Tourney');
      expect(json['daily_goal_minutes'], 15);
      expect(json['overall_goal_days'], 7);
    });

    test('JoinTourneyRequest toJson', () {
      const req = JoinTourneyRequest(inviteCode: 'XYZ');
      expect(req.toJson(), {'invite_code': 'XYZ'});
    });
  });

  // ---------------------------------------------------------------------------
  // Service tests
  // ---------------------------------------------------------------------------

  group('TourneyService', () {
    test('getConstants returns parsed TourneyConfig on 200', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/constants');
        expect(req.headers['Authorization'], 'Bearer $_token');
        return http.Response(jsonEncode(_constantsJson()), 200);
      });

      final config = await _buildService(mock).getConstants();
      expect(config.overallGoalDays.length, 3);
      expect(config.dailyGoalMinutes.first.value, 15);
    });

    test('getConstants throws UnauthorizedException on 401', () async {
      final mock = MockClient((_) async => http.Response('', 401));
      expect(
        () => _buildService(mock).getConstants(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('getActiveTourney returns Tourney on 200', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/tourney');
        return http.Response(jsonEncode(_tourneyJson()), 200);
      });

      final tourney = await _buildService(mock).getActiveTourney();
      expect(tourney, isNotNull);
      expect(tourney!.name, 'Summer Readers');
    });

    test('getActiveTourney returns null on 404', () async {
      final mock = MockClient((_) async => http.Response('', 404));
      final tourney = await _buildService(mock).getActiveTourney();
      expect(tourney, isNull);
    });

    test('getActiveTourney throws UnauthorizedException on 401', () async {
      final mock = MockClient((_) async => http.Response('', 401));
      expect(
        () => _buildService(mock).getActiveTourney(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('joinTourney returns Tourney on 200', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/join_tourney');
        final body = jsonDecode(req.body);
        expect(body['invite_code'], 'ABC123');
        return http.Response(jsonEncode(_tourneyJson()), 200);
      });

      final tourney = await _buildService(mock).joinTourney('ABC123');
      expect(tourney.name, 'Summer Readers');
    });

    test('joinTourney throws on 400 (invalid code)', () async {
      final mock = MockClient((_) async => http.Response('', 400));
      expect(
        () => _buildService(mock).joinTourney('BAD_CODE'),
        throwsA(isA<Exception>()),
      );
    });

    test('createTourney returns Tourney on 201', () async {
      final mock = MockClient((req) async {
        expect(req.url.path, '/tourney');
        final body = jsonDecode(req.body);
        expect(body['name'], 'My Tourney');
        expect(body['daily_goal_minutes'], 15);
        expect(body['overall_goal_days'], 7);
        return http.Response(jsonEncode(_tourneyJson()), 201);
      });

      final tourney = await _buildService(mock).createTourney(
        const CreateTourneyRequest(
          name: 'My Tourney',
          dailyGoalMinutes: 15,
          overallGoalDays: 7,
        ),
      );
      expect(tourney.id, 42);
    });

    test('createTourney throws on 500', () async {
      final mock = MockClient((_) async => http.Response('', 500));
      expect(
        () => _buildService(mock).createTourney(
          const CreateTourneyRequest(
            name: 'x',
            dailyGoalMinutes: 15,
            overallGoalDays: 7,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Bloc tests
  // ---------------------------------------------------------------------------

  group('TourneyBloc', () {
    late MockTourneyRepository mockRepository;
    late TourneyBloc bloc;

    final baseTourney = Tourney.fromJson(_tourneyJson());

    setUpAll(() {
      registerFallbackValue(const CreateTourneyRequest(
        name: 'x', dailyGoalMinutes: 0, overallGoalDays: 0));
    });

    setUp(() {
      mockRepository = MockTourneyRepository();
      bloc = TourneyBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, TourneyStatus.initial);
      expect(bloc.state.activeTourney, isNull);
    });

    test('FetchInitialData without active challenge', () async {
      when(() => mockRepository.getActiveTourney())
          .thenAnswer((_) async => null);

      final states = <TourneyState>[];
      bloc.stream.listen(states.add);

      bloc.add(FetchInitialData());
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0].status, TourneyStatus.loading);
      expect(states[1].status, TourneyStatus.loaded);
      expect(states[1].hasActiveChallenge, false);
      expect(states[1].activeTourney, isNull);
    });

    test('FetchInitialData with active challenge', () async {
      when(() => mockRepository.getActiveTourney())
          .thenAnswer((_) async => baseTourney);

      final states = <TourneyState>[];
      bloc.stream.listen(states.add);

      bloc.add(FetchInitialData());
      await Future.delayed(Duration.zero);

      expect(states[1].status, TourneyStatus.loaded);
      expect(states[1].hasActiveChallenge, true);
      expect(states[1].activeTourney!.name, 'Summer Readers');
    });

    test('FetchInitialData sets errorMessage on failure', () async {
      when(() => mockRepository.getActiveTourney())
          .thenThrow(Exception('API error'));

      final states = <TourneyState>[];
      bloc.stream.listen(states.add);

      bloc.add(FetchInitialData());
      await Future.delayed(Duration.zero);

      expect(states[1].status, TourneyStatus.error);
      expect(states[1].errorMessage, isNotNull);
    });

    test('createChallenge success populates activeTourney', () async {
      when(() => mockRepository.createTourney(any()))
          .thenAnswer((_) async => baseTourney);

      final states = <TourneyState>[];
      bloc.stream.listen(states.add);

      bloc.add(const CreateChallenge(name: 'Epic Quest', dailyMins: 15, overallDays: 7));
      await Future.delayed(Duration.zero);

      expect(states[1].status, TourneyStatus.loaded);
      expect(states[1].hasActiveChallenge, true);
      expect(states[1].activeTourney!.name, 'Summer Readers');
    });

    test('joinChallenge success sets active tourney', () async {
      when(() => mockRepository.joinTourney(any()))
          .thenAnswer((_) async => baseTourney);

      final states = <TourneyState>[];
      bloc.stream.listen(states.add);

      bloc.add(const JoinChallenge('ABC123'));
      await Future.delayed(Duration.zero);

      expect(states[1].status, TourneyStatus.loaded);
      expect(states[1].hasActiveChallenge, true);
      expect(states[1].activeTourney!.inviteCode, 'ABC123');
    });
  });
}
