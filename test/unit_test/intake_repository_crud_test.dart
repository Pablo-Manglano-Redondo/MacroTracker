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
  group('IntakeRepository full CRUD', () {
    late Directory tempDir;
    late Box<IntakeDBO> box;
    late IntakeRepository repo;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir =
          await Directory.systemTemp.createTemp('macrotracker_hive_test_');
      Hive.init(tempDir.path);
      _registerAdapters();
      box = await Hive.openBox<IntakeDBO>('intake_test');
      repo = IntakeRepository(IntakeDataSource(box));
    });

    tearDown(() async {
      await box.close();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    IntakeEntity makeIntake(String id, DateTime dt,
        {IntakeTypeEntity type = IntakeTypeEntity.breakfast,
        double amount = 1}) {
      return IntakeEntity(
        id: id,
        unit: 'g',
        amount: amount,
        type: type,
        meal: id == '1'
            ? MealEntityFixtures.mealOne
            : id == '2'
                ? MealEntityFixtures.mealTwo
                : MealEntityFixtures.mealThree,
        dateTime: dt,
      );
    }

    test('adds and retrieves intake by id', () async {
      await repo.addIntake(makeIntake('1', DateTime.utc(2024, 1, 1)));

      final result = await repo.getIntakeById('1');

      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.amount, 1);
    });

    test('returns null for non-existent intake id', () async {
      final result = await repo.getIntakeById('non_existent');
      expect(result, isNull);
    });

    test('updates intake fields', () async {
      final intake = makeIntake('1', DateTime.utc(2024, 1, 1), amount: 100);
      await repo.addIntake(intake);

      final updated = await repo.updateIntake('1', {'amount': 200.0});

      expect(updated, isNotNull);
      expect(updated!.amount, 200);
      // Other fields remain unchanged
      expect(updated.id, '1');
    });

    test('returns null when updating non-existent intake', () async {
      final result = await repo.updateIntake('ghost', {'amount': 999});
      expect(result, isNull);
    });

    test('deletes intake by entity', () async {
      await repo.addIntake(makeIntake('1', DateTime.utc(2024, 1, 1)));
      expect(await repo.getIntakeById('1'), isNotNull);

      final saved = (await repo.getIntakeById('1'))!;
      await repo.deleteIntake(saved);

      expect(await repo.getIntakeById('1'), isNull);
    });

    test('retrieves all intakes', () async {
      await repo.addIntake(makeIntake('1', DateTime.utc(2024, 1, 1)));
      await repo.addIntake(makeIntake('2', DateTime.utc(2024, 1, 2)));
      await repo.addIntake(makeIntake('3', DateTime.utc(2024, 1, 3)));

      final all = await repo.getAllIntakes();

      expect(all.length, 3);
    });

    test('deleting non-existent intake does not throw', () async {
      final fake = makeIntake('ghost', DateTime.utc(2024, 1, 1));
      await repo.addIntake(makeIntake('1', DateTime.utc(2024, 1, 1)));

      await repo.deleteIntake(fake);

      // Existing intake should remain
      expect(await repo.getIntakeById('1'), isNotNull);
    });

    test('adds and retrieves all DBOs in batch', () async {
      final dbos = [
        IntakeDBO.fromIntakeEntity(makeIntake('1', DateTime.utc(2024, 1, 1))),
        IntakeDBO.fromIntakeEntity(makeIntake('2', DateTime.utc(2024, 1, 2))),
      ];
      await repo.addAllIntakeDBOs(dbos);

      final all = await repo.getAllIntakes();
      expect(all.length, 2);
    });

    test('retrieves intakes by date and type', () async {
      final day = DateTime.utc(2024, 1, 1);
      await repo
          .addIntake(makeIntake('1', day, type: IntakeTypeEntity.breakfast));
      await repo.addIntake(makeIntake('2', day, type: IntakeTypeEntity.lunch));
      await repo.addIntake(makeIntake('3', day.add(const Duration(days: 1)),
          type: IntakeTypeEntity.breakfast));

      final breakfastOnDay1 =
          await repo.getIntakeByDateAndType(IntakeTypeEntity.breakfast, day);

      expect(breakfastOnDay1.length, 1);
      expect(breakfastOnDay1.first.id, '1');

      final lunchOnDay1 =
          await repo.getIntakeByDateAndType(IntakeTypeEntity.lunch, day);
      expect(lunchOnDay1.length, 1);
      expect(lunchOnDay1.first.id, '2');
    });

    test('returns recent intakes in reverse chronological order', () async {
      await repo.addIntake(makeIntake('1', DateTime.utc(2024, 1, 1)));
      await repo.addIntake(makeIntake('2', DateTime.utc(2024, 1, 2)));
      await repo.addIntake(makeIntake('3', DateTime.utc(2024, 1, 3)));

      final recent = (await repo.getRecentIntake()).map((e) => e.id).toList();

      // Most recent first (newest date first)
      expect(recent.first, '3');
    });

    test('empty box returns empty lists', () async {
      final all = await repo.getAllIntakes();
      expect(all, isEmpty);

      final recent = await repo.getRecentIntake();
      expect(recent, isEmpty);

      final byDate = await repo.getIntakeByDateAndType(
          IntakeTypeEntity.breakfast, DateTime.utc(2024, 1, 1));
      expect(byDate, isEmpty);

      final byId = await repo.getIntakeById('none');
      expect(byId, isNull);
    });
  });
}

void _registerAdapters() {
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
}
