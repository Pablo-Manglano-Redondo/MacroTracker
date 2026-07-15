import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';

class IntakeEntity extends Equatable {
  final String id;
  final String unit;
  final double amount;
  final IntakeTypeEntity type;
  final DateTime dateTime;

  final MealEntity meal;

  const IntakeEntity(
      {required this.id,
      required this.unit,
      required this.amount,
      required this.type,
      required this.meal,
      required this.dateTime});

  factory IntakeEntity.fromIntakeDBO(IntakeDBO intakeDBO) {
    return IntakeEntity(
        id: intakeDBO.id,
        unit: intakeDBO.unit,
        amount: intakeDBO.amount,
        type: IntakeTypeEntity.fromIntakeTypeDBO(intakeDBO.type),
        meal: MealEntity.fromMealDBO(intakeDBO.meal),
        dateTime: intakeDBO.dateTime);
  }

  MealPortionNutrition get _nutrition =>
      MealPortionCalculator.calculate(meal, amount, unit);

  double get totalKcal => _nutrition.kcal;

  double get totalCarbsGram => _nutrition.carbs;

  double get totalFatsGram => _nutrition.fat;

  double get totalProteinsGram => _nutrition.protein;

  double get totalSodiumMg => _nutrition.sodium ?? 0.0;
  double get totalPotassiumMg => _nutrition.potassium ?? 0.0;
  double get totalCalciumMg => _nutrition.calcium ?? 0.0;
  double get totalIronMg => _nutrition.iron ?? 0.0;
  double get totalVitaminCMg => _nutrition.vitaminC ?? 0.0;
  double get totalVitaminDMcg => _nutrition.vitaminD ?? 0.0;

  @override
  List<Object?> get props => [id, unit, amount, type, dateTime];
}
