import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/utils/calc/macro_calc.dart';

void main() {
  group('MacroCalc', () {
    test('getTotalCarbsGoal uses default 60% when no user goal provided', () {
      final carbs = MacroCalc.getTotalCarbsGoal(2000);
      // 2000 * 0.6 / 4 = 300
      expect(carbs, closeTo(300, 0.1));
    });

    test('getTotalCarbsGoal uses custom percentage when provided', () {
      final carbs = MacroCalc.getTotalCarbsGoal(2000, userCarbsGoal: 0.5);
      // 2000 * 0.5 / 4 = 250
      expect(carbs, closeTo(250, 0.1));
    });

    test('getTotalFatsGoal uses default 25% when no user goal provided', () {
      final fats = MacroCalc.getTotalFatsGoal(2000);
      // 2000 * 0.25 / 9 = 55.55
      expect(fats, closeTo(55.56, 0.1));
    });

    test('getTotalFatsGoal uses custom percentage when provided', () {
      final fats = MacroCalc.getTotalFatsGoal(2000, userFatsGoal: 0.3);
      // 2000 * 0.3 / 9 = 66.67
      expect(fats, closeTo(66.67, 0.1));
    });

    test('getTotalProteinsGoal uses default 15% when no user goal provided', () {
      final proteins = MacroCalc.getTotalProteinsGoal(2000);
      // 2000 * 0.15 / 4 = 75
      expect(proteins, closeTo(75, 0.1));
    });

    test('getTotalProteinsGoal uses custom percentage when provided', () {
      final proteins = MacroCalc.getTotalProteinsGoal(2000, userProteinsGoal: 0.25);
      // 2000 * 0.25 / 4 = 125
      expect(proteins, closeTo(125, 0.1));
    });

    test('zero calorie goal results in zero macros', () {
      expect(MacroCalc.getTotalCarbsGoal(0), 0);
      expect(MacroCalc.getTotalFatsGoal(0), 0);
      expect(MacroCalc.getTotalProteinsGoal(0), 0);
    });

    test('percentages always sum to 100% with defaults', () {
      const double kcal = 2500;
      final carbs = MacroCalc.getTotalCarbsGoal(kcal);
      final fats = MacroCalc.getTotalFatsGoal(kcal);
      final proteins = MacroCalc.getTotalProteinsGoal(kcal);

      final totalKcalFromMacros = carbs * 4 + fats * 9 + proteins * 4;
      expect(totalKcalFromMacros, closeTo(kcal, 1));
    });

    test('custom percentages sum correctly', () {
      const double kcal = 1800;
      final carbs = MacroCalc.getTotalCarbsGoal(kcal, userCarbsGoal: 0.4);
      final fats = MacroCalc.getTotalFatsGoal(kcal, userFatsGoal: 0.3);
      final proteins = MacroCalc.getTotalProteinsGoal(kcal, userProteinsGoal: 0.3);

      expect(carbs * 4 + fats * 9 + proteins * 4, closeTo(kcal, 1));
    });
  });
}
