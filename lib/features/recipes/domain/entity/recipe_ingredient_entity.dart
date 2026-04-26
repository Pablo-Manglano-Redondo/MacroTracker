import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';

class RecipeIngredientEntity extends Equatable {
  final String id;
  final MealEntity mealSnapshot;
  final double amount;
  final String unit;
  final int position;

  const RecipeIngredientEntity({
    required this.id,
    required this.mealSnapshot,
    required this.amount,
    required this.unit,
    required this.position,
  });

  @override
  List<Object?> get props => [id, mealSnapshot, amount, unit, position];
}
