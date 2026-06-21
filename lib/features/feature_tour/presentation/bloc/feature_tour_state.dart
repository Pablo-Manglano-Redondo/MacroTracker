part of 'feature_tour_bloc.dart';

class FeatureTourState extends Equatable {
  final int currentSlideIndex;
  final bool isCompleted;

  const FeatureTourState({
    required this.currentSlideIndex,
    required this.isCompleted,
  });

  factory FeatureTourState.initial() => const FeatureTourState(
        currentSlideIndex: 0,
        isCompleted: false,
      );

  FeatureTourState copyWith({
    int? currentSlideIndex,
    bool? isCompleted,
  }) {
    return FeatureTourState(
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentSlideIndex, isCompleted];
}
