import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import '../fixture/meal_entity_fixtures.dart';

class _FakeGetIntakeUsecase extends Fake implements GetIntakeUsecase {
  final List<IntakeEntity> intakes = [];

  @override
  Future<List<IntakeEntity>> getAllIntakes() async {
    return intakes;
  }
}

void main() {
  group('GetFrequentIntakePresetsUsecase Tests', () {
    late _FakeGetIntakeUsecase getIntakeUsecase;
    late GetFrequentIntakePresetsUsecase usecase;

    setUp(() {
      getIntakeUsecase = _FakeGetIntakeUsecase();
      usecase = GetFrequentIntakePresetsUsecase(getIntakeUsecase);
    });

    IntakeEntity makeIntake({
      required String id,
      required MealEntity meal,
      required DateTime dateTime,
      double amount = 100.0,
      String unit = 'g',
      IntakeTypeEntity type = IntakeTypeEntity.breakfast,
    }) {
      return IntakeEntity(
        id: id,
        unit: unit,
        amount: amount,
        type: type,
        meal: meal,
        dateTime: dateTime,
      );
    }

    test('returns empty list when no intakes exist', () async {
      final result = await usecase.getTopPresets();
      expect(result, isEmpty);
    });

    test('excludes intakes older than cutoff (lookbackDays)', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 50));
      
      // Since a preset requires at least 2 uses, we add 2 identical old intakes
      final old1 = makeIntake(id: '1', meal: MealEntityFixtures.mealOne, dateTime: oldDate);
      final old2 = makeIntake(id: '2', meal: MealEntityFixtures.mealOne, dateTime: oldDate);
      getIntakeUsecase.intakes.addAll([old1, old2]);

      final result = await usecase.getTopPresets(lookbackDays: 45);
      expect(result, isEmpty);
    });

    test('only includes presets with at least 2 uses', () async {
      final now = DateTime.now();
      
      // Meal one has 1 use (should be excluded)
      final use1 = makeIntake(id: '1', meal: MealEntityFixtures.mealOne, dateTime: now);
      
      // Meal two has 2 uses (should be included)
      final use2 = makeIntake(id: '2', meal: MealEntityFixtures.mealTwo, dateTime: now);
      final use3 = makeIntake(id: '3', meal: MealEntityFixtures.mealTwo, dateTime: now);
      
      getIntakeUsecase.intakes.addAll([use1, use2, use3]);

      final result = await usecase.getTopPresets();
      expect(result, hasLength(1));
      expect(result.first.meal.name, MealEntityFixtures.mealTwo.name);
      expect(result.first.uses, 2);
    });

    test('sorts presets by uses descending and respects limit', () async {
      final now = DateTime.now();
      
      // Meal one has 2 uses
      final m1u1 = makeIntake(id: '1', meal: MealEntityFixtures.mealOne, dateTime: now);
      final m1u2 = makeIntake(id: '2', meal: MealEntityFixtures.mealOne, dateTime: now);
      
      // Meal two has 3 uses
      final m2u1 = makeIntake(id: '3', meal: MealEntityFixtures.mealTwo, dateTime: now);
      final m2u2 = makeIntake(id: '4', meal: MealEntityFixtures.mealTwo, dateTime: now);
      final m2u3 = makeIntake(id: '5', meal: MealEntityFixtures.mealTwo, dateTime: now);
      
      getIntakeUsecase.intakes.addAll([m1u1, m1u2, m2u1, m2u2, m2u3]);

      final resultAll = await usecase.getTopPresets();
      expect(resultAll, hasLength(2));
      expect(resultAll[0].meal.name, MealEntityFixtures.mealTwo.name); // 3 uses
      expect(resultAll[1].meal.name, MealEntityFixtures.mealOne.name); // 2 uses

      final resultLimited = await usecase.getTopPresets(limit: 1);
      expect(resultLimited, hasLength(1));
      expect(resultLimited.first.meal.name, MealEntityFixtures.mealTwo.name);
    });

    test('uses fallback title when meal name is empty or blank', () async {
      final now = DateTime.now();
      final blankMeal = MealEntity(
        code: 'blank-code',
        name: '   ',
        url: '',
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: 100,
        servingUnit: 'g',
        servingSize: '100g',
        nutriments: MealEntityFixtures.mealOne.nutriments,
        source: MealSourceEntity.custom,
      );
      
      final u1 = makeIntake(id: '1', meal: blankMeal, dateTime: now);
      final u2 = makeIntake(id: '2', meal: blankMeal, dateTime: now);
      getIntakeUsecase.intakes.addAll([u1, u2]);

      final result = await usecase.getTopPresets();
      expect(result, hasLength(1));
      expect(result.first.title, 'Frequent meal');
    });

    test('FrequentIntakePresetEntity props check', () async {
      final preset1 = FrequentIntakePresetEntity(
        key: 'k1',
        title: 'T1',
        meal: MealEntityFixtures.mealOne,
        intakeType: IntakeTypeEntity.lunch,
        unit: 'g',
        amount: 100,
        uses: 5,
      );
      final preset2 = FrequentIntakePresetEntity(
        key: 'k1',
        title: 'T1',
        meal: MealEntityFixtures.mealOne,
        intakeType: IntakeTypeEntity.lunch,
        unit: 'g',
        amount: 100,
        uses: 5,
      );
      expect(preset1, preset2);
    });
  });
}
