import 'package:macrotracker/core/data/data_source/config_data_source.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';

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

  Future<void> setDailyFocus(DailyFocusEntity dailyFocus) async {
    _configDataSource.setConfigDailyFocus(dailyFocus.storageValue);
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
