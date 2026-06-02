part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadItemsEvent extends HomeEvent {
  final bool refreshRemotePlan;
  final bool uploadProfessionalSnapshot;

  const LoadItemsEvent({
    this.refreshRemotePlan = false,
    this.uploadProfessionalSnapshot = false,
  });

  @override
  List<Object?> get props => [refreshRemotePlan, uploadProfessionalSnapshot];
}
