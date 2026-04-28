import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';

class ConfigDataSource {
  static const _configKey = "ConfigKey";

  final _log = Logger('ConfigDataSource');
  final Box<ConfigDBO> _configBox;

  ConfigDataSource(this._configBox);

  Future<bool> configInitialized() async => _configBox.containsKey(_configKey);

  Future<void> initializeConfig() async =>
      _configBox.put(_configKey, ConfigDBO.empty());

  Future<void> addConfig(ConfigDBO configDBO) async {
    _log.fine('Adding new config item to db');
    _configBox.put(_configKey, configDBO);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _log.fine(
        'Updating config hasAcceptedDisclaimer to $hasAcceptedDisclaimer');
    final config = _configBox.get(_configKey);
    config?.hasAcceptedDisclaimer = hasAcceptedDisclaimer;
    config?.save();
  }

  Future<void> setConfigAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _log.fine(
        'Updating config hasAcceptedAnonymousData to $hasAcceptedAnonymousData');
    final config = _configBox.get(_configKey);
    config?.hasAcceptedSendAnonymousData = hasAcceptedAnonymousData;
    config?.save();
  }

  Future<AppThemeDBO> getAppTheme() async {
    final config = _configBox.get(_configKey);
    return config?.selectedAppTheme ?? AppThemeDBO.defaultTheme;
  }

  Future<void> setConfigAppTheme(AppThemeDBO appTheme) async {
    _log.fine('Updating config appTheme to $appTheme');
    final config = _configBox.get(_configKey);
    config?.selectedAppTheme = appTheme;
    config?.save();
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _log.fine('Updating config usesImperialUnits to $usesImperialUnits');
    final config = _configBox.get(_configKey);
    config?.usesImperialUnits = usesImperialUnits;
    config?.save();
  }

  Future<double> getKcalAdjustment() async {
    final config = _configBox.get(_configKey);
    return config?.userKcalAdjustment ?? 0;
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _log.fine('Updating config kcalAdjustment to $kcalAdjustment');
    final config = _configBox.get(_configKey);
    config?.userKcalAdjustment = kcalAdjustment;
    config?.save();
  }

  Future<void> setConfigCarbGoalPct(double carbGoalPct) async {
    _log.fine('Updating config carbGoalPct to $carbGoalPct');
    final config = _configBox.get(_configKey);
    config?.userCarbGoalPct = carbGoalPct;
    config?.save();
  }

  Future<void> setConfigProteinGoalPct(double proteinGoalPct) async {
    _log.fine('Updating config proteinGoalPct to $proteinGoalPct');
    final config = _configBox.get(_configKey);
    config?.userProteinGoalPct = proteinGoalPct;
    config?.save();
  }

  Future<void> setConfigFatGoalPct(double fatGoalPct) async {
    _log.fine('Updating config fatGoalPct to $fatGoalPct');
    final config = _configBox.get(_configKey);
    config?.userFatGoalPct = fatGoalPct;
    config?.save();
  }

  Future<void> setConfigDailyFocus(String dailyFocus) async {
    _log.fine('Updating config dailyFocus to $dailyFocus');
    final config = _configBox.get(_configKey);
    config?.dailyFocus = dailyFocus;
    config?.save();
  }

  Future<void> setConfigTrainingDayTemplate(String template) async {
    _log.fine('Updating config trainingDayTemplate to $template');
    final config = _configBox.get(_configKey);
    config?.trainingDayTemplate = template;
    await config?.save();
  }

  Future<void> addAiEstimatedCost({
    required bool isPhoto,
    required double usdCost,
  }) async {
    final config = _configBox.get(_configKey);
    if (config == null) {
      return;
    }

    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final monthKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

    if (config.aiCostTodayDate != todayKey) {
      config.aiCostTodayDate = todayKey;
      config.aiEstimatedCostTodayUsd = 0;
    }

    if (config.aiCostMonthKey != monthKey) {
      config.aiCostMonthKey = monthKey;
      config.aiEstimatedCostMonthUsd = 0;
    }

    config.aiEstimatedCostTotalUsd =
        (config.aiEstimatedCostTotalUsd ?? 0) + usdCost;
    config.aiEstimatedCostTodayUsd =
        (config.aiEstimatedCostTodayUsd ?? 0) + usdCost;
    config.aiEstimatedCostMonthUsd =
        (config.aiEstimatedCostMonthUsd ?? 0) + usdCost;
    config.aiTextCallsTotal =
        (config.aiTextCallsTotal ?? 0) + (isPhoto ? 0 : 1);
    config.aiPhotoCallsTotal =
        (config.aiPhotoCallsTotal ?? 0) + (isPhoto ? 1 : 0);
    await config.save();
  }

  Future<void> resetAiCostTracking() async {
    final config = _configBox.get(_configKey);
    if (config == null) {
      return;
    }
    config.aiEstimatedCostTotalUsd = 0;
    config.aiEstimatedCostTodayUsd = 0;
    config.aiEstimatedCostMonthUsd = 0;
    config.aiTextCallsTotal = 0;
    config.aiPhotoCallsTotal = 0;
    config.aiCostTodayDate = null;
    config.aiCostMonthKey = null;
    await config.save();
  }

  Future<ConfigDBO> getConfig() async {
    return _configBox.get(_configKey) ?? ConfigDBO.empty();
  }

  Future<bool> getHasAcceptedAnonymousData() async {
    final config = _configBox.get(_configKey);
    return config?.hasAcceptedSendAnonymousData ?? false;
  }
}
