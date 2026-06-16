import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';

TrackedDayEntity _makeDay({
  double calorieGoal = 2000,
  double caloriesTracked = 2000,
  double? proteinGoal,
  double? proteinTracked,
  double? carbsGoal,
  double? carbsTracked,
  double? fatGoal,
  double? fatTracked,
}) =>
    TrackedDayEntity(
      day: DateTime(2024, 1, 1),
      calorieGoal: calorieGoal,
      caloriesTracked: caloriesTracked,
      proteinGoal: proteinGoal,
      proteinTracked: proteinTracked,
      carbsGoal: carbsGoal,
      carbsTracked: carbsTracked,
      fatGoal: fatGoal,
      fatTracked: fatTracked,
    );

void main() {
  group('TrackedDayEntity.isCalorieOnTarget', () {
    test('returns true when tracked equals goal exactly', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2000);
      expect(day.isCalorieOnTarget, isTrue);
    });

    test('returns true when tracked is under goal within 1000 kcal', () {
      // difference of 999 < maxKcalDifferenceUnderGoal(1000)
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 1001);
      expect(day.isCalorieOnTarget, isTrue);
    });

    test('returns false when tracked is under goal by exactly 1000 kcal', () {
      // difference = 1000, not < 1000
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 1000);
      expect(day.isCalorieOnTarget, isFalse);
    });

    test('returns false when tracked is under goal by more than 1000 kcal', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 500);
      expect(day.isCalorieOnTarget, isFalse);
    });

    test('returns true when tracked exceeds goal by less than 500 kcal', () {
      // difference = 499 < maxKcalDifferenceOverGoal(500)
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2499);
      expect(day.isCalorieOnTarget, isTrue);
    });

    test('returns false when tracked exceeds goal by exactly 500 kcal', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2500);
      expect(day.isCalorieOnTarget, isFalse);
    });

    test('returns false when tracked exceeds goal by more than 500 kcal', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 3000);
      expect(day.isCalorieOnTarget, isFalse);
    });
  });

  group('TrackedDayEntity.hasProteinGoal', () {
    test('returns false when proteinGoal is null', () {
      final day = _makeDay(proteinGoal: null, proteinTracked: 100);
      expect(day.hasProteinGoal, isFalse);
    });

    test('returns false when proteinGoal is zero', () {
      final day = _makeDay(proteinGoal: 0, proteinTracked: 100);
      expect(day.hasProteinGoal, isFalse);
    });

    test('returns false when proteinTracked is null', () {
      final day = _makeDay(proteinGoal: 150, proteinTracked: null);
      expect(day.hasProteinGoal, isFalse);
    });

    test('returns true when both goal and tracked are set and goal > 0', () {
      final day = _makeDay(proteinGoal: 150, proteinTracked: 120);
      expect(day.hasProteinGoal, isTrue);
    });
  });

  group('TrackedDayEntity.isProteinOnTarget', () {
    test('returns false when there is no protein goal', () {
      final day = _makeDay(proteinGoal: null, proteinTracked: 100);
      expect(day.isProteinOnTarget, isFalse);
    });

    test('returns false when tracked is below goal', () {
      final day = _makeDay(proteinGoal: 150, proteinTracked: 120);
      expect(day.isProteinOnTarget, isFalse);
    });

    test('returns true when tracked exactly meets goal', () {
      final day = _makeDay(proteinGoal: 150, proteinTracked: 150);
      expect(day.isProteinOnTarget, isTrue);
    });

    test('returns true when tracked exceeds goal', () {
      final day = _makeDay(proteinGoal: 150, proteinTracked: 180);
      expect(day.isProteinOnTarget, isTrue);
    });
  });

  group('TrackedDayEntity.calorieAdherenceScore', () {
    test('returns 1.0 when tracked equals goal exactly', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2000);
      expect(day.calorieAdherenceScore, 1.0);
    });

    test('returns 0.0 when tracked is 1000 kcal or more below goal', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 1000);
      expect(day.calorieAdherenceScore, 0.0);
    });

    test('returns 0.0 when tracked exceeds goal by 500 or more', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2500);
      expect(day.calorieAdherenceScore, 0.0);
    });

    test('returns intermediate value when partially under goal', () {
      // tracked = 1500, goal = 2000 => difference = 500, maxUnder = 1000
      // normalized = 1 - (500/1000) = 0.5
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 1500);
      expect(day.calorieAdherenceScore, closeTo(0.5, 0.001));
    });

    test('returns intermediate value when slightly over goal', () {
      // tracked = 2250, goal = 2000 => difference = 250, maxOver = 500
      // normalized = 1 - (250/500) = 0.5
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 2250);
      expect(day.calorieAdherenceScore, closeTo(0.5, 0.001));
    });

    test('score is clamped to [0, 1]', () {
      final day = _makeDay(calorieGoal: 2000, caloriesTracked: 0);
      expect(day.calorieAdherenceScore, 0.0);
    });
  });

  group('TrackedDayEntity equality', () {
    test('equal instances match', () {
      final a = _makeDay(calorieGoal: 2000, caloriesTracked: 1800);
      final b = _makeDay(calorieGoal: 2000, caloriesTracked: 1800);
      expect(a, equals(b));
    });

    test('different calorie goals are not equal', () {
      final a = _makeDay(calorieGoal: 2000, caloriesTracked: 1800);
      final b = _makeDay(calorieGoal: 1800, caloriesTracked: 1800);
      expect(a, isNot(equals(b)));
    });
  });

  group('TrackedDayEntity static constants', () {
    test('maxKcalDifferenceOverGoal is 500', () {
      expect(TrackedDayEntity.maxKcalDifferenceOverGoal, 500);
    });

    test('maxKcalDifferenceUnderGoal is 1000', () {
      expect(TrackedDayEntity.maxKcalDifferenceUnderGoal, 1000);
    });
  });
}
