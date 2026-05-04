import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';

class AddTrackedDayUsecase {
  final TrackedDayRepository _trackedDayRepository;
  final UpdateHomeWidgetUsecase _updateHomeWidgetUsecase;

  AddTrackedDayUsecase(
    this._trackedDayRepository,
    this._updateHomeWidgetUsecase,
  );

  Future<void> updateDayCalorieGoal(DateTime day, double calorieGoal) async {
    await _trackedDayRepository.updateDayCalorieGoal(day, calorieGoal);
    await _refreshWidgetIfToday(day);
  }

  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {
    await _trackedDayRepository.increaseDayCalorieGoal(day, amount);
    await _refreshWidgetIfToday(day);
  }

  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {
    await _trackedDayRepository.reduceDayCalorieGoal(day, amount);
    await _refreshWidgetIfToday(day);
  }

  Future<bool> hasTrackedDay(DateTime day) async {
    return await _trackedDayRepository.hasTrackedDay(day);
  }

  Future<void> addNewTrackedDay(
      DateTime day,
      double totalKcalGoal,
      double totalCarbsGoal,
      double totalFatGoal,
      double totalProteinGoal) async {
    await _trackedDayRepository.addNewTrackedDay(
        day, totalKcalGoal, totalCarbsGoal, totalFatGoal, totalProteinGoal);
    await _refreshWidgetIfToday(day);
  }

  Future<void> addDayCaloriesTracked(
      DateTime day, double caloriesTracked) async {
    await _trackedDayRepository.addDayTrackedCalories(day, caloriesTracked);
    await _refreshWidgetIfToday(day);
  }

  Future<void> removeDayCaloriesTracked(
      DateTime day, double caloriesTracked) async {
    await _trackedDayRepository.removeDayTrackedCalories(day, caloriesTracked);
    await _refreshWidgetIfToday(day);
  }

  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {
    await _trackedDayRepository.updateDayMacroGoal(day,
        carbGoal: carbsGoal, fatGoal: fatGoal, proteinGoal: proteinGoal);
    await _refreshWidgetIfToday(day);
  }

  Future<void> increaseDayMacroGoals(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    await _trackedDayRepository.increaseDayMacroGoal(day,
        carbGoal: carbsAmount, fatGoal: fatAmount, proteinGoal: proteinAmount);
    await _refreshWidgetIfToday(day);
  }

  Future<void> reduceDayMacroGoals(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    await _trackedDayRepository.reduceDayMacroGoal(day,
        carbGoal: carbsAmount, fatGoal: fatAmount, proteinGoal: proteinAmount);
    await _refreshWidgetIfToday(day);
  }

  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {
    await _trackedDayRepository.addDayMacrosTracked(day,
        carbsTracked: carbsTracked, fatTracked: fatTracked, proteinTracked: proteinTracked);
    await _refreshWidgetIfToday(day);
  }

  Future<void> removeDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {
    await _trackedDayRepository.removeDayMacrosTracked(day,
        carbsTracked: carbsTracked, fatTracked: fatTracked, proteinTracked: proteinTracked);
    await _refreshWidgetIfToday(day);
  }

  Future<void> _refreshWidgetIfToday(DateTime day) async {
    final now = DateTime.now();
    if (day.year != now.year || day.month != now.month || day.day != now.day) {
      return;
    }

    await _updateHomeWidgetUsecase.refreshToday();
  }
}
