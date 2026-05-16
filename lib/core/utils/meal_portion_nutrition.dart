import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';

class MealPortionNutrition {
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final double? fiber;
  final double? sugar;
  final double? saturatedFat;

  const MealPortionNutrition({
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    this.fiber,
    this.sugar,
    this.saturatedFat,
  });
}

class MealPortionCalculator {
  static MealPortionNutrition calculate(
    MealEntity meal,
    double amount,
    String unit,
  ) {
    final convertedAmount = _convertAmount(amount, unit, meal);
    return MealPortionNutrition(
      kcal: convertedAmount * (meal.nutriments.energyPerUnit ?? 0),
      carbs: convertedAmount * (meal.nutriments.carbohydratesPerUnit ?? 0),
      fat: convertedAmount * (meal.nutriments.fatPerUnit ?? 0),
      protein: convertedAmount * (meal.nutriments.proteinsPerUnit ?? 0),
      fiber: _scaledOptionalValue(convertedAmount, meal.nutriments.fiber100),
      sugar: _scaledOptionalValue(convertedAmount, meal.nutriments.sugars100),
      saturatedFat:
          _scaledOptionalValue(convertedAmount, meal.nutriments.saturatedFat100),
    );
  }

  static double _convertAmount(double amount, String unit, MealEntity meal) {
    switch (unit) {
      case 'serving':
        return amount * (meal.servingQuantity ?? 1);
      case 'oz':
        return UnitCalc.ozToG(amount);
      case 'fl oz':
      case 'fl.oz':
        return UnitCalc.flOzToMl(amount);
      default:
        return amount;
    }
  }

  static double? _scaledOptionalValue(double amount, double? valuePer100) {
    if (valuePer100 == null) {
      return null;
    }
    return amount * (valuePer100 / 100);
  }
}
