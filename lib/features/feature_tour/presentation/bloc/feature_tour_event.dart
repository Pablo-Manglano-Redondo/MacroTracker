part of 'feature_tour_bloc.dart';

abstract class FeatureTourEvent extends Equatable {
  const FeatureTourEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatureTourEvent extends FeatureTourEvent {
  final bool force;

  const LoadFeatureTourEvent({this.force = false});

  @override
  List<Object?> get props => [force];
}

class NextSlideEvent extends FeatureTourEvent {}

class PrevSlideEvent extends FeatureTourEvent {}

class SkipTourEvent extends FeatureTourEvent {}
