import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/calc/bmr_calc.dart';

import '../fixture/user_entity_fixtures.dart';

void main() {
  group('BMRCalc - Harris-Benedict 1918', () {
    test('calculates BMR for a young sedentary male', () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final bmr = BMRCalc.getBMRHarrisBenedict1918(user);
      // 66.4730 + 13.7516*80 + 5.0033*180 - 6.7550*25
      // 66.4730 + 1100.128 + 900.594 - 168.875 = 1898.32
      expect(bmr, closeTo(1898.32, 0.1));
    });

    test('calculates BMR for a middle-aged active female', () {
      final user = UserEntityFixtures.middleAgedActiveFemaleWantingToLoseWeight;
      final bmr = BMRCalc.getBMRHarrisBenedict1918(user);
      // 655.0955 + 9.5634*75 + 1.8496*160 - 4.6756*54
      // 655.0955 + 717.255 + 295.936 - 252.4824 = 1415.80
      expect(bmr, closeTo(1415.80, 0.1));
    });
  });

  group('BMRCalc - Revised Harris-Benedict 1984', () {
    test('calculates BMR for a young sedentary male', () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final bmr = BMRCalc.getBMRRevisedHarrisBenedict1984(user);
      // 88.362 + 13.397*80 + 4.799*180 - 5.677*25
      // 88.362 + 1071.76 + 863.82 - 141.925 = 1882.017
      expect(bmr, closeTo(1882.02, 0.1));
    });

    test('calculates BMR for an elderly low-active male', () {
      final user = UserEntityFixtures.elderlyLowActiveMaleWantingToGainWeight;
      final bmr = BMRCalc.getBMRRevisedHarrisBenedict1984(user);
      expect(bmr, greaterThan(0));
    });
  });

  group('BMRCalc - Mifflin-St Jeor 1990', () {
    test('calculates BMR for a young sedentary male', () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final bmr = BMRCalc.getBMRMifflinStJeor1990(user);
      // 10*80 + 6.25*180 - 5*25 + 5
      // 800 + 1125 - 125 + 5 = 1805
      expect(bmr, closeTo(1805, 0.1));
    });

    test('calculates BMR for a middle-aged active female', () {
      final user = UserEntityFixtures.middleAgedActiveFemaleWantingToLoseWeight;
      final bmr = BMRCalc.getBMRMifflinStJeor1990(user);
      // 10*75 + 6.25*160 - 5*54 - 161
      // 750 + 1000 - 270 - 161 = 1319
      expect(bmr, closeTo(1319, 0.1));
    });
  });

  group('BMRCalc - Schofield 1985', () {
    test('calculates BMR for a young sedentary male (age 25, in 18-30 bracket)',
        () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final bmr = BMRCalc.getBMRSchofield11985(user);
      // 15.057*80 + 692.2 = 1204.56 + 692.2 = 1896.76
      expect(bmr, closeTo(1896.76, 0.1));
    });

    test('calculates BMR for a middle-aged active female (age 54, in 30-60 bracket)',
        () {
      final user = UserEntityFixtures.middleAgedActiveFemaleWantingToLoseWeight;
      final bmr = BMRCalc.getBMRSchofield11985(user);
      // 8.126*75 + 845.6 = 609.45 + 845.6 = 1455.05
      expect(bmr, closeTo(1455.05, 0.1));
    });

    test('calculates BMR for an elderly male (age 76, in 60+ bracket)', () {
      final user = UserEntityFixtures.elderlyLowActiveMaleWantingToGainWeight;
      final bmr = BMRCalc.getBMRSchofield11985(user);
      // 11.711*55 + 587.7 = 644.105 + 587.7 = 1231.805
      expect(bmr, closeTo(1231.8, 0.1));
    });

    test('calculates BMR for a young very active female (age 19, in 18-30 bracket)',
        () {
      final user =
          UserEntityFixtures.youngVeryActiveOverweightFemaleWantingToLoseWeight;
      final bmr = BMRCalc.getBMRSchofield11985(user);
      // 14.818*105 + 486.6 = 1555.89 + 486.6 = 2042.49
      expect(bmr, closeTo(2042.49, 0.1));
    });

    test('handles child age bracket (age < 18) for male', () {
      final teen = UserEntity(
        birthday: DateTime(DateTime.now().year - 16, 1, 1),
        heightCM: 170.0,
        weightKG: 60.0,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      // Schofield male 10-18: 17.686*60 + 658.2 = 1061.16 + 658.2 = 1719.36
      final bmr = BMRCalc.getBMRSchofield11985(teen);
      expect(bmr, closeTo(1719.36, 0.1));
    });
  });

  group('BMRCalc - edge cases', () {
    test('returns positive values for all equations', () {
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;

      expect(BMRCalc.getBMRHarrisBenedict1918(user), greaterThan(0));
      expect(BMRCalc.getBMRRevisedHarrisBenedict1984(user), greaterThan(0));
      expect(BMRCalc.getBMRMifflinStJeor1990(user), greaterThan(0));
      expect(BMRCalc.getBMRSchofield11985(user), greaterThan(0));
    });

    test('female BMR is consistently lower than male for same stats', () {
      final male = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, 1, 1),
        heightCM: 170.0,
        weightKG: 70.0,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      final female = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, 1, 1),
        heightCM: 170.0,
        weightKG: 70.0,
        gender: UserGenderEntity.female,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );

      for (final bmrFn in [
        BMRCalc.getBMRHarrisBenedict1918,
        BMRCalc.getBMRRevisedHarrisBenedict1984,
        BMRCalc.getBMRMifflinStJeor1990,
        BMRCalc.getBMRSchofield11985,
      ]) {
        expect(bmrFn(male), greaterThan(bmrFn(female)));
      }
    });
  });
}
