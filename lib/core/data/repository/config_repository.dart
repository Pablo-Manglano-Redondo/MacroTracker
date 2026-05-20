import 'package:macrotracker/core/data/data_source/config_data_source.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';

class ConfigRepository {
  final ConfigDataSource _configDataSource;

  ConfigRepository(this._configDataSource);

  Future<void> updateConfig(ConfigEntity configEntity) async {
    final configDBO = ConfigDBO.fromConfigEntity(configEntity);
    _configDataSource.addConfig(configDBO);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _configDataSource.setConfigDisclaimer(hasAcceptedDisclaimer);
  }

  Future<void> setConfigHasAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _configDataSource.setConfigAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  Future<bool> getConfigHasAcceptedAnonymousData() async {
    return await _configDataSource.getHasAcceptedAnonymousData();
  }

  Future<AppThemeEntity> getConfigAppTheme() async {
    final appThemeDBO = await _configDataSource.getAppTheme();
    return AppThemeEntity.fromAppThemeDBO(appThemeDBO);
  }

  Future<void> setConfigAppTheme(AppThemeEntity appTheme) async {
    await _configDataSource
        .setConfigAppTheme(AppThemeDBO.fromAppThemeEntity(appTheme));
  }

  Future<String?> getConfigLocale() async {
    return await _configDataSource.getLocale();
  }

  Future<void> setConfigLocale(String? locale) async {
    await _configDataSource.setConfigLocale(locale);
  }

  Future<ConfigEntity> getConfig() async {
    final configDBO = await _configDataSource.getConfig();
    return ConfigEntity.fromConfigDBO(configDBO);
  }

  Future<ConfigDBO> getConfigDBO() async {
    final configDBO = await _configDataSource.getConfig();
    return configDBO;
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _configDataSource.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<double> getConfigKcalAdjustment() async {
    return await _configDataSource.getKcalAdjustment();
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _configDataSource.setConfigKcalAdjustment(kcalAdjustment);
  }

  Future<void> setUserMacroPct(double carbs, double protein, double fat) async {
    _configDataSource.setConfigCarbGoalPct(carbs);
    _configDataSource.setConfigProteinGoalPct(protein);
    _configDataSource.setConfigFatGoalPct(fat);
  }

  Future<void> setUserMacroGoalsGramPerKg(
      double carbs, double protein, double fat) async {
    await _configDataSource.setConfigCarbGoalGramPerKg(carbs);
    await _configDataSource.setConfigProteinGoalGramPerKg(protein);
    await _configDataSource.setConfigFatGoalGramPerKg(fat);
  }

  Future<void> setMacroGoalMode(MacroGoalModeEntity macroGoalMode) async {
    await _configDataSource.setMacroGoalMode(macroGoalMode.storageValue);
  }

  Future<void> setDailyFocus(DailyFocusEntity dailyFocus) async {
    _configDataSource.setConfigDailyFocus(dailyFocus.storageValue);
  }

  Future<void> setTrainingDayTemplate(
      TrainingDayTemplateEntity trainingDayTemplate) async {
    await _configDataSource
        .setConfigTrainingDayTemplate(trainingDayTemplate.storageValue);
  }

  Future<void> setHealthConnectAutoSyncEnabled(bool enabled) async {
    await _configDataSource.setHealthConnectAutoSyncEnabled(enabled);
  }

  Future<void> setMealReminderConfig({
    required bool enabled,
    required int morningMinutes,
    required int lunchMinutes,
    required int afternoonMinutes,
    required int eveningMinutes,
  }) async {
    await _configDataSource.setMealReminderConfig(
      enabled: enabled,
      morningMinutes: morningMinutes,
      lunchMinutes: lunchMinutes,
      afternoonMinutes: afternoonMinutes,
      eveningMinutes: eveningMinutes,
    );
  }

  Future<void> setGoogleDriveAutoBackupEnabled(bool enabled) async {
    await _configDataSource.setGoogleDriveAutoBackupEnabled(enabled);
  }

  Future<void> setGoogleDriveBackupStatus({
    required String attemptedAtIso,
    String? successAtIso,
    String? errorMessage,
  }) async {
    await _configDataSource.setGoogleDriveBackupStatus(
      attemptedAtIso: attemptedAtIso,
      successAtIso: successAtIso,
      errorMessage: errorMessage,
    );
  }

  Future<List<String>> getDiscardedHealthConnectActivityIds() async {
    return _configDataSource.getDiscardedHealthConnectActivityIds();
  }

  Future<void> addDiscardedHealthConnectActivityId(String externalId) async {
    await _configDataSource.addDiscardedHealthConnectActivityId(externalId);
  }

  Future<void> addAiEstimatedCost({
    required bool isPhoto,
    required double usdCost,
  }) async {
    await _configDataSource.addAiEstimatedCost(
      isPhoto: isPhoto,
      usdCost: usdCost,
    );
  }

  Future<void> resetAiCostTracking() async {
    await _configDataSource.resetAiCostTracking();
  }
}
