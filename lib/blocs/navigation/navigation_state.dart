import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int currentIndex;
  final bool isRestricted;

  const NavigationState({
    this.currentIndex = 1, // Default to Home
    this.isRestricted = false,
  });

  NavigationState copyWith({
    int? currentIndex,
    bool? isRestricted,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isRestricted: isRestricted ?? this.isRestricted,
    );
  }

  @override
  List<Object?> get props => [currentIndex, isRestricted];
}
