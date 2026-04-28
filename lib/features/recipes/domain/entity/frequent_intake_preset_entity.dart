import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';

class FrequentIntakePresetEntity extends Equatable {
  final String key;
  final String title;
  final MealEntity meal;
  final IntakeTypeEntity intakeType;
  final String unit;
  final double amount;
  final int uses;

  const FrequentIntakePresetEntity({
    required this.key,
    required this.title,
    required this.meal,
    required this.intakeType,
    required this.unit,
    required this.amount,
    required this.uses,
  });

  @override
  List<Object?> get props => [key, title, intakeType, unit, amount, uses];
}
