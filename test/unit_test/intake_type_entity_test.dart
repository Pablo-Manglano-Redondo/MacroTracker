import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';

void main() {
  group('IntakeTypeEntity DBO round-trip', () {
    test('breakfast round-trips correctly', () {
      final dbo = IntakeTypeDBO.breakfast;
      final entity = IntakeTypeEntity.fromIntakeTypeDBO(dbo);
      final back = IntakeTypeDBO.fromIntakeTypeEntity(entity);
      expect(entity, IntakeTypeEntity.breakfast);
      expect(back, IntakeTypeDBO.breakfast);
    });

    test('lunch round-trips correctly', () {
      final entity = IntakeTypeEntity.fromIntakeTypeDBO(IntakeTypeDBO.lunch);
      expect(entity, IntakeTypeEntity.lunch);
      expect(
          IntakeTypeDBO.fromIntakeTypeEntity(entity), IntakeTypeDBO.lunch);
    });

    test('dinner round-trips correctly', () {
      final entity = IntakeTypeEntity.fromIntakeTypeDBO(IntakeTypeDBO.dinner);
      expect(entity, IntakeTypeEntity.dinner);
      expect(
          IntakeTypeDBO.fromIntakeTypeEntity(entity), IntakeTypeDBO.dinner);
    });

    test('snack round-trips correctly', () {
      final entity = IntakeTypeEntity.fromIntakeTypeDBO(IntakeTypeDBO.snack);
      expect(entity, IntakeTypeEntity.snack);
      expect(
          IntakeTypeDBO.fromIntakeTypeEntity(entity), IntakeTypeDBO.snack);
    });
  });

  group('IntakeTypeEntity.getIconData', () {
    test('breakfast returns bakery icon', () {
      expect(
        IntakeTypeEntity.breakfast.getIconData(),
        Icons.bakery_dining_outlined,
      );
    });

    test('lunch returns lunch_dining icon', () {
      expect(
        IntakeTypeEntity.lunch.getIconData(),
        Icons.lunch_dining_outlined,
      );
    });

    test('dinner returns dinner_dining icon', () {
      expect(
        IntakeTypeEntity.dinner.getIconData(),
        Icons.dinner_dining_outlined,
      );
    });

    test('snack returns non-null icon', () {
      expect(IntakeTypeEntity.snack.getIconData(), isA<IconData>());
    });
  });

  group('GymTargetsEntity', () {
    test('equality holds for same values', () {
      const a = GymTargetsEntity(
        kcalGoal: 2500,
        carbsGoal: 300,
        fatGoal: 80,
        proteinGoal: 180,
      );
      const b = GymTargetsEntity(
        kcalGoal: 2500,
        carbsGoal: 300,
        fatGoal: 80,
        proteinGoal: 180,
      );
      expect(a, equals(b));
    });

    test('inequality for different values', () {
      const a = GymTargetsEntity(
        kcalGoal: 2500,
        carbsGoal: 300,
        fatGoal: 80,
        proteinGoal: 180,
      );
      const b = GymTargetsEntity(
        kcalGoal: 2000,
        carbsGoal: 250,
        fatGoal: 70,
        proteinGoal: 160,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
