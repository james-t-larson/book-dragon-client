import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_dragon_client/models/app_constants.dart';
import 'package:book_dragon_client/repositories/constants_repository.dart';
import 'package:book_dragon_client/services/tourney_service.dart';

class MockTourneyService extends Mock implements TourneyService {}

void main() {
  late MockTourneyService mockService;
  late SharedPreferences prefs;
  late ConstantsRepository repository;

  final tourneyConfig = TourneyConfig(
    overallGoalDays: [const ConfigOption(label: '3 days', value: 3)],
    dailyGoalMinutes: [const ConfigOption(label: '15 mins', value: 15)],
  );

  setUp(() async {
    mockService = MockTourneyService();
    // Use the official mock for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = ConstantsRepository(service: mockService, prefs: prefs);
  });

  group('ConstantsRepository', () {
    test('getConstants fetches from API and caches when no cache exists', () async {
      when(() => mockService.getConstants()).thenAnswer((_) async => tourneyConfig);

      final result = await repository.getConstants();

      expect(result.tourneyConfig, tourneyConfig);
      verify(() => mockService.getConstants()).called(1);
      
      // Check cache
      final cachedJson = prefs.getString('app_constants_cache');
      expect(cachedJson, isNotNull);
      final decoded = AppConstants.fromString(cachedJson!);
      expect(decoded.tourneyConfig.overallGoalDays.first.value, 3);
    });

    test('getConstants returns cached data without calling API', () async {
      final constants = AppConstants(tourneyConfig: tourneyConfig);
      await prefs.setString('app_constants_cache', constants.toStringContent());

      final result = await repository.getConstants();

      expect(result.tourneyConfig.overallGoalDays.first.value, 3);
      verifyNever(() => mockService.getConstants());
    });

    test('getConstants fetches from API when forceRefresh is true', () async {
      final constants = AppConstants(tourneyConfig: tourneyConfig);
      await prefs.setString('app_constants_cache', constants.toStringContent());
      
      when(() => mockService.getConstants()).thenAnswer((_) async => tourneyConfig);

      final result = await repository.getConstants(forceRefresh: true);

      expect(result.tourneyConfig, tourneyConfig);
      verify(() => mockService.getConstants()).called(1);
    });

    test('clearCache removes data from SharedPreferences', () async {
      await prefs.setString('app_constants_cache', 'some data');
      
      await repository.clearCache();
      
      expect(prefs.containsKey('app_constants_cache'), isFalse);
    });
  });
}
