part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class ProfileLoadingState extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoadedState extends ProfileState {
  final UserBMIEntity userBMI;
  final UserEntity userEntity;
  final bool usesImperialUnits;
  final DailyFocusEntity dailyFocus;
  final GymTargetsEntity currentTargets;

  const ProfileLoadedState(
      {required this.userBMI,
      required this.userEntity,
      required this.usesImperialUnits,
      required this.dailyFocus,
      required this.currentTargets});

  @override
  List<Object?> get props =>
      [userBMI, userEntity, usesImperialUnits, dailyFocus, currentTargets];
}
