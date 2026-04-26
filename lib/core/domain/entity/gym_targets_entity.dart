import 'package:equatable/equatable.dart';

class GymTargetsEntity extends Equatable {
  final double kcalGoal;
  final double carbsGoal;
  final double fatGoal;
  final double proteinGoal;

  const GymTargetsEntity({
    required this.kcalGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.proteinGoal,
  });

  @override
  List<Object> get props => [kcalGoal, carbsGoal, fatGoal, proteinGoal];
}
