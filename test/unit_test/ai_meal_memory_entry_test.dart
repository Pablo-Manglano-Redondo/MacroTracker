import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/ai_meal_memory_entry.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('AiMealMemoryEntry Tests', () {
    test('serialization and deserialization roundtrip', () {
      final now = DateTime(2026, 6, 16, 12, 0, 0);
      final entry = AiMealMemoryEntry(
        key: 'shake',
        title: 'Post-workout Shake',
        searchText: 'shake whey banana',
        intakeType: IntakeTypeEntity.snack,
        mealSnapshot: MealEntityFixtures.mealOne,
        defaultAmount: 2.5,
        defaultUnit: 'scoops',
        uses: 4,
        updatedAt: now,
      );

      final map = entry.toMap();
      expect(map['title'], 'Post-workout Shake');
      expect(map['searchText'], 'shake whey banana');
      expect(map['intakeType'], 'snack');
      expect(map['defaultAmount'], 2.5);
      expect(map['defaultUnit'], 'scoops');
      expect(map['uses'], 4);
      expect(map['updatedAt'], now.toIso8601String());
      expect(map['mealSnapshot'], isA<Map>());

      final deserialized = AiMealMemoryEntry.fromMap('shake', map);
      expect(deserialized.key, 'shake');
      expect(deserialized.title, 'Post-workout Shake');
      expect(deserialized.searchText, 'shake whey banana');
      expect(deserialized.intakeType, IntakeTypeEntity.snack);
      expect(deserialized.defaultAmount, 2.5);
      expect(deserialized.defaultUnit, 'scoops');
      expect(deserialized.uses, 4);
      expect(deserialized.updatedAt, now);
      expect(deserialized.mealSnapshot.name, MealEntityFixtures.mealOne.name);

      expect(deserialized, entry);
    });

    test('fromMap with missing values uses default fallbacks', () {
      final raw = <dynamic, dynamic>{};
      final entry = AiMealMemoryEntry.fromMap('custom-key', raw);

      expect(entry.key, 'custom-key');
      expect(entry.title, 'custom-key');
      expect(entry.searchText, '');
      expect(entry.intakeType, IntakeTypeEntity.breakfast);
      expect(entry.defaultAmount, 1.0);
      expect(entry.defaultUnit, 'serving');
      expect(entry.uses, 1);
      expect(
          entry.updatedAt
              .isBefore(DateTime.now().add(const Duration(seconds: 1))),
          isTrue);
    });
  });
}
