enum DailyFocusEntity {
  training,
  rest,
  cardio,
}

extension DailyFocusEntityX on DailyFocusEntity {
  String get storageValue {
    switch (this) {
      case DailyFocusEntity.training:
        return 'training';
      case DailyFocusEntity.rest:
        return 'rest';
      case DailyFocusEntity.cardio:
        return 'cardio';
    }
  }

  String get label {
    switch (this) {
      case DailyFocusEntity.training:
        return 'Training';
      case DailyFocusEntity.rest:
        return 'Rest';
      case DailyFocusEntity.cardio:
        return 'Cardio';
    }
  }

  String get headline {
    switch (this) {
      case DailyFocusEntity.training:
        return 'Push performance and recovery';
      case DailyFocusEntity.rest:
        return 'Recover while keeping protein high';
      case DailyFocusEntity.cardio:
        return 'Stay light but keep fuel available';
    }
  }

  String get macroHint {
    switch (this) {
      case DailyFocusEntity.training:
        return 'Higher carbs around the session, steady protein all day.';
      case DailyFocusEntity.rest:
        return 'Keep protein anchored and trim carbs a bit.';
      case DailyFocusEntity.cardio:
        return 'Moderate carbs, lighter fats, enough calories to move well.';
    }
  }

  double adjustKcalGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.training:
        return (baseGoal * 1.08).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 0.94).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.03).roundToDouble();
    }
  }

  double adjustCarbGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.training:
        return (baseGoal * 1.14).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 0.82).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.08).roundToDouble();
    }
  }

  double adjustProteinGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.training:
        return (baseGoal * 1.08).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 1.1).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.05).roundToDouble();
    }
  }

  double adjustFatGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.training:
        return (baseGoal * 0.96).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 1.05).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 0.92).roundToDouble();
    }
  }

  static DailyFocusEntity fromStorageValue(String? value) {
    switch (value) {
      case 'rest':
        return DailyFocusEntity.rest;
      case 'cardio':
        return DailyFocusEntity.cardio;
      case 'training':
      default:
        return DailyFocusEntity.training;
    }
  }
}
