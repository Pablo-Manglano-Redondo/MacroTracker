import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';

class AddConfigUsecase {
  final ConfigRepository _configRepository;

  AddConfigUsecase(this._configRepository);

  Future<void> addConfig(ConfigEntity configEntity) async {
    _configRepository.updateConfig(configEntity);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _configRepository.setConfigDisclaimer(hasAcceptedDisclaimer);
  }

  Future<void> setConfigHasAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _configRepository
        .setConfigHasAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  Future<void> setConfigAppTheme(AppThemeEntity appTheme) async {
    await _configRepository.setConfigAppTheme(appTheme);
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _configRepository.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _configRepository.setConfigKcalAdjustment(kcalAdjustment);
  }

  Future<void> setConfigMacroGoalPct(
      double carbGoalPct, double proteinGoalPct, double fatPctGoal) async {
    _configRepository.setUserMacroPct(carbGoalPct, proteinGoalPct, fatPctGoal);
  }

  Future<void> setConfigDailyFocus(DailyFocusEntity dailyFocus) async {
    _configRepository.setDailyFocus(dailyFocus);
  }

  Future<void> setConfigTrainingDayTemplate(
      TrainingDayTemplateEntity trainingDayTemplate) async {
    await _configRepository.setTrainingDayTemplate(trainingDayTemplate);
  }

  Future<void> addAiEstimatedCost({
    required bool isPhoto,
    required double usdCost,
  }) async {
    await _configRepository.addAiEstimatedCost(
      isPhoto: isPhoto,
      usdCost: usdCost,
    );
  }

  Future<void> resetAiCostTracking() async {
    await _configRepository.resetAiCostTracking();
  }
}
