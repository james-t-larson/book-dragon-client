import 'package:equatable/equatable.dart';

abstract class ConstantsEvent extends Equatable {
  const ConstantsEvent();

  @override
  List<Object?> get props => [];
}

class LoadConstants extends ConstantsEvent {
  final bool forceRefresh;

  const LoadConstants({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
