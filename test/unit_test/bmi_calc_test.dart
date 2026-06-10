import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
import 'package:macrotracker/core/utils/calc/bmi_calc.dart';

import '../fixture/user_entity_fixtures.dart';

void main() {
  group('BMICalc', () {
    test('calculates BMI for a young sedentary male (180cm, 80kg)', () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final bmi = BMICalc.getBMI(user);
      // 80 / (1.80^2) = 80 / 3.24 = 24.69
      expect(bmi, closeTo(24.69, 0.1));
    });

    test('calculates BMI for a middle-aged active female (160cm, 75kg)', () {
      final user = UserEntityFixtures.middleAgedActiveFemaleWantingToLoseWeight;
      final bmi = BMICalc.getBMI(user);
      // 75 / (1.60^2) = 75 / 2.56 = 29.30
      expect(bmi, closeTo(29.30, 0.1));
    });

    test('calculates BMI for an overweight female (190cm, 105kg)', () {
      final user =
          UserEntityFixtures.youngVeryActiveOverweightFemaleWantingToLoseWeight;
      final bmi = BMICalc.getBMI(user);
      // 105 / (1.90^2) = 105 / 3.61 = 29.09
      expect(bmi, closeTo(29.09, 0.1));
    });
  });

  group('BMICalc.getNutritionalStatus', () {
    test('returns underweight for BMI < 18.5', () {
      expect(BMICalc.getNutritionalStatus(16.0),
          UserNutritionalStatus.underWeight);
      expect(BMICalc.getNutritionalStatus(18.4),
          UserNutritionalStatus.underWeight);
    });

    test('returns normal weight for BMI 18.5 - 24.9', () {
      expect(BMICalc.getNutritionalStatus(18.5),
          UserNutritionalStatus.normalWeight);
      expect(BMICalc.getNutritionalStatus(22.0),
          UserNutritionalStatus.normalWeight);
      expect(BMICalc.getNutritionalStatus(24.9),
          UserNutritionalStatus.normalWeight);
    });

    test('returns pre-obesity for BMI 25.0 - 29.9', () {
      expect(BMICalc.getNutritionalStatus(25.0),
          UserNutritionalStatus.preObesity);
      expect(BMICalc.getNutritionalStatus(27.5),
          UserNutritionalStatus.preObesity);
      expect(BMICalc.getNutritionalStatus(29.9),
          UserNutritionalStatus.preObesity);
    });

    test('returns obesity class I for BMI 30.0 - 34.9', () {
      expect(BMICalc.getNutritionalStatus(30.0),
          UserNutritionalStatus.obesityClassI);
      expect(BMICalc.getNutritionalStatus(32.0),
          UserNutritionalStatus.obesityClassI);
      expect(BMICalc.getNutritionalStatus(34.9),
          UserNutritionalStatus.obesityClassI);
    });

    test('returns obesity class II for BMI 35.0 - 39.9', () {
      expect(BMICalc.getNutritionalStatus(35.0),
          UserNutritionalStatus.obesityClassII);
      expect(BMICalc.getNutritionalStatus(37.0),
          UserNutritionalStatus.obesityClassII);
      expect(BMICalc.getNutritionalStatus(39.9),
          UserNutritionalStatus.obesityClassII);
    });

    test('returns obesity class III for BMI >= 40.0', () {
      expect(BMICalc.getNutritionalStatus(40.0),
          UserNutritionalStatus.obesityClassIII);
      expect(BMICalc.getNutritionalStatus(45.0),
          UserNutritionalStatus.obesityClassIII);
    });

    test('handles boundary values correctly', () {
      expect(BMICalc.getNutritionalStatus(18.5),
          UserNutritionalStatus.normalWeight);
      expect(BMICalc.getNutritionalStatus(25.0),
          UserNutritionalStatus.preObesity);
      expect(BMICalc.getNutritionalStatus(30.0),
          UserNutritionalStatus.obesityClassI);
      expect(BMICalc.getNutritionalStatus(35.0),
          UserNutritionalStatus.obesityClassII);
      expect(BMICalc.getNutritionalStatus(40.0),
          UserNutritionalStatus.obesityClassIII);
    });
  });
}
