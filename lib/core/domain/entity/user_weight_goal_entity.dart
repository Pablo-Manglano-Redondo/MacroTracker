import 'package:flutter/material.dart';
import 'package:macrotracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:macrotracker/generated/l10n.dart';

enum UserWeightGoalEntity {
  loseWeight,
  maintainWeight,
  gainWeight;

  factory UserWeightGoalEntity.fromUserWeightGoalDBO(
      UserWeightGoalDBO weightGoalDBO) {
    UserWeightGoalEntity weightGoalEntity;
    switch (weightGoalDBO) {
      case UserWeightGoalDBO.gainWeight:
        weightGoalEntity = UserWeightGoalEntity.gainWeight;
        break;
      case UserWeightGoalDBO.maintainWeight:
        weightGoalEntity = UserWeightGoalEntity.maintainWeight;
        break;
      case UserWeightGoalDBO.loseWeight:
        weightGoalEntity = UserWeightGoalEntity.loseWeight;
        break;
    }
    return weightGoalEntity;
  }

  String getName(BuildContext context) {
    String name;
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        name = S.of(context).goalLoseWeight;
        break;
      case UserWeightGoalEntity.maintainWeight:
        name = S.of(context).goalMaintainWeight;
        break;
      case UserWeightGoalEntity.gainWeight:
        name = S.of(context).goalGainWeight;
        break;
    }
    return name;
  }

  String get gymPhaseLabel {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return 'Cut';
      case UserWeightGoalEntity.maintainWeight:
        return 'Maintain';
      case UserWeightGoalEntity.gainWeight:
        return 'Bulk';
    }
  }

  String get gymHeadline {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return 'Protect muscle while bringing calories down';
      case UserWeightGoalEntity.maintainWeight:
        return 'Hold bodyweight steady and sharpen consistency';
      case UserWeightGoalEntity.gainWeight:
        return 'Feed performance and recover hard';
    }
  }

  String get macroHint {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return 'Higher protein, tighter carbs, enough fats to stay stable.';
      case UserWeightGoalEntity.maintainWeight:
        return 'Balanced macros with protein kept comfortably high.';
      case UserWeightGoalEntity.gainWeight:
        return 'Extra carbs and enough total food to support progression.';
    }
  }

  double adjustCarbGoal(double baseGoal) {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return (baseGoal * 0.9).roundToDouble();
      case UserWeightGoalEntity.maintainWeight:
        return baseGoal.roundToDouble();
      case UserWeightGoalEntity.gainWeight:
        return (baseGoal * 1.08).roundToDouble();
    }
  }

  double adjustFatGoal(double baseGoal) {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return (baseGoal * 0.92).roundToDouble();
      case UserWeightGoalEntity.maintainWeight:
        return baseGoal.roundToDouble();
      case UserWeightGoalEntity.gainWeight:
        return (baseGoal * 1.04).roundToDouble();
    }
  }

  double adjustProteinGoal(double baseGoal) {
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        return (baseGoal * 1.2).roundToDouble();
      case UserWeightGoalEntity.maintainWeight:
        return (baseGoal * 1.06).roundToDouble();
      case UserWeightGoalEntity.gainWeight:
        return (baseGoal * 1.1).roundToDouble();
    }
  }
}
