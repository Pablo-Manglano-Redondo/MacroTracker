import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:macrotracker/features/settings/domain/usecase/import_data_usecase.dart';

import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';

import 'package:macrotracker/core/data/dbo/user_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_ingredient_dbo.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_gender_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_pal_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

void main() {
  group('ExportDataUsecase & ImportDataUsecase Integration Tests', () {
    late ExportDataUsecase exportUsecase;
    late ImportDataUsecase importUsecase;

    late _FakeUserActivityRepository fakeUserActivityRepository;
    late _FakeIntakeRepository fakeIntakeRepository;
    late _FakeTrackedDayRepository fakeTrackedDayRepository;
    late _FakeRecipeRepository fakeRecipeRepository;
    late _FakeBodyMeasurementRepository fakeBodyMeasurementRepository;
    late _FakeDailyHabitLogRepository fakeDailyHabitLogRepository;
    late _FakeUserRepository fakeUserRepository;
    late _FakeConfigRepository fakeConfigRepository;

    late _FakeFilePicker fakeFilePicker;

    final tempZipPath = 'test_export_temp.zip';

    setUp(() {
      fakeUserActivityRepository = _FakeUserActivityRepository();
      fakeIntakeRepository = _FakeIntakeRepository();
      fakeTrackedDayRepository = _FakeTrackedDayRepository();
      fakeRecipeRepository = _FakeRecipeRepository();
      fakeBodyMeasurementRepository = _FakeBodyMeasurementRepository();
      fakeDailyHabitLogRepository = _FakeDailyHabitLogRepository();
      fakeUserRepository = _FakeUserRepository();
      fakeConfigRepository = _FakeConfigRepository();

      fakeFilePicker = _FakeFilePicker();
      FilePicker.platform = fakeFilePicker;

      exportUsecase = ExportDataUsecase(
        fakeUserActivityRepository,
        fakeIntakeRepository,
        fakeTrackedDayRepository,
        fakeRecipeRepository,
        fakeBodyMeasurementRepository,
        fakeDailyHabitLogRepository,
        fakeUserRepository,
        fakeConfigRepository,
      );

      importUsecase = ImportDataUsecase(
        fakeUserActivityRepository,
        fakeIntakeRepository,
        fakeTrackedDayRepository,
        fakeRecipeRepository,
        fakeBodyMeasurementRepository,
        fakeDailyHabitLogRepository,
        fakeUserRepository,
        fakeConfigRepository,
      );

      // Seed baseline config/user DBOs
      fakeUserRepository.userDbo = UserDBO(
        birthday: DateTime(1995, 1, 1),
        heightCM: 180.0,
        weightKG: 75.0,
        gender: UserGenderDBO.male,
        goal: UserWeightGoalDBO.maintainWeight,
        pal: UserPALDBO.sedentary,
      );

      fakeConfigRepository.configDbo = ConfigDBO(
        true,
        true,
        true,
        AppThemeDBO.system,
      );
    });

    tearDown(() {
      final file = File(tempZipPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('exports database to a valid zip file, and imports back correctly', () async {
      // 1. Seed some mock database records to export
      final testDate = DateTime(2026, 6, 15);

      fakeUserActivityRepository.dbos = [
        UserActivityDBO(
          'activity1',
          45.0,
          350.0,
          testDate,
          PhysicalActivityDBO(
            '01015',
            'Bicycling',
            'Outdoor cycling',
            8.0,
            const ['cycling'],
            PhysicalActivityTypeDBO.bicycling,
          ),
          source: 'manual',
          externalId: 'ext_act1',
        )
      ];

      fakeIntakeRepository.dbos = [
        IntakeDBO(
          id: 'intake1',
          unit: 'g',
          amount: 150.0,
          type: IntakeTypeDBO.snack,
          meal: MealDBO(
            code: 'm1',
            name: 'Apple',
            brands: 'Organic',
            thumbnailImageUrl: '',
            mainImageUrl: '',
            url: 'http://apple.com',
            mealQuantity: '1',
            mealUnit: 'piece',
            servingQuantity: 150.0,
            servingUnit: 'g',
            servingSize: '1 medium',
            nutriments: MealNutrimentsDBO(
              energyKcal100: 52.0,
              carbohydrates100: 14.0,
              fat100: 0.2,
              proteins100: 0.3,
              sugars100: 10.0,
              saturatedFat100: 0.0,
              fiber100: 2.4,
            ),
            source: MealSourceDBO.fdc,
          ),
          dateTime: testDate,
        )
      ];

      fakeTrackedDayRepository.dbos = [
        TrackedDayDBO(
          day: testDate,
          calorieGoal: 2000.0,
          caloriesTracked: 150.0,
          carbsGoal: 250.0,
          carbsTracked: 20.0,
          fatGoal: 65.0,
          fatTracked: 2.0,
          proteinGoal: 100.0,
          proteinTracked: 10.0,
        )
      ];

      fakeRecipeRepository.dbos = [
        RecipeDBO(
          id: 'recipe1',
          name: 'Fruit Salad',
          notes: 'Healthy mix',
          defaultServings: 2.0,
          yieldQuantity: 2.0,
          yieldUnit: 'serving',
          saved: true,
          pinned: false,
          timesUsed: 3,
          lastUsedAt: testDate,
          createdAt: testDate,
          updatedAt: testDate,
          ingredients: [
            RecipeIngredientDBO(
              id: 'ing1',
              mealSnapshot: MealDBO(
                code: 'm1',
                name: 'Apple',
                brands: 'Organic',
                thumbnailImageUrl: '',
                mainImageUrl: '',
                url: 'http://apple.com',
                mealQuantity: '1',
                mealUnit: 'piece',
                servingQuantity: 150.0,
                servingUnit: 'g',
                servingSize: '1 medium',
                nutriments: MealNutrimentsDBO(
                  energyKcal100: 52.0,
                  carbohydrates100: 14.0,
                  fat100: 0.2,
                  proteins100: 0.3,
                  sugars100: 10.0,
                  saturatedFat100: 0.0,
                  fiber100: 2.4,
                ),
                source: MealSourceDBO.fdc,
              ),
              amount: 150.0,
              unit: 'g',
              position: 0,
            )
          ],
          quickCategory: 'shake',
        )
      ];

      fakeBodyMeasurementRepository.dbos = [
        BodyMeasurementDBO(
          day: testDate,
          weightKg: 75.5,
          waistCm: 82.0,
          bodyFatPct: 14.5,
        )
      ];

      fakeDailyHabitLogRepository.dbos = [
        DailyHabitLogDBO(
          day: testDate,
          sleepHours: 7.5,
          steps: 8000,
          waterLiters: 2.0,
          sleepSyncedFromHealthConnect: true,
          stepsSyncedFromHealthConnect: true,
        )
      ];

      // 2. Perform Export using customOutputPath
      final exportPath = await exportUsecase.exportData(
        'export.zip',
        'activities.json',
        'intakes.json',
        'tracked_days.json',
        'recipes.json',
        'measurements.json',
        'habits.json',
        'user.json',
        'config.json',
        customOutputPath: tempZipPath,
      );

      expect(exportPath, equals(tempZipPath));
      expect(File(tempZipPath).existsSync(), isTrue);

      // 3. Perform Import by setting pickedPath on our FakeFilePicker
      fakeFilePicker.pickedPath = tempZipPath;

      final success = await importUsecase.importData(
        'activities.json',
        'intakes.json',
        'tracked_days.json',
        'recipes.json',
        'measurements.json',
        'habits.json',
        'user.json',
        'config.json',
      );

      expect(success, isTrue);

      // 4. Verify that the imported database values were correctly saved to repositories
      expect(fakeUserActivityRepository.savedDbos, hasLength(1));
      expect(fakeUserActivityRepository.savedDbos.first.id, 'activity1');
      expect(fakeUserActivityRepository.savedDbos.first.physicalActivityDBO.specificActivity, 'Bicycling');

      expect(fakeIntakeRepository.savedDbos, hasLength(1));
      expect(fakeIntakeRepository.savedDbos.first.id, 'intake1');
      expect(fakeIntakeRepository.savedDbos.first.meal.name, 'Apple');

      expect(fakeTrackedDayRepository.savedDbos, hasLength(1));
      expect(fakeTrackedDayRepository.savedDbos.first.day, testDate);
      expect(fakeTrackedDayRepository.savedDbos.first.calorieGoal, 2000.0);

      expect(fakeRecipeRepository.savedRecipes, hasLength(1));
      expect(fakeRecipeRepository.savedRecipes.first.id, 'recipe1');
      expect(fakeRecipeRepository.savedRecipes.first.name, 'Fruit Salad');

      expect(fakeBodyMeasurementRepository.savedDbos, hasLength(1));
      expect(fakeBodyMeasurementRepository.savedDbos.first.weightKg, 75.5);

      expect(fakeDailyHabitLogRepository.savedDbos, hasLength(1));
      expect(fakeDailyHabitLogRepository.savedDbos.first.steps, 8000);

      expect(fakeUserRepository.updatedUser, isNotNull);
      expect(fakeUserRepository.updatedUser?.weightKG, 75.0);

      expect(fakeConfigRepository.updatedConfig, isNotNull);
      expect(fakeConfigRepository.updatedConfig?.hasAcceptedDisclaimer, isTrue);
    });

    test('export fallback to FilePicker saveFile when customOutputPath is null', () async {
      fakeFilePicker.pickedPath = 'saved_file_via_picker.zip';
      final path = await exportUsecase.exportData(
        'export.zip',
        'activities.json',
        'intakes.json',
        'tracked_days.json',
        'recipes.json',
        'measurements.json',
        'habits.json',
        'user.json',
        'config.json',
        customOutputPath: null,
      );

      expect(path, equals('saved_file_via_picker.zip'));
    });

    test('import throws exception when pickFiles returns null', () async {
      fakeFilePicker.pickedPath = null; // simulate cancel

      expect(
        () => importUsecase.importData(
          'activities.json',
          'intakes.json',
          'tracked_days.json',
          'recipes.json',
          'measurements.json',
          'habits.json',
          'user.json',
          'config.json',
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No file selected'))),
      );
    });
  });
}

class _FakeUserActivityRepository implements UserActivityRepository {
  List<UserActivityDBO> dbos = [];
  List<UserActivityDBO> savedDbos = [];

  @override
  Future<List<UserActivityDBO>> getAllUserActivityDBO() async => dbos;

  @override
  Future<void> addAllUserActivityDBOs(List<UserActivityDBO> list) async {
    savedDbos.addAll(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeIntakeRepository implements IntakeRepository {
  List<IntakeDBO> dbos = [];
  List<IntakeDBO> savedDbos = [];

  @override
  Future<List<IntakeDBO>> getAllIntakesDBO() async => dbos;

  @override
  Future<void> addAllIntakeDBOs(List<IntakeDBO> list) async {
    savedDbos.addAll(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTrackedDayRepository implements TrackedDayRepository {
  List<TrackedDayDBO> dbos = [];
  List<TrackedDayDBO> savedDbos = [];

  @override
  Future<List<TrackedDayDBO>> getAllTrackedDaysDBO() async => dbos;

  @override
  Future<void> addAllTrackedDays(List<TrackedDayDBO> list) async {
    savedDbos.addAll(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecipeRepository implements RecipeRepository {
  List<RecipeDBO> dbos = [];
  List<RecipeEntity> savedRecipes = [];

  @override
  Future<List<RecipeDBO>> getAllRecipesDBO() async => dbos;

  @override
  Future<void> saveRecipe(RecipeEntity recipe) async {
    savedRecipes.add(recipe);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBodyMeasurementRepository implements BodyMeasurementRepository {
  List<BodyMeasurementDBO> dbos = [];
  List<BodyMeasurementDBO> savedDbos = [];

  @override
  Future<List<BodyMeasurementDBO>> getAllMeasurementsDBO() async => dbos;

  @override
  Future<void> addAllMeasurements(List<BodyMeasurementDBO> list) async {
    savedDbos.addAll(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDailyHabitLogRepository implements DailyHabitLogRepository {
  List<DailyHabitLogDBO> dbos = [];
  List<DailyHabitLogDBO> savedDbos = [];

  @override
  Future<List<DailyHabitLogDBO>> getAllLogsDBO() async => dbos;

  @override
  Future<void> addAllLogs(List<DailyHabitLogDBO> list) async {
    savedDbos.addAll(list);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  late UserDBO userDbo;
  UserEntity? updatedUser;

  @override
  Future<UserDBO> getUserDBO() async => userDbo;

  @override
  Future<void> updateUserData(UserEntity entity) async {
    updatedUser = entity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConfigRepository implements ConfigRepository {
  late ConfigDBO configDbo;
  ConfigEntity? updatedConfig;

  @override
  Future<ConfigDBO> getConfigDBO() async => configDbo;

  @override
  Future<void> updateConfig(ConfigEntity entity) async {
    updatedConfig = entity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFilePicker extends FilePicker {
  String? pickedPath;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    int? compressionQuality,
  }) async {
    final path = pickedPath;
    if (path == null) return null;
    return FilePickerResult([
      PlatformFile(
        path: path,
        name: 'test.zip',
        size: 100,
        bytes: null,
        readStream: null,
      )
    ]);
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    return pickedPath;
  }
}
