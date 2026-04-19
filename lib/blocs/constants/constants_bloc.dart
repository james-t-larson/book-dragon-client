import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/constants_repository.dart';
import 'constants_event.dart';
import 'constants_state.dart';

class ConstantsBloc extends Bloc<ConstantsEvent, ConstantsState> {
  final ConstantsRepository _repository;

  ConstantsBloc({required ConstantsRepository repository})
      : _repository = repository,
        super(ConstantsInitial()) {
    on<LoadConstants>(_onLoadConstants);
  }

  Future<void> _onLoadConstants(
    LoadConstants event,
    Emitter<ConstantsState> emit,
  ) async {
    emit(ConstantsLoading());
    try {
      final constants = await _repository.getConstants(
        forceRefresh: event.forceRefresh,
      );
      emit(ConstantsLoaded(constants));
    } catch (e) {
      emit(ConstantsError(e.toString()));
    }
  }
}
