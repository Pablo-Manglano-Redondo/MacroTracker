import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import '../fixture/user_entity_fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTrackedDayRepository extends Fake implements TrackedDayRepository {
  final Map<String, TrackedDayDBO> _store = {};
  int updateCalorieGoalCalls = 0;
  int updateMacroGoalCalls = 0;
  int addNewTrackedDayCalls = 0;
  DateTime? lastUpdatedDay;
  double? lastCalorieGoal;

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Future<bool> hasTrackedDay(DateTime day) async =>
      _store.containsKey(_key(day));

  @override
  Future<TrackedDayEntity?> getTrackedDay(DateTime day) async {
    final dbo = _store[_key(day)];
    if (dbo == null) return null;
    return TrackedDayEntity.fromTrackedDayDBO(dbo);
  }

  @override
  Future<void> addNewTrackedDay(DateTime day, double totalKcalGoal,
      double totalCarbsGoal, double totalFatGoal, double totalProteinGoal) async {
    addNewTrackedDayCalls++;
    _store[_key(day)] = TrackedDayDBO(
      day: day,
      calorieGoal: totalKcalGoal,
      caloriesTracked: 0,
      carbsGoal: totalCarbsGoal,
      carbsTracked: 0,
      fatGoal: totalFatGoal,
      fatTracked: 0,
      proteinGoal: totalProteinGoal,
      proteinTracked: 0,
    );
  }

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double calorieGoal) async {
    updateCalorieGoalCalls++;
    lastUpdatedDay = day;
    lastCalorieGoal = calorieGoal;
    final dbo = _store[_key(day)];
    if (dbo != null) dbo.calorieGoal = calorieGoal;
  }

  @override
  Future<void> updateDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {
    updateMacroGoalCalls++;
  }

  @override
  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {}

  @override
  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {}

  @override
  Future<void> addDayTrackedCalories(DateTime day, double calories) async {}

  @override
  Future<void> removeDayTrackedCalories(DateTime day, double calories) async {}

  @override
  Future<void> increaseDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {}

  @override
  Future<void> reduceDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {}

  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}

  @override
  Future<void> removeDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
}

class _FakeUpdateHomeWidgetUsecase extends Fake
    implements UpdateHomeWidgetUsecase {
  int refreshCalls = 0;
  @override
  Future<void> refreshToday() async => refreshCalls++;
}

class _FakeConfigRepository extends Fake implements ConfigRepository {
  ConfigDBO _dbo = ConfigDBO.empty();

  void seedWithMacroMode(MacroGoalModeEntity mode,
      {double? carbGramPerKg, double? proteinGramPerKg, double? fatGramPerKg}) {
    _dbo = ConfigDBO.empty()
      ..macroGoalMode = mode.storageValue
      ..userCarbGoalGramPerKg = carbGramPerKg
      ..userProteinGoalGramPerKg = proteinGramPerKg
      ..userFatGoalGramPerKg = fatGramPerKg;
  }

  void seedWithPctMode(
      {double? carbPct, double? proteinPct, double? fatPct}) {
    _dbo = ConfigDBO.empty()
      ..macroGoalMode = MacroGoalModeEntity.percentage.storageValue
      ..userCarbGoalPct = carbPct
      ..userProteinGoalPct = proteinPct
      ..userFatGoalPct = fatPct;
  }

  @override
  Future<ConfigEntity> getConfig() async =>
      ConfigEntity.fromConfigDBO(_dbo);

  @override
  Future<void> updateConfig(ConfigEntity configEntity) async {
    _dbo = ConfigDBO.fromConfigEntity(configEntity);
  }

  @override
  Future<void> setConfigDisclaimer(bool v) async =>
      _dbo.hasAcceptedDisclaimer = v;

  @override
  Future<void> setConfigHasAcceptedAnonymousData(bool v) async =>
      _dbo.hasAcceptedSendAnonymousData = v;

  @override
  Future<void> setConfigAppTheme(AppThemeEntity t) async =>
      _dbo.selectedAppTheme = AppThemeDBO.fromAppThemeEntity(t);

  @override
  Future<void> setConfigLocale(String? locale) async =>
      _dbo.selectedLocale = locale;

  @override
  Future<void> setConfigUsesImperialUnits(bool v) async =>
      _dbo.usesImperialUnits = v;

  @override
  Future<void> setConfigKcalAdjustment(double v) async =>
      _dbo.userKcalAdjustment = v;

  @override
  Future<void> setUserMacroPct(double carbs, double protein, double fat) async {
    _dbo.userCarbGoalPct = carbs;
    _dbo.userProteinGoalPct = protein;
    _dbo.userFatGoalPct = fat;
  }

  @override
  Future<void> setUserMacroGoalsGramPerKg(
      double carbs, double protein, double fat) async {
    _dbo.userCarbGoalGramPerKg = carbs;
    _dbo.userProteinGoalGramPerKg = protein;
    _dbo.userFatGoalGramPerKg = fat;
  }

  @override
  Future<void> setMacroGoalMode(MacroGoalModeEntity mode) async =>
      _dbo.macroGoalMode = mode.storageValue;

  @override
  Future<void> setDailyFocus(DailyFocusEntity focus) async =>
      _dbo.dailyFocus = focus.storageValue;

  @override
  Future<void> setTrainingDayTemplate(TrainingDayTemplateEntity t) async =>
      _dbo.trainingDayTemplate = t.storageValue;

  @override
  Future<void> setHealthConnectAutoSyncEnabled(bool v) async =>
      _dbo.healthConnectAutoSyncEnabled = v;

  @override
  Future<void> setMealReminderConfig({
    required bool enabled,
    required int morningMinutes,
    required int lunchMinutes,
    required int afternoonMinutes,
    required int eveningMinutes,
  }) async {
    _dbo.mealRemindersEnabled = enabled;
  }

  @override
  Future<void> setGoogleDriveAutoBackupEnabled(bool v) async =>
      _dbo.googleDriveAutoBackupEnabled = v;

  @override
  Future<void> setGoogleDriveBackupStatus({
    required String attemptedAtIso,
    String? successAtIso,
    String? errorMessage,
  }) async {
    _dbo.googleDriveLastBackupAttemptAt = attemptedAtIso;
    _dbo.googleDriveLastBackupSuccessAt = successAtIso;
    _dbo.googleDriveLastBackupError = errorMessage;
  }

  @override
  Future<void> addDiscardedHealthConnectActivityId(String id) async {
    final list = List<String>.from(_dbo.discardedHealthConnectActivityIds ?? []);
    list.add(id);
    _dbo.discardedHealthConnectActivityIds = list;
  }

  @override
  Future<void> addAiEstimatedCost({
    required bool isPhoto,
    required double usdCost,
  }) async {
    _dbo.aiEstimatedCostTotalUsd = (_dbo.aiEstimatedCostTotalUsd ?? 0) + usdCost;
  }

  @override
  Future<void> resetAiCostTracking() async {
    _dbo.aiEstimatedCostTotalUsd = 0;
    _dbo.aiEstimatedCostTodayUsd = 0;
    _dbo.aiEstimatedCostMonthUsd = 0;
    _dbo.aiTextCallsTotal = 0;
    _dbo.aiPhotoCallsTotal = 0;
  }
}

class _FakeUserRepository extends Fake implements UserRepository {
  final _user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
  @override
  Future<UserEntity> getUserData() async => _user;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── AddTrackedDayUsecase ──────────────────────────────────────────────────
  group('AddTrackedDayUsecase', () {
    late _FakeTrackedDayRepository repo;
    late _FakeUpdateHomeWidgetUsecase widget;
    late AddTrackedDayUsecase usecase;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    setUp(() {
      repo = _FakeTrackedDayRepository();
      widget = _FakeUpdateHomeWidgetUsecase();
      usecase = AddTrackedDayUsecase(repo, widget);
    });

    test('hasTrackedDay returns false when no day stored', () async {
      expect(await usecase.hasTrackedDay(today), isFalse);
    });

    test('addNewTrackedDay stores the day and triggers widget refresh for today',
        () async {
      await usecase.addNewTrackedDay(today, 2000, 300, 55, 100);
      expect(repo.addNewTrackedDayCalls, 1);
      expect(await usecase.hasTrackedDay(today), isTrue);
      expect(widget.refreshCalls, 1);
    });

    test('addNewTrackedDay for a past day does NOT refresh the widget',
        () async {
      await usecase.addNewTrackedDay(yesterday, 2000, 300, 55, 100);
      expect(widget.refreshCalls, 0);
    });

    test('updateDayCalorieGoal delegates and refreshes widget for today',
        () async {
      await usecase.addNewTrackedDay(today, 2000, 300, 55, 100);
      widget.refreshCalls = 0; // reset counter

      await usecase.updateDayCalorieGoal(today, 2200);
      expect(repo.updateCalorieGoalCalls, 1);
      expect(repo.lastCalorieGoal, 2200);
      expect(widget.refreshCalls, 1);
    });

    test('updateDayCalorieGoal for past day does NOT refresh widget', () async {
      await usecase.updateDayCalorieGoal(yesterday, 1800);
      expect(widget.refreshCalls, 0);
    });

    test('updateDayMacroGoals delegates to repository', () async {
      await usecase.updateDayMacroGoals(today,
          carbsGoal: 300, fatGoal: 70, proteinGoal: 150);
      expect(repo.updateMacroGoalCalls, 1);
    });

    test('addDayCaloriesTracked delegates and refreshes today', () async {
      await usecase.addDayCaloriesTracked(today, 500);
      expect(widget.refreshCalls, 1);
    });

    test('removeDayCaloriesTracked delegates and refreshes today', () async {
      await usecase.removeDayCaloriesTracked(today, 200);
      expect(widget.refreshCalls, 1);
    });

    test('increaseDayCalorieGoal delegates and refreshes today', () async {
      await usecase.increaseDayCalorieGoal(today, 100);
      expect(widget.refreshCalls, 1);
    });

    test('reduceDayCalorieGoal delegates and refreshes today', () async {
      await usecase.reduceDayCalorieGoal(today, 100);
      expect(widget.refreshCalls, 1);
    });

    test('increaseDayMacroGoals delegates and refreshes today', () async {
      await usecase.increaseDayMacroGoals(today, carbsAmount: 10);
      expect(widget.refreshCalls, 1);
    });

    test('reduceDayMacroGoals delegates and refreshes today', () async {
      await usecase.reduceDayMacroGoals(today, fatAmount: 5);
      expect(widget.refreshCalls, 1);
    });

    test('addDayMacrosTracked delegates and refreshes today', () async {
      await usecase.addDayMacrosTracked(today, carbsTracked: 30);
      expect(widget.refreshCalls, 1);
    });

    test('removeDayMacrosTracked delegates and refreshes today', () async {
      await usecase.removeDayMacrosTracked(today, proteinTracked: 20);
      expect(widget.refreshCalls, 1);
    });
  });

  // ── AddConfigUsecase ──────────────────────────────────────────────────────
  group('AddConfigUsecase', () {
    late _FakeConfigRepository repo;
    late AddConfigUsecase usecase;

    setUp(() {
      repo = _FakeConfigRepository();
      usecase = AddConfigUsecase(repo);
    });

    test('addConfig persists entire ConfigEntity', () async {
      final entity = ConfigEntity(
        true, true, false, AppThemeEntity.dark,
        usesImperialUnits: true,
      );
      await usecase.addConfig(entity);
      final stored = await repo.getConfig();
      expect(stored.hasAcceptedDisclaimer, isTrue);
      expect(stored.usesImperialUnits, isTrue);
    });

    test('setConfigDisclaimer updates disclaimer field', () async {
      await usecase.setConfigDisclaimer(true);
      expect((await repo.getConfig()).hasAcceptedDisclaimer, isTrue);
      await usecase.setConfigDisclaimer(false);
      expect((await repo.getConfig()).hasAcceptedDisclaimer, isFalse);
    });

    test('setConfigHasAcceptedAnonymousData updates field', () async {
      await usecase.setConfigHasAcceptedAnonymousData(true);
      expect((await repo.getConfig()).hasAcceptedSendAnonymousData, isTrue);
    });

    test('setConfigAppTheme updates theme', () async {
      await usecase.setConfigAppTheme(AppThemeEntity.light);
      expect((await repo.getConfig()).appTheme, AppThemeEntity.light);
    });

    test('setConfigLocale sets and clears locale', () async {
      await usecase.setConfigLocale('es');
      expect((await repo.getConfig()).selectedLocale, 'es');
      await usecase.setConfigLocale(null);
      expect((await repo.getConfig()).selectedLocale, isNull);
    });

    test('setConfigUsesImperialUnits toggles units', () async {
      await usecase.setConfigUsesImperialUnits(true);
      expect((await repo.getConfig()).usesImperialUnits, isTrue);
    });

    test('setConfigKcalAdjustment stores adjustment', () async {
      await usecase.setConfigKcalAdjustment(150.0);
      expect((await repo.getConfig()).userKcalAdjustment, 150.0);
    });

    test('setConfigMacroGoalPct stores percentages', () async {
      await usecase.setConfigMacroGoalPct(0.5, 0.2, 0.3);
      final cfg = await repo.getConfig();
      expect(cfg.userCarbGoalPct, closeTo(0.5, 0.001));
      expect(cfg.userProteinGoalPct, closeTo(0.2, 0.001));
      expect(cfg.userFatGoalPct, closeTo(0.3, 0.001));
    });

    test('setConfigMacroGoalGramPerKg stores gram-per-kg values', () async {
      await usecase.setConfigMacroGoalGramPerKg(3.0, 2.0, 1.0);
      final cfg = await repo.getConfig();
      expect(cfg.userCarbGoalGramPerKg, 3.0);
      expect(cfg.userProteinGoalGramPerKg, 2.0);
      expect(cfg.userFatGoalGramPerKg, 1.0);
    });

    test('setMacroGoalMode sets gramsPerKg mode', () async {
      await usecase.setMacroGoalMode(MacroGoalModeEntity.gramsPerKg);
      expect((await repo.getConfig()).macroGoalMode,
          MacroGoalModeEntity.gramsPerKg);
    });

    test('setConfigDailyFocus stores focus', () async {
      await usecase.setConfigDailyFocus(DailyFocusEntity.lowerBody);
      expect((await repo.getConfig()).dailyFocus, DailyFocusEntity.lowerBody);
    });

    test('setConfigTrainingDayTemplate stores template', () async {
      await usecase.setConfigTrainingDayTemplate(
          TrainingDayTemplateEntity.upperBody);
      expect((await repo.getConfig()).trainingDayTemplate,
          TrainingDayTemplateEntity.upperBody);
    });

    test('setHealthConnectAutoSyncEnabled stores value', () async {
      await usecase.setHealthConnectAutoSyncEnabled(false);
      expect((await repo.getConfig()).healthConnectAutoSyncEnabled, isFalse);
    });

    test('setMealReminderConfig stores enabled flag', () async {
      await usecase.setMealReminderConfig(
        enabled: true,
        morningMinutes: 540,
        lunchMinutes: 780,
        afternoonMinutes: 1020,
        eveningMinutes: 1260,
      );
      expect((await repo.getConfig()).mealRemindersEnabled, isTrue);
    });

    test('setGoogleDriveAutoBackupEnabled stores value', () async {
      await usecase.setGoogleDriveAutoBackupEnabled(true);
      expect((await repo.getConfig()).googleDriveAutoBackupEnabled, isTrue);
    });

    test('setGoogleDriveBackupStatus records attempt and error', () async {
      await usecase.setGoogleDriveBackupStatus(
        attemptedAtIso: '2024-01-01T00:00:00Z',
        errorMessage: 'timeout',
      );
      final cfg = await repo.getConfig();
      expect(cfg.googleDriveLastBackupAttemptAt, '2024-01-01T00:00:00Z');
      expect(cfg.googleDriveLastBackupError, 'timeout');
    });

    test('addDiscardedHealthConnectActivityId appends id', () async {
      await usecase.addDiscardedHealthConnectActivityId('act-1');
      final cfg = await repo.getConfig();
      expect(cfg.discardedHealthConnectActivityIds, contains('act-1'));
    });

    test('addAiEstimatedCost increments total cost', () async {
      await usecase.addAiEstimatedCost(isPhoto: true, usdCost: 0.005);
      final cfg = await repo.getConfig();
      expect(cfg.aiEstimatedCostTotalUsd, closeTo(0.005, 0.0001));
    });

    test('resetAiCostTracking zeroes all cost fields', () async {
      await usecase.addAiEstimatedCost(isPhoto: false, usdCost: 0.02);
      await usecase.resetAiCostTracking();
      final cfg = await repo.getConfig();
      expect(cfg.aiEstimatedCostTotalUsd, 0);
    });
  });

  // ── GetMacroGoalUsecase ───────────────────────────────────────────────────
  group('GetMacroGoalUsecase', () {
    late _FakeConfigRepository configRepo;
    late _FakeUserRepository userRepo;
    late GetMacroGoalUsecase usecase;

    setUp(() {
      configRepo = _FakeConfigRepository();
      userRepo = _FakeUserRepository();
      usecase = GetMacroGoalUsecase(configRepo, userRepo);
    });

    group('percentage mode (default)', () {
      test('getCarbsGoal uses default 60% when no custom pct set', () async {
        configRepo.seedWithPctMode();
        final carbs = await usecase.getCarbsGoal(2000);
        // 2000 * 0.60 / 4 = 300
        expect(carbs, closeTo(300, 1));
      });

      test('getCarbsGoal uses custom carb pct when set', () async {
        configRepo.seedWithPctMode(carbPct: 0.5);
        final carbs = await usecase.getCarbsGoal(2000);
        // 2000 * 0.50 / 4 = 250
        expect(carbs, closeTo(250, 1));
      });

      test('getFatsGoal uses default 25% when no custom pct set', () async {
        configRepo.seedWithPctMode();
        final fat = await usecase.getFatsGoal(2000);
        // 2000 * 0.25 / 9 ≈ 55.56
        expect(fat, closeTo(55.56, 1));
      });

      test('getFatsGoal uses custom fat pct when set', () async {
        configRepo.seedWithPctMode(fatPct: 0.3);
        final fat = await usecase.getFatsGoal(2000);
        // 2000 * 0.30 / 9 ≈ 66.67
        expect(fat, closeTo(66.67, 1));
      });

      test('getProteinsGoal uses default 15% when no custom pct set', () async {
        configRepo.seedWithPctMode();
        final protein = await usecase.getProteinsGoal(2000);
        // 2000 * 0.15 / 4 = 75
        expect(protein, closeTo(75, 1));
      });
    });

    group('gramsPerKg mode', () {
      // user weight = 80kg (youngSedentaryMale)
      test('getCarbsGoal in g/kg mode derives carbs from remaining kcal',
          () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg,
            proteinGramPerKg: 2.0, fatGramPerKg: 1.0);
        // protein = 2.0 * 80 = 160g → 640kcal
        // fat    = 1.0 * 80 = 80g  → 720kcal
        // remaining = 2000 - 640 - 720 = 640kcal → 640/4 = 160g carbs
        final carbs = await usecase.getCarbsGoal(2000);
        expect(carbs, closeTo(160, 1));
      });

      test('getCarbsGoal returns 0 when protein+fat exceed total kcal',
          () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg,
            proteinGramPerKg: 10.0, fatGramPerKg: 10.0);
        final carbs = await usecase.getCarbsGoal(2000);
        expect(carbs, 0);
      });

      test('getFatsGoal in g/kg mode uses gram-per-kg value', () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg,
            fatGramPerKg: 1.2);
        // 1.2 * 80 = 96
        final fat = await usecase.getFatsGoal(2000);
        expect(fat, closeTo(96, 1));
      });

      test(
          'getFatsGoal falls back to pct mode when fatGramPerKg is null in g/kg mode',
          () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg);
        // fatGramPerKg == null → falls back to default 25%
        final fat = await usecase.getFatsGoal(2000);
        expect(fat, closeTo(55.56, 1));
      });

      test('getProteinsGoal in g/kg mode uses gram-per-kg value', () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg,
            proteinGramPerKg: 1.8);
        // 1.8 * 80 = 144
        final protein = await usecase.getProteinsGoal(2000);
        expect(protein, closeTo(144, 1));
      });

      test(
          'getProteinsGoal falls back to pct when proteinGramPerKg is null in g/kg mode',
          () async {
        configRepo.seedWithMacroMode(MacroGoalModeEntity.gramsPerKg);
        final protein = await usecase.getProteinsGoal(2000);
        expect(protein, closeTo(75, 1));
      });
    });
  });
}
