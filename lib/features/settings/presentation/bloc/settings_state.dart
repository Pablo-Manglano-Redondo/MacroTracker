part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsLoadingState extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoadedState extends SettingsState {
  final String versionNumber;
  final bool sendAnonymousData;
  final AppThemeEntity appTheme;
  final bool usesImperialUnits;
  final double aiEstimatedCostTotalUsd;
  final double aiEstimatedCostTodayUsd;
  final double aiEstimatedCostMonthUsd;
  final int aiTextCallsTotal;
  final int aiPhotoCallsTotal;
  final String? currentLocale;
  final bool healthConnectAutoSyncEnabled;
  final bool mealRemindersEnabled;
  final int mealReminderMorningMinutes;
  final int mealReminderLunchMinutes;
  final int mealReminderAfternoonMinutes;
  final int mealReminderEveningMinutes;
  final MacroGoalModeEntity macroGoalMode;

  const SettingsLoadedState(this.versionNumber, this.sendAnonymousData,
      this.appTheme, this.usesImperialUnits,
      {this.aiEstimatedCostTotalUsd = 0,
      this.aiEstimatedCostTodayUsd = 0,
      this.aiEstimatedCostMonthUsd = 0,
      this.aiTextCallsTotal = 0,
      this.aiPhotoCallsTotal = 0,
      this.currentLocale,
      this.healthConnectAutoSyncEnabled = true,
      this.mealRemindersEnabled = false,
      this.mealReminderMorningMinutes = 9 * 60,
      this.mealReminderLunchMinutes = 15 * 60 + 30,
      this.mealReminderAfternoonMinutes = 18 * 60,
      this.mealReminderEveningMinutes = 21 * 60 + 30,
      this.macroGoalMode = MacroGoalModeEntity.percentage});

  @override
  List<Object?> get props => [
        versionNumber,
        sendAnonymousData,
        appTheme,
        usesImperialUnits,
        aiEstimatedCostTotalUsd,
        aiEstimatedCostTodayUsd,
        aiEstimatedCostMonthUsd,
        aiTextCallsTotal,
        aiPhotoCallsTotal,
        currentLocale,
        healthConnectAutoSyncEnabled,
        mealRemindersEnabled,
        mealReminderMorningMinutes,
        mealReminderLunchMinutes,
        mealReminderAfternoonMinutes,
        mealReminderEveningMinutes,
        macroGoalMode,
      ];
}

class SettingsAccountDeletedState extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsAccountDeletionFailedState extends SettingsState {
  final String message;

  const SettingsAccountDeletionFailedState(this.message);

  @override
  List<Object?> get props => [message];
}
