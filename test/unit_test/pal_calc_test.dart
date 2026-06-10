import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/calc/pal_calc.dart';

void main() {
  group('PalCalc.getPALValueFromActivityCategory', () {
    UserEntity _makeUser(UserPALEntity pal) => UserEntity(
          birthday: DateTime(2000, 1, 1),
          heightCM: 170,
          weightKG: 70,
          gender: UserGenderEntity.male,
          goal: UserWeightGoalEntity.maintainWeight,
          pal: pal,
        );

    test('sedentary returns 1.25', () {
      expect(PalCalc.getPALValueFromActivityCategory(_makeUser(UserPALEntity.sedentary)), 1.25);
    });

    test('low active returns 1.5', () {
      expect(PalCalc.getPALValueFromActivityCategory(_makeUser(UserPALEntity.lowActive)), 1.5);
    });

    test('active returns 1.75', () {
      expect(PalCalc.getPALValueFromActivityCategory(_makeUser(UserPALEntity.active)), 1.75);
    });

    test('very active returns 2.2', () {
      expect(PalCalc.getPALValueFromActivityCategory(_makeUser(UserPALEntity.veryActive)), 2.2);
    });
  });

  group('PalCalc.getPAValueFromPALValue', () {
    UserEntity _makeUser(UserPALEntity pal, {UserGenderEntity gender = UserGenderEntity.male}) =>
        UserEntity(
          birthday: DateTime(2000, 1, 1),
          heightCM: 170,
          weightKG: 70,
          gender: gender,
          goal: UserWeightGoalEntity.maintainWeight,
          pal: pal,
        );

    test('PAL < 1.4 returns 1.0 regardless of gender', () {
      final male = _makeUser(UserPALEntity.sedentary);
      final female = _makeUser(UserPALEntity.sedentary, gender: UserGenderEntity.female);
      expect(PalCalc.getPAValueFromPALValue(male, 1.3), 1.0);
      expect(PalCalc.getPAValueFromPALValue(female, 1.3), 1.0);
    });

    test('PAL 1.4-1.59 returns gender-specific values', () {
      final male = _makeUser(UserPALEntity.lowActive);
      final female = _makeUser(UserPALEntity.lowActive, gender: UserGenderEntity.female);
      expect(PalCalc.getPAValueFromPALValue(male, 1.5), 1.12);
      expect(PalCalc.getPAValueFromPALValue(female, 1.5), 1.14);
    });

    test('PAL 1.6-1.89 returns 1.27 for both genders', () {
      final male = _makeUser(UserPALEntity.active);
      final female = _makeUser(UserPALEntity.active, gender: UserGenderEntity.female);
      expect(PalCalc.getPAValueFromPALValue(male, 1.7), 1.27);
      expect(PalCalc.getPAValueFromPALValue(female, 1.7), 1.27);
    });

    test('PAL >= 1.9 returns gender-specific values', () {
      final male = _makeUser(UserPALEntity.veryActive);
      final female = _makeUser(UserPALEntity.veryActive, gender: UserGenderEntity.female);
      expect(PalCalc.getPAValueFromPALValue(male, 2.0), 1.54);
      expect(PalCalc.getPAValueFromPALValue(female, 2.0), 1.45);
    });

    test('exact boundary at 1.4 falls into 1.4-1.59 range', () {
      final male = _makeUser(UserPALEntity.sedentary);
      expect(PalCalc.getPAValueFromPALValue(male, 1.4), 1.12);
    });

    test('exact boundary at 1.6 falls into 1.6-1.89 range', () {
      final male = _makeUser(UserPALEntity.active);
      expect(PalCalc.getPAValueFromPALValue(male, 1.6), 1.27);
    });

    test('exact boundary at 1.9 falls into >= 1.9 range', () {
      final male = _makeUser(UserPALEntity.veryActive);
      expect(PalCalc.getPAValueFromPALValue(male, 1.9), 1.54);
    });
  });
}
