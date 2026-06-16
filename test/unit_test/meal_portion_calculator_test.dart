import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

// Helper factory to build a test MealEntity.
MealEntity _meal({
  String mealUnit = 'g',
  double? servingQuantity,
  double? energyKcal100 = 400.0,
  double? carbs100 = 50.0,
  double? fat100 = 15.0,
  double? proteins100 = 20.0,
  double? sugars100 = 5.0,
  double? saturatedFat100 = 4.0,
  double? fiber100 = 3.0,
}) =>
    MealEntity(
      code: 'test',
      name: 'Test Meal',
      url: null,
      mealQuantity: null,
      mealUnit: mealUnit,
      servingQuantity: servingQuantity,
      servingUnit: mealUnit,
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: energyKcal100,
        carbohydrates100: carbs100,
        fat100: fat100,
        proteins100: proteins100,
        sugars100: sugars100,
        saturatedFat100: saturatedFat100,
        fiber100: fiber100,
      ),
      source: MealSourceEntity.custom,
    );

void main() {
  group('MealNutrimentsEntity', () {
    test('perUnit getters divide by 100', () {
      final n = MealNutrimentsEntity(
        energyKcal100: 400,
        carbohydrates100: 50,
        fat100: 20,
        proteins100: 30,
        sugars100: 10,
        saturatedFat100: 8,
        fiber100: 5,
      );
      expect(n.energyPerUnit, closeTo(4.0, 0.001));
      expect(n.carbohydratesPerUnit, closeTo(0.5, 0.001));
      expect(n.fatPerUnit, closeTo(0.2, 0.001));
      expect(n.proteinsPerUnit, closeTo(0.3, 0.001));
      expect(n.sugarsPerUnit, closeTo(0.1, 0.001));
      expect(n.saturatedFatPerUnit, closeTo(0.08, 0.001));
      expect(n.fiberPerUnit, closeTo(0.05, 0.001));
    });

    test('perUnit getters return null when value is null', () {
      final n = MealNutrimentsEntity.empty();
      expect(n.energyPerUnit, isNull);
      expect(n.carbohydratesPerUnit, isNull);
      expect(n.fatPerUnit, isNull);
      expect(n.proteinsPerUnit, isNull);
      expect(n.sugarsPerUnit, isNull);
      expect(n.saturatedFatPerUnit, isNull);
      expect(n.fiberPerUnit, isNull);
    });

    test('empty() factory creates all-null instance', () {
      final n = MealNutrimentsEntity.empty();
      expect(n.energyKcal100, isNull);
      expect(n.carbohydrates100, isNull);
      expect(n.fat100, isNull);
      expect(n.proteins100, isNull);
    });

    test('equality works correctly', () {
      const a = MealNutrimentsEntity(
        energyKcal100: 200,
        carbohydrates100: 30,
        fat100: 10,
        proteins100: 15,
        sugars100: 5,
        saturatedFat100: 2,
        fiber100: 3,
      );
      const b = MealNutrimentsEntity(
        energyKcal100: 200,
        carbohydrates100: 30,
        fat100: 10,
        proteins100: 15,
        sugars100: 5,
        saturatedFat100: 2,
        fiber100: 3,
      );
      expect(a, equals(b));
    });
  });

  group('MealPortionCalculator - gram unit', () {
    test('calculates nutrition correctly for 100g', () {
      final meal = _meal(mealUnit: 'g');
      final result = MealPortionCalculator.calculate(meal, 100, 'g');
      expect(result.kcal, closeTo(400.0, 0.01));
      expect(result.carbs, closeTo(50.0, 0.01));
      expect(result.fat, closeTo(15.0, 0.01));
      expect(result.protein, closeTo(20.0, 0.01));
    });

    test('calculates nutrition correctly for 200g', () {
      final meal = _meal(mealUnit: 'g');
      final result = MealPortionCalculator.calculate(meal, 200, 'g');
      expect(result.kcal, closeTo(800.0, 0.01));
      expect(result.carbs, closeTo(100.0, 0.01));
    });

    test('scales optional fiber and sugar per 100g', () {
      final meal = _meal(mealUnit: 'g', fiber100: 6.0, sugars100: 10.0);
      final result = MealPortionCalculator.calculate(meal, 100, 'g');
      expect(result.fiber, closeTo(6.0, 0.01));
      expect(result.sugar, closeTo(10.0, 0.01));
    });

    test('returns null fiber and sugar when not set', () {
      final meal = _meal(mealUnit: 'g', fiber100: null, sugars100: null);
      final result = MealPortionCalculator.calculate(meal, 100, 'g');
      expect(result.fiber, isNull);
      expect(result.sugar, isNull);
    });
  });

  group('MealPortionCalculator - oz unit', () {
    test('converts oz to grams for calculation (1 oz ≈ 28.3495g)', () {
      final meal = _meal(mealUnit: 'oz');
      final result = MealPortionCalculator.calculate(meal, 1, 'oz');
      // 1 oz = 28.3495g, kcal per unit = 400/100 = 4, so kcal ≈ 113.4
      expect(result.kcal, closeTo(28.3495 * 4.0, 0.1));
    });
  });

  group('MealPortionCalculator - fl oz unit', () {
    test('converts fl oz to ml for calculation (1 fl oz ≈ 29.5735ml)', () {
      final meal = _meal(mealUnit: 'fl oz');
      final result = MealPortionCalculator.calculate(meal, 1, 'fl oz');
      expect(result.kcal, closeTo(29.5735 * 4.0, 0.1));
    });

    test('fl.oz alias also converts correctly', () {
      final meal = _meal(mealUnit: 'fl.oz');
      final result = MealPortionCalculator.calculate(meal, 1, 'fl.oz');
      expect(result.kcal, closeTo(29.5735 * 4.0, 0.1));
    });
  });

  group('MealPortionCalculator - serving unit', () {
    test('multiplies by servingQuantity when amount is a fraction', () {
      // servingQuantity = 250, amount = 1 (1 serving)
      final meal = _meal(mealUnit: 'serving', servingQuantity: 250.0);
      final result = MealPortionCalculator.calculate(meal, 1, 'serving');
      // amount (1) < servingQuantity (250), so not legacy
      // convertedAmount = 1 * 250 = 250
      expect(result.kcal, closeTo(250 * 4.0, 0.01));
    });

    test('legacy converted serving bypasses multiplication', () {
      // Legacy: amount stored as actual grams but unit=serving
      // if amount >= servingQuantity, treat as base units
      final meal = _meal(mealUnit: 'serving', servingQuantity: 250.0);
      final result = MealPortionCalculator.calculate(meal, 250, 'serving');
      // amount (250) >= servingQuantity (250) => legacy path
      // convertedAmount = 250 (no multiplication)
      expect(result.kcal, closeTo(250 * 4.0, 0.01));
    });

    test('no servingQuantity falls back to 1', () {
      final meal = _meal(mealUnit: 'serving', servingQuantity: null);
      final result = MealPortionCalculator.calculate(meal, 2, 'serving');
      // servingQuantity = null => 1, convertedAmount = 2*1 = 2
      expect(result.kcal, closeTo(2 * 4.0, 0.01));
    });

    test('servingQuantity <= 1 is not legacy regardless of amount', () {
      // servingQuantity = 1, amount = 1 => not legacy
      // convertedAmount = 1 * 1 = 1
      final meal = _meal(mealUnit: 'serving', servingQuantity: 1.0);
      final result = MealPortionCalculator.calculate(meal, 1, 'serving');
      expect(result.kcal, closeTo(1 * 4.0, 0.01));
    });
  });
}
