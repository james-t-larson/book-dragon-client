import 'package:flutter/foundation.dart';
import '../blocs/constants/constants_bloc.dart';
import '../blocs/constants/constants_event.dart';
import '../blocs/constants/constants_state.dart';
import '../models/app_constants.dart';

/// ViewModel for application-wide constants.
///
/// Strictly follows the MVVM model by wrapping a [ConstantsBloc] and exposing
/// only relevant data and actions to the View.
class ConstantsViewModel extends ChangeNotifier {
  final ConstantsBloc _bloc;
  
  ConstantsViewModel({required ConstantsBloc bloc}) : _bloc = bloc {
    // Listen to bloc state changes to trigger UI updates via notifyListeners()
    _bloc.stream.listen((state) {
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  ConstantsState get state => _bloc.state;

  bool get isLoading => state is ConstantsLoading;

  String? get errorMessage => state is ConstantsError ? (state as ConstantsError).message : null;

  AppConstants? get constants => state is ConstantsLoaded ? (state as ConstantsLoaded).constants : null;

  TourneyConfig? get tourneyConfig => constants?.tourneyConfig;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Triggers a fetch of the constants.
  void loadConstants({bool forceRefresh = false}) {
    _bloc.add(LoadConstants(forceRefresh: forceRefresh));
  }
}
