import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:book_dragon_client/blocs/constants/constants_bloc.dart';
import 'package:book_dragon_client/blocs/constants/constants_event.dart';
import 'package:book_dragon_client/blocs/constants/constants_state.dart';
import 'package:book_dragon_client/models/app_constants.dart';
import 'package:book_dragon_client/repositories/constants_repository.dart';

class MockConstantsRepository extends Mock implements ConstantsRepository {}

void main() {
  late MockConstantsRepository mockRepository;
  late ConstantsBloc bloc;

  final constants = AppConstants(
    tourneyConfig: TourneyConfig(
      overallGoalDays: [const ConfigOption(label: '3 days', value: 3)],
      dailyGoalMinutes: [const ConfigOption(label: '15 mins', value: 15)],
    ),
  );

  setUp(() {
    mockRepository = MockConstantsRepository();
    bloc = ConstantsBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ConstantsBloc', () {
    test('initial state is ConstantsInitial', () {
      expect(bloc.state, ConstantsInitial());
    });

    test('emits [Loading, Loaded] when LoadConstants is successful', () async {
      when(() => mockRepository.getConstants(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => constants);

      final states = <ConstantsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadConstants());

      // Wait for async operations
      await Future.delayed(Duration.zero);

      expect(states, [
        ConstantsLoading(),
        ConstantsLoaded(constants),
      ]);
    });

    test('emits [Loading, Error] when LoadConstants fails', () async {
      when(() => mockRepository.getConstants(forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(Exception('API Error'));

      final states = <ConstantsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadConstants());

      // Wait for async operations
      await Future.delayed(Duration.zero);

      expect(states, [
        ConstantsLoading(),
        const ConstantsError('Exception: API Error'),
      ]);
    });
  });
}
