import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
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

  double get totalKcal => amount * (meal.nutriments.energyPerUnit ?? 0);

  double get totalCarbsGram =>
      amount * (meal.nutriments.carbohydratesPerUnit ?? 0);

  double get totalFatsGram => amount * (meal.nutriments.fatPerUnit ?? 0);

  double get totalProteinsGram =>
      amount * (meal.nutriments.proteinsPerUnit ?? 0);

  @override
  List<Object?> get props => [id, unit, amount, type, dateTime];
}
