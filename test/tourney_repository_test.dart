import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:book_dragon_client/models/tourney.dart';
import 'package:book_dragon_client/services/tourney_service.dart';
import 'package:book_dragon_client/repositories/tourney_repository.dart';

class MockTourneyService extends Mock implements TourneyService {}

void main() {
  group('TourneyRepository', () {
    late MockTourneyService mockService;
    late TourneyRepository repository;

    final baseTourney = Tourney(
      id: 1,
      inviteCode: 'ABC',
      name: 'Test',
      dailyProgress: const DailyProgress(
        isComplete: false,
        minuteGoal: 30,
        minutesComplete: 10,
      ),
      overallProgress: const OverallProgress(
        dayNumber: 1,
        daysComplete: 0,
        daysGoal: 7,
        isComplete: false,
      ),
      tauntMessages: const [],
    );

    setUp(() {
      mockService = MockTourneyService();
      repository = TourneyRepository(service: mockService);
    });

    test('getActiveTourney delegates to service', () async {
      when(() => mockService.getActiveTourney())
          .thenAnswer((_) async => baseTourney);

      final result = await repository.getActiveTourney();
      expect(result, baseTourney);
      verify(() => mockService.getActiveTourney()).called(1);
    });

    test('joinTourney delegates to service', () async {
      when(() => mockService.joinTourney('ABC'))
          .thenAnswer((_) async => baseTourney);

      final result = await repository.joinTourney('ABC');
      expect(result, baseTourney);
      verify(() => mockService.joinTourney('ABC')).called(1);
    });

    test('createTourney delegates to service', () async {
      const request = CreateTourneyRequest(
        name: 'Test',
        dailyGoalMinutes: 30,
        overallGoalDays: 7,
      );
      when(() => mockService.createTourney(request))
          .thenAnswer((_) async => baseTourney);

      final result = await repository.createTourney(request);
      expect(result, baseTourney);
      verify(() => mockService.createTourney(request)).called(1);
    });
  });
}
