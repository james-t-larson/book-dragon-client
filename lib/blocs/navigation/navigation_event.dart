import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class TabSelected extends NavigationEvent {
  final int index;
  final int userCoins;

  const TabSelected(this.index, this.userCoins);

  @override
  List<Object?> get props => [index, userCoins];
}

class DismissRestriction extends NavigationEvent {}
