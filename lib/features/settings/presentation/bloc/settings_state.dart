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

  const SettingsLoadedState(this.versionNumber, this.sendAnonymousData,
      this.appTheme, this.usesImperialUnits,
      {this.aiEstimatedCostTotalUsd = 0,
      this.aiEstimatedCostTodayUsd = 0,
      this.aiEstimatedCostMonthUsd = 0,
      this.aiTextCallsTotal = 0,
      this.aiPhotoCallsTotal = 0});

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
        aiPhotoCallsTotal
      ];
}
