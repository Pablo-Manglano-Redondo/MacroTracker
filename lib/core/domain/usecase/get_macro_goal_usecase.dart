import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/utils/calc/macro_calc.dart';

class GetMacroGoalUsecase {
  final ConfigRepository _configRepository;
  final UserRepository _userRepository;

  GetMacroGoalUsecase(this._configRepository, this._userRepository);

  Future<double> getCarbsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.macroGoalMode == MacroGoalModeEntity.gramsPerKg) {
      final user = await _userRepository.getUserData();
      final proteinGoal =
          (config.userProteinGoalGramPerKg ?? 1.6) * user.weightKG;
      final fatGoal = (config.userFatGoalGramPerKg ?? 0.8) * user.weightKG;
      final remainingKcal =
          totalCalorieGoal - (proteinGoal * 4) - (fatGoal * 9);
      if (remainingKcal <= 0) {
        return 0;
      }
      return (remainingKcal / 4).roundToDouble();
    }

    return MacroCalc.getTotalCarbsGoal(totalCalorieGoal,
        userCarbsGoal: config.userCarbGoalPct);
  }

  Future<double> getFatsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.macroGoalMode == MacroGoalModeEntity.gramsPerKg &&
        config.userFatGoalGramPerKg != null) {
      final user = await _userRepository.getUserData();
      return (config.userFatGoalGramPerKg! * user.weightKG).roundToDouble();
    }

    return MacroCalc.getTotalFatsGoal(totalCalorieGoal,
        userFatsGoal: config.userFatGoalPct);
  }

  Future<double> getProteinsGoal(double totalCalorieGoal) async {
    final config = await _configRepository.getConfig();
    if (config.macroGoalMode == MacroGoalModeEntity.gramsPerKg &&
        config.userProteinGoalGramPerKg != null) {
      final user = await _userRepository.getUserData();
      return (config.userProteinGoalGramPerKg! * user.weightKG).roundToDouble();
    }

    return MacroCalc.getTotalProteinsGoal(totalCalorieGoal,
        userProteinsGoal: config.userProteinGoalPct);
  }
}
