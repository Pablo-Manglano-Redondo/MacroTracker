enum MacroGoalModeEntity {
  percentage,
  gramsPerKg,
}

extension MacroGoalModeEntityX on MacroGoalModeEntity {
  String get storageValue {
    switch (this) {
      case MacroGoalModeEntity.percentage:
        return 'percentage';
      case MacroGoalModeEntity.gramsPerKg:
        return 'gramsPerKg';
    }
  }

  static MacroGoalModeEntity fromStorageValue(String? value) {
    switch (value) {
      case 'gramsPerKg':
        return MacroGoalModeEntity.gramsPerKg;
      case 'percentage':
      default:
        return MacroGoalModeEntity.percentage;
    }
  }
}
