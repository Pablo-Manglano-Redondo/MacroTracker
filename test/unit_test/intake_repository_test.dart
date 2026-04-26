import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/data_source/intake_data_source.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('IntakeRepository test', () {
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir =
          await Directory.systemTemp.createTemp('macrotracker_hive_test_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(IntakeDBOAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(IntakeTypeDBOAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(MealDBOAdapter());
      }
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(MealSourceDBOAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MealNutrimentsDBOAdapter());
      }
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns last added first', () async {
      final box = await Hive.openBox<IntakeDBO>('intake_test');

      final repo = IntakeRepository(IntakeDataSource(box));

      await repo.addIntake(IntakeEntity(
          id: "1",
          unit: "g",
          amount: 1,
          type: IntakeTypeEntity.breakfast,
          meal: MealEntityFixtures.mealOne,
          dateTime: DateTime.utc(2024, 1, 1, 0, 0, 0)));
      await repo.addIntake(IntakeEntity(
          id: "2",
          unit: "g",
          amount: 1,
          type: IntakeTypeEntity.breakfast,
          meal: MealEntityFixtures.mealTwo,
          dateTime: DateTime.utc(2024, 1, 2, 0, 0, 0)));
      await repo.addIntake(IntakeEntity(
          id: "3",
          unit: "g",
          amount: 1,
          type: IntakeTypeEntity.breakfast,
          meal: MealEntityFixtures.mealThree,
          dateTime: DateTime.utc(2024, 1, 3, 0, 0, 0)));

      final recents = (await repo.getRecentIntake()).map((e) => e.id).toList();
      expect(recents, List.from(["3", "2", "1"]));
    });
  });
}
