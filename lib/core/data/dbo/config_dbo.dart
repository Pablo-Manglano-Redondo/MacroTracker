import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';

part 'config_dbo.g.dart';

@HiveType(typeId: 13)
@JsonSerializable() // Used for exporting to JSON
class ConfigDBO extends HiveObject {
  @HiveField(0)
  bool hasAcceptedDisclaimer;
  @HiveField(1)
  bool hasAcceptedPolicy;
  @HiveField(2)
  bool hasAcceptedSendAnonymousData;
  @HiveField(3)
  AppThemeDBO selectedAppTheme;
  @HiveField(4)
  bool? usesImperialUnits;
  @HiveField(5)
  double? userKcalAdjustment;
  @HiveField(6)
  double? userCarbGoalPct;
  @HiveField(7)
  double? userProteinGoalPct;
  @HiveField(8)
  double? userFatGoalPct;
  @HiveField(9)
  String? dailyFocus;
  @HiveField(10)
  double? aiEstimatedCostTotalUsd;
  @HiveField(11)
  double? aiEstimatedCostTodayUsd;
  @HiveField(12)
  double? aiEstimatedCostMonthUsd;
  @HiveField(13)
  int? aiTextCallsTotal;
  @HiveField(14)
  int? aiPhotoCallsTotal;
  @HiveField(15)
  String? aiCostTodayDate;
  @HiveField(16)
  String? aiCostMonthKey;
  @HiveField(17)
  String? trainingDayTemplate;
  @HiveField(18)
  String? selectedLocale;

  ConfigDBO(this.hasAcceptedDisclaimer, this.hasAcceptedPolicy,
      this.hasAcceptedSendAnonymousData, this.selectedAppTheme,
      {this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.dailyFocus = 'upperBody',
      this.selectedLocale});

  factory ConfigDBO.empty() =>
      ConfigDBO(false, false, false, AppThemeDBO.system);

  factory ConfigDBO.fromConfigEntity(ConfigEntity entity) => ConfigDBO(
      entity.hasAcceptedDisclaimer,
      entity.hasAcceptedPolicy,
      entity.hasAcceptedSendAnonymousData,
      AppThemeDBO.fromAppThemeEntity(entity.appTheme),
      usesImperialUnits: entity.usesImperialUnits,
      userKcalAdjustment: entity.userKcalAdjustment,
      dailyFocus: entity.dailyFocus.storageValue,
      selectedLocale: entity.selectedLocale)
    ..userCarbGoalPct = entity.userCarbGoalPct
    ..userProteinGoalPct = entity.userProteinGoalPct
    ..userFatGoalPct = entity.userFatGoalPct
    ..aiEstimatedCostTotalUsd = entity.aiEstimatedCostTotalUsd
    ..aiEstimatedCostTodayUsd = entity.aiEstimatedCostTodayUsd
    ..aiEstimatedCostMonthUsd = entity.aiEstimatedCostMonthUsd
    ..aiTextCallsTotal = entity.aiTextCallsTotal
    ..aiPhotoCallsTotal = entity.aiPhotoCallsTotal
    ..aiCostTodayDate = entity.aiCostTodayDate
    ..aiCostMonthKey = entity.aiCostMonthKey
    ..trainingDayTemplate = entity.trainingDayTemplate.storageValue;

  factory ConfigDBO.fromJson(Map<String, dynamic> json) =>
      _$ConfigDBOFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigDBOToJson(this);
}
