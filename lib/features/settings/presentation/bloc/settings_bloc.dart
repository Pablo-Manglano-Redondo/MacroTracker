import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/app_const.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final log = Logger('SettingsBloc');

  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetUserUsecase _getUserUsecase;
  final SyncSleepFromHealthConnectUsecase _syncSleepFromHealthConnectUsecase;

  SettingsBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._addTrackedDayUsecase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase,
      this._getUserUsecase,
      this._syncSleepFromHealthConnectUsecase)
      : super(SettingsInitial()) {
    on<LoadSettingsEvent>((event, emit) async {
      emit(SettingsLoadingState());

      final userConfig = await _getConfigUsecase.getConfig();
      final appVersion = await AppConst.getVersionNumber();
      final usesImperialUnits = userConfig.usesImperialUnits;

      emit(SettingsLoadedState(
          appVersion,
          userConfig.hasAcceptedSendAnonymousData,
          userConfig.appTheme,
          usesImperialUnits,
          aiEstimatedCostTotalUsd: userConfig.aiEstimatedCostTotalUsd,
          aiEstimatedCostTodayUsd: userConfig.aiEstimatedCostTodayUsd,
          aiEstimatedCostMonthUsd: userConfig.aiEstimatedCostMonthUsd,
          aiTextCallsTotal: userConfig.aiTextCallsTotal,
          aiPhotoCallsTotal: userConfig.aiPhotoCallsTotal,
          currentLocale: userConfig.selectedLocale,
          healthConnectAutoSyncEnabled:
              userConfig.healthConnectAutoSyncEnabled));
    });
  }

  void setHasAcceptedAnonymousData(bool hasAcceptedAnonymousData) {
    _addConfigUsecase
        .setConfigHasAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  void setAppTheme(AppThemeEntity appTheme) async {
    await _addConfigUsecase.setConfigAppTheme(appTheme);
  }

  void setLocale(String? locale) async {
    await _addConfigUsecase.setConfigLocale(locale);
  }

  void setUsesImperialUnits(bool usesImperialUnits) {
    _addConfigUsecase.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<double> getKcalAdjustment() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userKcalAdjustment ?? 0;
  }

  Future<double?> getUserCarbGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userCarbGoalPct;
  }

  Future<double?> getUserProteinGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userProteinGoalPct;
  }

  Future<double?> getUserFatGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userFatGoalPct;
  }

  void setKcalAdjustment(double kcalAdjustment) {
    _addConfigUsecase.setConfigKcalAdjustment(kcalAdjustment);
  }

  void setMacroGoals(
      double carbGoalPct, double proteinGoalPct, double fatGoalPct) {
    _addConfigUsecase.setConfigMacroGoalPct(carbGoalPct.toInt() / 100,
        proteinGoalPct.toInt() / 100, fatGoalPct.toInt() / 100);
  }

  Future<void> resetAiCostTracking() async {
    await _addConfigUsecase.resetAiCostTracking();
  }

  Future<void> setHealthConnectAutoSyncEnabled(bool enabled) async {
    await _addConfigUsecase.setHealthConnectAutoSyncEnabled(enabled);
  }

  Future<HealthConnectSyncStatusEntity> getHealthConnectStatus() async {
    return _syncSleepFromHealthConnectUsecase.getStatus();
  }

  Future<HealthConnectSyncStatusEntity> requestHealthConnectPermissions() async {
    return _syncSleepFromHealthConnectUsecase.requestPermissions();
  }

  Future<bool> syncHealthConnectNow() async {
    return _syncSleepFromHealthConnectUsecase.syncToday(
      requestPermissionsIfNeeded: true,
      ignoreAutoSyncSetting: true,
    );
  }

  void updateTrackedDay(DateTime day) async {
    final config = await _getConfigUsecase.getConfig();
    final user = await _getUserUsecase.getUserData();
    final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
    final baseCarbsGoal =
        await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
    final baseFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
    final baseProteinGoal =
        await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);
    final targets = GymTargetCalc.buildTargets(
      phase: user.goal,
      dailyFocus: config.dailyFocus,
      baseKcalGoal: totalKcalGoal,
      baseCarbsGoal: baseCarbsGoal,
      baseFatGoal: baseFatGoal,
      baseProteinGoal: baseProteinGoal,
      userWeightKg: user.weightKG,
      userHeightCm: user.heightCM,
    );

    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);

    if (hasTrackedDay) {
      await _addTrackedDayUsecase.updateDayCalorieGoal(day, targets.kcalGoal);
      await _addTrackedDayUsecase.updateDayMacroGoals(day,
          carbsGoal: targets.carbsGoal,
          fatGoal: targets.fatGoal,
          proteinGoal: targets.proteinGoal);
    }
  }
}

enum SystemDropDownType { metric, imperial }
