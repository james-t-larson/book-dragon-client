import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:book_dragon_client/blocs/constants/constants_bloc.dart';
import 'package:book_dragon_client/blocs/constants/constants_event.dart';
import 'package:book_dragon_client/blocs/constants/constants_state.dart';
import 'package:book_dragon_client/models/app_constants.dart';
import 'package:book_dragon_client/view_models/constants_view_model.dart';

class MockConstantsBloc extends Mock implements ConstantsBloc {}

void main() {
  late MockConstantsBloc mockBloc;
  late ConstantsViewModel viewModel;

  final constants = AppConstants(
    tourneyConfig: TourneyConfig(
      overallGoalDays: [const ConfigOption(label: '3 days', value: 3)],
      dailyGoalMinutes: [const ConfigOption(label: '15 mins', value: 15)],
    ),
  );

  setUp(() {
    mockBloc = MockConstantsBloc();
    // Default mock behavior for stream
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('ConstantsViewModel', () {
    test('exposes loading state correctly', () {
      when(() => mockBloc.state).thenReturn(ConstantsLoading());
      viewModel = ConstantsViewModel(bloc: mockBloc);
      
      expect(viewModel.isLoading, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('exposes loaded constants correctly', () {
      when(() => mockBloc.state).thenReturn(ConstantsLoaded(constants));
      viewModel = ConstantsViewModel(bloc: mockBloc);
      
      expect(viewModel.isLoading, false);
      expect(viewModel.constants, constants);
      expect(viewModel.tourneyConfig, constants.tourneyConfig);
    });

    test('exposes error state correctly', () {
      when(() => mockBloc.state).thenReturn(const ConstantsError('Failed'));
      viewModel = ConstantsViewModel(bloc: mockBloc);
      
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Failed');
    });

    test('loadConstants adds event to bloc', () {
      when(() => mockBloc.state).thenReturn(ConstantsInitial());
      viewModel = ConstantsViewModel(bloc: mockBloc);
      
      viewModel.loadConstants(forceRefresh: true);
      
      verify(() => mockBloc.add(const LoadConstants(forceRefresh: true))).called(1);
    });
  });
}
