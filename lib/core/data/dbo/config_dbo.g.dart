// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigDBOAdapter extends TypeAdapter<ConfigDBO> {
  @override
  final int typeId = 13;

  @override
  ConfigDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigDBO(
      fields[0] as bool,
      fields[1] as bool,
      fields[2] as bool,
      fields[3] as AppThemeDBO,
      usesImperialUnits: fields[4] as bool?,
      userKcalAdjustment: fields[5] as double?,
      dailyFocus: fields[9] as String?,
      selectedLocale: fields[18] as String?,
      healthConnectAutoSyncEnabled: fields[19] as bool?,
    )
      ..userCarbGoalPct = fields[6] as double?
      ..userProteinGoalPct = fields[7] as double?
      ..userFatGoalPct = fields[8] as double?
      ..aiEstimatedCostTotalUsd = fields[10] as double?
      ..aiEstimatedCostTodayUsd = fields[11] as double?
      ..aiEstimatedCostMonthUsd = fields[12] as double?
      ..aiTextCallsTotal = fields[13] as int?
      ..aiPhotoCallsTotal = fields[14] as int?
      ..aiCostTodayDate = fields[15] as String?
      ..aiCostMonthKey = fields[16] as String?
      ..trainingDayTemplate = fields[17] as String?
      ..discardedHealthConnectActivityIds =
          (fields[20] as List?)?.cast<String>()
      ..mealRemindersEnabled = fields[21] as bool?
      ..mealReminderMorningMinutes = fields[22] as int?
      ..mealReminderLunchMinutes = fields[23] as int?
      ..mealReminderAfternoonMinutes = fields[24] as int?
      ..mealReminderEveningMinutes = fields[25] as int?
      ..googleDriveAutoBackupEnabled = fields[26] as bool?
      ..googleDriveLastBackupAttemptAt = fields[27] as String?
      ..googleDriveLastBackupSuccessAt = fields[28] as String?
      ..googleDriveLastBackupError = fields[29] as String?
      ..macroGoalMode = fields[30] as String?
      ..userCarbGoalGramPerKg = fields[31] as double?
      ..userProteinGoalGramPerKg = fields[32] as double?
      ..userFatGoalGramPerKg = fields[33] as double?;
  }

  @override
  void write(BinaryWriter writer, ConfigDBO obj) {
    writer
      ..writeByte(34)
      ..writeByte(0)
      ..write(obj.hasAcceptedDisclaimer)
      ..writeByte(1)
      ..write(obj.hasAcceptedPolicy)
      ..writeByte(2)
      ..write(obj.hasAcceptedSendAnonymousData)
      ..writeByte(3)
      ..write(obj.selectedAppTheme)
      ..writeByte(4)
      ..write(obj.usesImperialUnits)
      ..writeByte(5)
      ..write(obj.userKcalAdjustment)
      ..writeByte(6)
      ..write(obj.userCarbGoalPct)
      ..writeByte(7)
      ..write(obj.userProteinGoalPct)
      ..writeByte(8)
      ..write(obj.userFatGoalPct)
      ..writeByte(9)
      ..write(obj.dailyFocus)
      ..writeByte(10)
      ..write(obj.aiEstimatedCostTotalUsd)
      ..writeByte(11)
      ..write(obj.aiEstimatedCostTodayUsd)
      ..writeByte(12)
      ..write(obj.aiEstimatedCostMonthUsd)
      ..writeByte(13)
      ..write(obj.aiTextCallsTotal)
      ..writeByte(14)
      ..write(obj.aiPhotoCallsTotal)
      ..writeByte(15)
      ..write(obj.aiCostTodayDate)
      ..writeByte(16)
      ..write(obj.aiCostMonthKey)
      ..writeByte(17)
      ..write(obj.trainingDayTemplate)
      ..writeByte(18)
      ..write(obj.selectedLocale)
      ..writeByte(19)
      ..write(obj.healthConnectAutoSyncEnabled)
      ..writeByte(20)
      ..write(obj.discardedHealthConnectActivityIds)
      ..writeByte(21)
      ..write(obj.mealRemindersEnabled)
      ..writeByte(22)
      ..write(obj.mealReminderMorningMinutes)
      ..writeByte(23)
      ..write(obj.mealReminderLunchMinutes)
      ..writeByte(24)
      ..write(obj.mealReminderAfternoonMinutes)
      ..writeByte(25)
      ..write(obj.mealReminderEveningMinutes)
      ..writeByte(26)
      ..write(obj.googleDriveAutoBackupEnabled)
      ..writeByte(27)
      ..write(obj.googleDriveLastBackupAttemptAt)
      ..writeByte(28)
      ..write(obj.googleDriveLastBackupSuccessAt)
      ..writeByte(29)
      ..write(obj.googleDriveLastBackupError)
      ..writeByte(30)
      ..write(obj.macroGoalMode)
      ..writeByte(31)
      ..write(obj.userCarbGoalGramPerKg)
      ..writeByte(32)
      ..write(obj.userProteinGoalGramPerKg)
      ..writeByte(33)
      ..write(obj.userFatGoalGramPerKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigDBO _$ConfigDBOFromJson(Map<String, dynamic> json) => ConfigDBO(
      json['hasAcceptedDisclaimer'] as bool,
      json['hasAcceptedPolicy'] as bool,
      json['hasAcceptedSendAnonymousData'] as bool,
      $enumDecode(_$AppThemeDBOEnumMap, json['selectedAppTheme']),
      usesImperialUnits: json['usesImperialUnits'] as bool? ?? false,
      userKcalAdjustment: (json['userKcalAdjustment'] as num?)?.toDouble(),
      dailyFocus: json['dailyFocus'] as String? ?? 'upperBody',
      selectedLocale: json['selectedLocale'] as String?,
      healthConnectAutoSyncEnabled:
          json['healthConnectAutoSyncEnabled'] as bool? ?? true,
    )
      ..userCarbGoalPct = (json['userCarbGoalPct'] as num?)?.toDouble()
      ..userProteinGoalPct = (json['userProteinGoalPct'] as num?)?.toDouble()
      ..userFatGoalPct = (json['userFatGoalPct'] as num?)?.toDouble()
      ..aiEstimatedCostTotalUsd =
          (json['aiEstimatedCostTotalUsd'] as num?)?.toDouble()
      ..aiEstimatedCostTodayUsd =
          (json['aiEstimatedCostTodayUsd'] as num?)?.toDouble()
      ..aiEstimatedCostMonthUsd =
          (json['aiEstimatedCostMonthUsd'] as num?)?.toDouble()
      ..aiTextCallsTotal = (json['aiTextCallsTotal'] as num?)?.toInt()
      ..aiPhotoCallsTotal = (json['aiPhotoCallsTotal'] as num?)?.toInt()
      ..aiCostTodayDate = json['aiCostTodayDate'] as String?
      ..aiCostMonthKey = json['aiCostMonthKey'] as String?
      ..trainingDayTemplate = json['trainingDayTemplate'] as String?
      ..discardedHealthConnectActivityIds =
          (json['discardedHealthConnectActivityIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList()
      ..mealRemindersEnabled = json['mealRemindersEnabled'] as bool?
      ..mealReminderMorningMinutes =
          (json['mealReminderMorningMinutes'] as num?)?.toInt()
      ..mealReminderLunchMinutes =
          (json['mealReminderLunchMinutes'] as num?)?.toInt()
      ..mealReminderAfternoonMinutes =
          (json['mealReminderAfternoonMinutes'] as num?)?.toInt()
      ..mealReminderEveningMinutes =
          (json['mealReminderEveningMinutes'] as num?)?.toInt()
      ..googleDriveAutoBackupEnabled =
          json['googleDriveAutoBackupEnabled'] as bool?
      ..googleDriveLastBackupAttemptAt =
          json['googleDriveLastBackupAttemptAt'] as String?
      ..googleDriveLastBackupSuccessAt =
          json['googleDriveLastBackupSuccessAt'] as String?
      ..googleDriveLastBackupError =
          json['googleDriveLastBackupError'] as String?
      ..macroGoalMode = json['macroGoalMode'] as String?
      ..userCarbGoalGramPerKg =
          (json['userCarbGoalGramPerKg'] as num?)?.toDouble()
      ..userProteinGoalGramPerKg =
          (json['userProteinGoalGramPerKg'] as num?)?.toDouble()
      ..userFatGoalGramPerKg =
          (json['userFatGoalGramPerKg'] as num?)?.toDouble();

Map<String, dynamic> _$ConfigDBOToJson(ConfigDBO instance) => <String, dynamic>{
      'hasAcceptedDisclaimer': instance.hasAcceptedDisclaimer,
      'hasAcceptedPolicy': instance.hasAcceptedPolicy,
      'hasAcceptedSendAnonymousData': instance.hasAcceptedSendAnonymousData,
      'selectedAppTheme': _$AppThemeDBOEnumMap[instance.selectedAppTheme]!,
      'usesImperialUnits': instance.usesImperialUnits,
      'userKcalAdjustment': instance.userKcalAdjustment,
      'userCarbGoalPct': instance.userCarbGoalPct,
      'userProteinGoalPct': instance.userProteinGoalPct,
      'userFatGoalPct': instance.userFatGoalPct,
      'dailyFocus': instance.dailyFocus,
      'aiEstimatedCostTotalUsd': instance.aiEstimatedCostTotalUsd,
      'aiEstimatedCostTodayUsd': instance.aiEstimatedCostTodayUsd,
      'aiEstimatedCostMonthUsd': instance.aiEstimatedCostMonthUsd,
      'aiTextCallsTotal': instance.aiTextCallsTotal,
      'aiPhotoCallsTotal': instance.aiPhotoCallsTotal,
      'aiCostTodayDate': instance.aiCostTodayDate,
      'aiCostMonthKey': instance.aiCostMonthKey,
      'trainingDayTemplate': instance.trainingDayTemplate,
      'selectedLocale': instance.selectedLocale,
      'healthConnectAutoSyncEnabled': instance.healthConnectAutoSyncEnabled,
      'discardedHealthConnectActivityIds':
          instance.discardedHealthConnectActivityIds,
      'mealRemindersEnabled': instance.mealRemindersEnabled,
      'mealReminderMorningMinutes': instance.mealReminderMorningMinutes,
      'mealReminderLunchMinutes': instance.mealReminderLunchMinutes,
      'mealReminderAfternoonMinutes': instance.mealReminderAfternoonMinutes,
      'mealReminderEveningMinutes': instance.mealReminderEveningMinutes,
      'googleDriveAutoBackupEnabled': instance.googleDriveAutoBackupEnabled,
      'googleDriveLastBackupAttemptAt': instance.googleDriveLastBackupAttemptAt,
      'googleDriveLastBackupSuccessAt': instance.googleDriveLastBackupSuccessAt,
      'googleDriveLastBackupError': instance.googleDriveLastBackupError,
      'macroGoalMode': instance.macroGoalMode,
      'userCarbGoalGramPerKg': instance.userCarbGoalGramPerKg,
      'userProteinGoalGramPerKg': instance.userProteinGoalGramPerKg,
      'userFatGoalGramPerKg': instance.userFatGoalGramPerKg,
    };

const _$AppThemeDBOEnumMap = {
  AppThemeDBO.light: 'light',
  AppThemeDBO.dark: 'dark',
  AppThemeDBO.system: 'system',
};
