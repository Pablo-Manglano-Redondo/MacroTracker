import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';

class ConfigEntity extends Equatable {
  final bool hasAcceptedDisclaimer;
  final bool hasAcceptedPolicy;
  final bool hasAcceptedSendAnonymousData;
  final AppThemeEntity appTheme;
  final bool usesImperialUnits;
  final double? userKcalAdjustment;
  final double? userCarbGoalPct;
  final double? userProteinGoalPct;
  final double? userFatGoalPct;
  final DailyFocusEntity dailyFocus;
  final double aiEstimatedCostTotalUsd;
  final double aiEstimatedCostTodayUsd;
  final double aiEstimatedCostMonthUsd;
  final int aiTextCallsTotal;
  final int aiPhotoCallsTotal;
  final String? aiCostTodayDate;
  final String? aiCostMonthKey;

  const ConfigEntity(this.hasAcceptedDisclaimer, this.hasAcceptedPolicy,
      this.hasAcceptedSendAnonymousData, this.appTheme,
      {this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.userCarbGoalPct,
      this.userProteinGoalPct,
      this.userFatGoalPct,
      this.dailyFocus = DailyFocusEntity.training,
      this.aiEstimatedCostTotalUsd = 0,
      this.aiEstimatedCostTodayUsd = 0,
      this.aiEstimatedCostMonthUsd = 0,
      this.aiTextCallsTotal = 0,
      this.aiPhotoCallsTotal = 0,
      this.aiCostTodayDate,
      this.aiCostMonthKey});

  factory ConfigEntity.fromConfigDBO(ConfigDBO dbo) => ConfigEntity(
        dbo.hasAcceptedDisclaimer,
        dbo.hasAcceptedPolicy,
        dbo.hasAcceptedSendAnonymousData,
        AppThemeEntity.fromAppThemeDBO(dbo.selectedAppTheme),
        usesImperialUnits: dbo.usesImperialUnits ?? false,
        userKcalAdjustment: dbo.userKcalAdjustment,
        userCarbGoalPct: dbo.userCarbGoalPct,
        userProteinGoalPct: dbo.userProteinGoalPct,
        userFatGoalPct: dbo.userFatGoalPct,
        dailyFocus: DailyFocusEntityX.fromStorageValue(dbo.dailyFocus),
        aiEstimatedCostTotalUsd: dbo.aiEstimatedCostTotalUsd ?? 0,
        aiEstimatedCostTodayUsd: dbo.aiEstimatedCostTodayUsd ?? 0,
        aiEstimatedCostMonthUsd: dbo.aiEstimatedCostMonthUsd ?? 0,
        aiTextCallsTotal: dbo.aiTextCallsTotal ?? 0,
        aiPhotoCallsTotal: dbo.aiPhotoCallsTotal ?? 0,
        aiCostTodayDate: dbo.aiCostTodayDate,
        aiCostMonthKey: dbo.aiCostMonthKey,
      );

  @override
  List<Object?> get props => [
        hasAcceptedDisclaimer,
        hasAcceptedPolicy,
        hasAcceptedSendAnonymousData,
        usesImperialUnits,
        userKcalAdjustment,
        userCarbGoalPct,
        userProteinGoalPct,
        userFatGoalPct,
        dailyFocus,
        aiEstimatedCostTotalUsd,
        aiEstimatedCostTodayUsd,
        aiEstimatedCostMonthUsd,
        aiTextCallsTotal,
        aiPhotoCallsTotal,
        aiCostTodayDate,
        aiCostMonthKey,
      ];
}
