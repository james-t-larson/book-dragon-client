import 'package:equatable/equatable.dart';
import '../../models/app_constants.dart';

abstract class ConstantsState extends Equatable {
  const ConstantsState();

  @override
  List<Object?> get props => [];
}

class ConstantsInitial extends ConstantsState {}

class ConstantsLoading extends ConstantsState {}

class ConstantsLoaded extends ConstantsState {
  final AppConstants constants;

  const ConstantsLoaded(this.constants);

  @override
  List<Object?> get props => [constants];
}

class ConstantsError extends ConstantsState {
  final String message;

  const ConstantsError(this.message);

  @override
  List<Object?> get props => [message];
}
