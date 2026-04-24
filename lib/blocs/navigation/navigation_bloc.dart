import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc({int initialIndex = 1})
      : super(NavigationState(currentIndex: initialIndex)) {
    on<TabSelected>(_onTabSelected);
    on<DismissRestriction>(_onDismissRestriction);
  }

  void _onTabSelected(TabSelected event, Emitter<NavigationState> emit) {
    if (event.index == 2 && event.userCoins < 50) {
      // Visiting Tourney with low coins triggers restriction.
      // We still update the index to 2 so the page "loads" behind the popup,
      // as requested ("visiting the tourney page should bring up a pop up").
      emit(state.copyWith(currentIndex: event.index, isRestricted: true));
    } else {
      emit(state.copyWith(currentIndex: event.index, isRestricted: false));
    }
  }

  void _onDismissRestriction(DismissRestriction event, Emitter<NavigationState> emit) {
    // Direct back to Home (index 1) and clear restriction
    emit(state.copyWith(currentIndex: 1, isRestricted: false));
  }
}
