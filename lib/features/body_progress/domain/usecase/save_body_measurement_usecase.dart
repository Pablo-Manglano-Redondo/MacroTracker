import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';

class SaveBodyMeasurementUsecase {
  final BodyMeasurementRepository _bodyMeasurementRepository;
  final GetUserUsecase _getUserUsecase;
  final AddUserUsecase _addUserUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;

  SaveBodyMeasurementUsecase(
    this._bodyMeasurementRepository,
    this._getUserUsecase,
    this._addUserUsecase,
    this._addTrackedDayUsecase,
    this._getGymTargetsUsecase,
  );

  Future<void> saveMeasurement({
    required DateTime day,
    double? weightKg,
    double? waistCm,
  }) async {
    if (weightKg == null && waistCm == null) {
      return;
    }

    final existing = await _bodyMeasurementRepository.getMeasurement(day);
    final measurement = BodyMeasurementEntity(
      day: DateTime(day.year, day.month, day.day),
      weightKg: weightKg ?? existing?.weightKg,
      waistCm: waistCm ?? existing?.waistCm,
    );
    await _bodyMeasurementRepository.saveMeasurement(measurement);

    if (weightKg != null && DateUtils.isSameDay(day, DateTime.now())) {
      final user = await _getUserUsecase.getUserData();
      await _syncUserWeight(user, day, weightKg);
    }
  }

  Future<void> _syncUserWeight(
      UserEntity user, DateTime day, double weightKg) async {
    user.weightKG = weightKg;
    await _addUserUsecase.addUser(user);

    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      return;
    }

    final targets = await _getGymTargetsUsecase.getTargetsForDay(
      day,
      userEntity: user,
    );
    await _addTrackedDayUsecase.updateDayCalorieGoal(day, targets.kcalGoal);
    await _addTrackedDayUsecase.updateDayMacroGoals(
      day,
      carbsGoal: targets.carbsGoal,
      fatGoal: targets.fatGoal,
      proteinGoal: targets.proteinGoal,
    );
  }
}
