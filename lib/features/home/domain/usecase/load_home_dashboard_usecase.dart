import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/home/domain/entity/home_dashboard_data_entity.dart';
import 'package:macrotracker/features/home/domain/usecase/sync_home_tracked_day_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/process_pending_syncs_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/upload_professional_snapshot_usecase.dart';

class LoadHomeDashboardUsecase {
  final GetConfigUsecase _getConfigUsecase;
  final GetUserUsecase _getUserUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final CalculateFoodQualityScoreUsecase _calculateFoodQualityScoreUsecase;
  final GetProfessionalPlanUsecase _getProfessionalPlanUsecase;
  final UploadProfessionalSnapshotUsecase _uploadProfessionalSnapshotUsecase;
  final ProcessPendingSyncsUsecase _processPendingSyncsUsecase;
  final GetBodyProgressUsecase _getBodyProgressUsecase;
  final ProfessionalPlanRepository _professionalPlanRepository;
  final SyncHomeTrackedDayUsecase _syncHomeTrackedDayUsecase;

  LoadHomeDashboardUsecase(
    this._getConfigUsecase,
    this._getUserUsecase,
    this._getIntakeUsecase,
    this._getUserActivityUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
    this._calculateFoodQualityScoreUsecase,
    this._getProfessionalPlanUsecase,
    this._uploadProfessionalSnapshotUsecase,
    this._processPendingSyncsUsecase,
    this._getBodyProgressUsecase,
    this._professionalPlanRepository,
    this._syncHomeTrackedDayUsecase,
  );

  Future<HomeDashboardDataEntity> execute({
    required DateTime day,
    bool refreshRemotePlan = false,
    bool uploadProfessionalSnapshot = false,
  }) async {
    unawaited(_processPendingSyncsUsecase.execute().catchError((_) {}));

    final config = await _getConfigUsecase.getConfig();
    final user = await _getUserUsecase.getUserData();
    final professionalConnection =
        await _getProfessionalPlanUsecase.getActiveConnection(
      refreshRemotePlan: refreshRemotePlan,
    );

    await _syncHomeTrackedDayUsecase.execute(
      day: day,
      phase: user.goal,
      dailyFocus: config.dailyFocus,
      user: user,
      professionalConnection: professionalConnection,
    );

    final breakfastIntakeList =
        await _getIntakeUsecase.getTodayBreakfastIntake();
    final lunchIntakeList = await _getIntakeUsecase.getTodayLunchIntake();
    final dinnerIntakeList = await _getIntakeUsecase.getTodayDinnerIntake();
    final snackIntakeList = await _getIntakeUsecase.getTodaySnackIntake();

    final allIntakes = <IntakeEntity>[
      ...breakfastIntakeList,
      ...lunchIntakeList,
      ...dinnerIntakeList,
      ...snackIntakeList,
    ];

    final totalKcalIntake = _sumIntakes(allIntakes, (intake) => intake.totalKcal);
    final totalCarbsIntake =
        _sumIntakes(allIntakes, (intake) => intake.totalCarbsGram);
    final totalFatsIntake =
        _sumIntakes(allIntakes, (intake) => intake.totalFatsGram);
    final totalProteinsIntake =
        _sumIntakes(allIntakes, (intake) => intake.totalProteinsGram);

    final foodQualitySummary =
        _calculateFoodQualityScoreUsecase.summarizeIntakes(allIntakes);

    final userActivities =
        await _getUserActivityUsecase.getTodayUserActivity();
    final totalKcalActivities =
        userActivities.map((activity) => activity.burnedKcal).toList().sum;

    final baseKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
      userEntity: user,
      totalKcalActivitiesParam: totalKcalActivities,
    );
    final baseCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(baseKcalGoal);
    final baseFatsGoal = await _getMacroGoalUsecase.getFatsGoal(baseKcalGoal);
    final baseProteinsGoal =
        await _getMacroGoalUsecase.getProteinsGoal(baseKcalGoal);

    final appTargets = GymTargetCalc.buildTargets(
      phase: user.goal,
      dailyFocus: config.dailyFocus,
      macroGoalMode: config.macroGoalMode,
      baseKcalGoal: baseKcalGoal,
      baseCarbsGoal: baseCarbsGoal,
      baseFatGoal: baseFatsGoal,
      baseProteinGoal: baseProteinsGoal,
      userWeightKg: user.weightKG,
      userHeightCm: user.heightCM,
    );

    final targets = _resolveTargetsForDay(
      date: day,
      appTargets: appTargets,
      connection: professionalConnection,
    );

    if (uploadProfessionalSnapshot) {
      await _uploadSnapshotIfConsented(
        day: day,
        connection: professionalConnection,
        targets: targets,
        kcalActual: totalKcalIntake,
        carbsActual: totalCarbsIntake,
        fatActual: totalFatsIntake,
        proteinActual: totalProteinsIntake,
        mealsLogged: allIntakes.length,
        allIntakes: allIntakes,
      );
    }

    return HomeDashboardDataEntity(
      config: config,
      user: user,
      breakfastIntakeList: breakfastIntakeList,
      lunchIntakeList: lunchIntakeList,
      dinnerIntakeList: dinnerIntakeList,
      snackIntakeList: snackIntakeList,
      userActivities: userActivities,
      foodQualitySummary: foodQualitySummary,
      targets: targets,
      professionalConnection: professionalConnection,
      totalKcalIntake: totalKcalIntake,
      totalCarbsIntake: totalCarbsIntake,
      totalFatsIntake: totalFatsIntake,
      totalProteinsIntake: totalProteinsIntake,
      totalKcalActivities: totalKcalActivities,
    );
  }

  double _sumIntakes(
    Iterable<IntakeEntity> intakes,
    double Function(IntakeEntity intake) value,
  ) {
    return intakes.map(value).toList().sum;
  }

  GymTargetsEntity _resolveTargetsForDay({
    required DateTime date,
    required GymTargetsEntity appTargets,
    required ProfessionalConnectionEntity? connection,
  }) {
    final dayTarget = connection?.activePlan?.targetForDate(date);
    if (dayTarget == null || dayTarget.kcalGoal <= 0) {
      return appTargets;
    }

    return GymTargetsEntity(
      kcalGoal: dayTarget.kcalGoal,
      carbsGoal: dayTarget.carbsGoal,
      fatGoal: dayTarget.fatGoal,
      proteinGoal: dayTarget.proteinGoal,
    );
  }

  Future<void> _uploadSnapshotIfConsented({
    required DateTime day,
    required ProfessionalConnectionEntity? connection,
    required GymTargetsEntity targets,
    required double kcalActual,
    required double carbsActual,
    required double fatActual,
    required double proteinActual,
    required int mealsLogged,
    required List<IntakeEntity> allIntakes,
  }) async {
    if (connection == null || connection.activePlan == null) {
      return;
    }

    try {
      final dailyNote = await _professionalPlanRepository.getDailyNote(day);
      final bodyProgress =
          await _getBodyProgressUsecase.getSummary(referenceDay: day);

      await _uploadProfessionalSnapshotUsecase.uploadDailySnapshot(
        connection: connection,
        day: day,
        kcalActual: kcalActual,
        kcalTarget: targets.kcalGoal,
        carbsActual: carbsActual,
        carbsTarget: targets.carbsGoal,
        fatActual: fatActual,
        fatTarget: targets.fatGoal,
        proteinActual: proteinActual,
        proteinTarget: targets.proteinGoal,
        mealsLogged: mealsLogged,
        notes: dailyNote,
        weightKg: bodyProgress.latestWeightKg,
        waistCm: bodyProgress.latestWaistCm,
      );

      if (allIntakes.isNotEmpty && connection.sharingMode == 'detailed') {
        final entries = allIntakes
            .map((intake) => {
                  'meal_type': intake.type.name,
                  'meal_name': intake.meal.name ?? intake.meal.code,
                  'meal_brands': intake.meal.brands,
                  'amount': intake.amount,
                  'unit': intake.unit,
                  'kcal': intake.totalKcal,
                  'protein': intake.totalProteinsGram,
                  'carbs': intake.totalCarbsGram,
                  'fat': intake.totalFatsGram,
                })
            .toList();

        await _professionalPlanRepository.uploadDiaryEntries(
          connection: connection,
          day: day,
          entries: entries,
        );
      }
    } catch (_) {
      // Snapshot sync is consented but non-blocking; local tracking must keep working.
    }
  }
}
