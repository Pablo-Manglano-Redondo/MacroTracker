import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import '../fixture/meal_entity_fixtures.dart';

class _FakeIntakeRepository extends Fake implements IntakeRepository {
  final List<IntakeEntity> intakes = [];

  @override
  Future<List<IntakeEntity>> getIntakeByDateAndType(IntakeTypeEntity type, DateTime date) async {
    return intakes.where((i) => i.type == type && _isSameDay(i.dateTime, date)).toList();
  }

  @override
  Future<List<IntakeEntity>> getRecentIntake() async {
    return intakes;
  }

  @override
  Future<List<IntakeEntity>> getAllIntakes() async {
    return intakes;
  }

  @override
  Future<IntakeEntity?> getIntakeById(String id) async {
    for (final i in intakes) {
      if (i.id == id) return i;
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

void main() {
  group('GetIntakeUsecase Tests', () {
    late _FakeIntakeRepository repository;
    late GetIntakeUsecase usecase;

    setUp(() {
      repository = _FakeIntakeRepository();
      usecase = GetIntakeUsecase(repository);
    });

    IntakeEntity makeIntake(String id, DateTime dt, IntakeTypeEntity type) {
      return IntakeEntity(
        id: id,
        unit: 'g',
        amount: 100,
        type: type,
        meal: MealEntityFixtures.mealOne,
        dateTime: dt,
      );
    }

    test('getBreakfastIntakeByDay returns correct breakfast intakes', () async {
      final day = DateTime(2024, 6, 15);
      final breakfast = makeIntake('1', day, IntakeTypeEntity.breakfast);
      final lunch = makeIntake('2', day, IntakeTypeEntity.lunch);
      repository.intakes.addAll([breakfast, lunch]);

      final result = await usecase.getBreakfastIntakeByDay(day);
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getTodayBreakfastIntake returns today\'s breakfast intakes', () async {
      final today = DateTime.now();
      final breakfast = makeIntake('1', today, IntakeTypeEntity.breakfast);
      final oldBreakfast = makeIntake('2', today.subtract(const Duration(days: 1)), IntakeTypeEntity.breakfast);
      repository.intakes.addAll([breakfast, oldBreakfast]);

      final result = await usecase.getTodayBreakfastIntake();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getLunchIntakeByDay returns correct lunch intakes', () async {
      final day = DateTime(2024, 6, 15);
      final breakfast = makeIntake('1', day, IntakeTypeEntity.breakfast);
      final lunch = makeIntake('2', day, IntakeTypeEntity.lunch);
      repository.intakes.addAll([breakfast, lunch]);

      final result = await usecase.getLunchIntakeByDay(day);
      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('getTodayLunchIntake returns today\'s lunch intakes', () async {
      final today = DateTime.now();
      final lunch = makeIntake('1', today, IntakeTypeEntity.lunch);
      repository.intakes.addAll([lunch]);

      final result = await usecase.getTodayLunchIntake();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getDinnerIntakeByDay returns correct dinner intakes', () async {
      final day = DateTime(2024, 6, 15);
      final dinner = makeIntake('1', day, IntakeTypeEntity.dinner);
      repository.intakes.addAll([dinner]);

      final result = await usecase.getDinnerIntakeByDay(day);
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getTodayDinnerIntake returns today\'s dinner intakes', () async {
      final today = DateTime.now();
      final dinner = makeIntake('1', today, IntakeTypeEntity.dinner);
      repository.intakes.addAll([dinner]);

      final result = await usecase.getTodayDinnerIntake();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getSnackIntakeByDay returns correct snack intakes', () async {
      final day = DateTime(2024, 6, 15);
      final snack = makeIntake('1', day, IntakeTypeEntity.snack);
      repository.intakes.addAll([snack]);

      final result = await usecase.getSnackIntakeByDay(day);
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getTodaySnackIntake returns today\'s snack intakes', () async {
      final today = DateTime.now();
      final snack = makeIntake('1', today, IntakeTypeEntity.snack);
      repository.intakes.addAll([snack]);

      final result = await usecase.getTodaySnackIntake();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getRecentIntake delegates to repository', () async {
      final day = DateTime(2024, 6, 15);
      final snack = makeIntake('1', day, IntakeTypeEntity.snack);
      repository.intakes.addAll([snack]);

      final result = await usecase.getRecentIntake();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getAllIntakes delegates to repository', () async {
      final day = DateTime(2024, 6, 15);
      final snack = makeIntake('1', day, IntakeTypeEntity.snack);
      repository.intakes.addAll([snack]);

      final result = await usecase.getAllIntakes();
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('getIntakeById delegates to repository', () async {
      final day = DateTime(2024, 6, 15);
      final snack = makeIntake('1', day, IntakeTypeEntity.snack);
      repository.intakes.addAll([snack]);

      final result = await usecase.getIntakeById('1');
      expect(result, isNotNull);
      expect(result!.id, '1');

      expect(await usecase.getIntakeById('unknown'), isNull);
    });
  });
}
