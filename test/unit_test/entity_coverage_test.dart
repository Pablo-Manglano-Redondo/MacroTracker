import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/ai_food_memory_entry.dart';

void main() {
  group('Entity Coverage Tests', () {
    test('ConfigEntity fields and props', () {
      const config1 = ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.dark,
        usesImperialUnits: true,
      );

      expect(config1.hasAcceptedDisclaimer, isTrue);
      expect(config1.hasAcceptedPolicy, isTrue);
      expect(config1.hasAcceptedSendAnonymousData, isTrue);
      expect(config1.appTheme, equals(AppThemeEntity.dark));
      expect(config1.usesImperialUnits, isTrue);
      expect(config1.props, contains(true));
    });

    test('MealNutrimentsEntity methods', () {
      final emptyNutr = MealNutrimentsEntity.empty();
      expect(emptyNutr.energyKcal100, isNull);
      expect(emptyNutr.energyPerUnit, isNull);

      const nutr = MealNutrimentsEntity(
        energyKcal100: 150,
        carbohydrates100: 20,
        fat100: 5,
        proteins100: 10,
        sugars100: 2,
        saturatedFat100: 1,
        fiber100: 3,
      );

      expect(nutr.energyPerUnit, equals(1.5));
      expect(nutr.carbohydratesPerUnit, equals(0.2));
      expect(nutr.fatPerUnit, equals(0.05));
      expect(nutr.proteinsPerUnit, equals(0.1));
      expect(nutr.sugarsPerUnit, equals(0.02));
      expect(nutr.saturatedFatPerUnit, equals(0.01));
      expect(nutr.fiberPerUnit, equals(0.03));
      expect(nutr.props, contains(150.0));
    });

    test('MealEntity methods', () {
      final meal1 = MealEntity.empty();
      expect(meal1.code, isNotNull);
      expect(meal1.name, isNull);
      expect(meal1.isLiquid, isFalse);
      expect(meal1.isSolid, isFalse);

      final meal2 = MealEntity(
        code: 'm2',
        name: 'Orange Juice',
        url: 'url',
        mealQuantity: '200',
        mealUnit: 'ml',
        servingQuantity: 200,
        servingUnit: 'ml',
        servingSize: '1 glass',
        nutriments: MealNutrimentsEntity.empty(),
        source: MealSourceEntity.custom,
      );

      expect(meal2.isLiquid, isTrue);
      expect(meal2.isSolid, isFalse);
      expect(meal2.props, contains('m2'));
      expect(meal2.props, contains('Orange Juice'));
    });

    test('AiFoodMemoryEntry map conversion and copyWith', () {
      final entry = AiFoodMemoryEntry(
        key: 'banana',
        displayLabel: 'Banana Display',
        amount: 1,
        unit: 'unit',
        kcal: 89,
        carbs: 23,
        fat: 0.3,
        protein: 1.1,
        mealSnapshot: MealEntity(
          code: 'm1',
          name: 'Banana',
          url: 'url',
          mealQuantity: '120',
          mealUnit: 'g',
          servingQuantity: 120,
          servingUnit: 'g',
          servingSize: '1 medium',
          nutriments: const MealNutrimentsEntity(
            energyKcal100: 74,
            carbohydrates100: 19,
            fat100: 0.3,
            proteins100: 0.9,
            sugars100: 12,
            saturatedFat100: 0.1,
            fiber100: 2.6,
          ),
          source: MealSourceEntity.custom,
        ),
        uses: 5,
        updatedAt: DateTime(2026, 6, 16),
      );

      final map = entry.toMap();
      expect(map['displayLabel'], equals('Banana Display'));
      expect(map['amount'], equals(1.0));
      expect(map['uses'], equals(5));

      final parsed = AiFoodMemoryEntry.fromMap('banana', map);
      expect(parsed.key, equals('banana'));
      expect(parsed.displayLabel, equals('Banana Display'));
      expect(parsed.kcal, equals(89.0));
      expect(parsed.mealSnapshot, isNotNull);
      expect(parsed.mealSnapshot!.name, equals('Banana'));
      expect(parsed.mealSnapshot!.nutriments.energyKcal100, equals(74.0));
      expect(parsed.uses, equals(5));
      expect(parsed.updatedAt, equals(DateTime(2026, 6, 16)));

      final copied = entry.copyWith(
        displayLabel: 'New Label',
        uses: 6,
      );
      expect(copied.displayLabel, equals('New Label'));
      expect(copied.uses, equals(6));
      expect(copied.key, equals('banana'));
    });
  });
}
