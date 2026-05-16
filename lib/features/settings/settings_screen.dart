import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/presentation/widgets/app_banner_version.dart';
import 'package:macrotracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:macrotracker/core/utils/app_const.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/theme_mode_provider.dart';
import 'package:macrotracker/core/utils/url_const.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:macrotracker/features/settings/presentation/widgets/calculations_dialog.dart';
import 'package:macrotracker/features/settings/presentation/widgets/drive_backup_dialog.dart';
import 'package:macrotracker/features/settings/presentation/widgets/export_import_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;
  late ProfileBloc _profileBloc;
  late HomeBloc _homeBloc;
  late DiaryBloc _diaryBloc;
  late CalendarDayBloc _calendarDayBloc;
  Future<HealthConnectSyncStatusEntity>? _healthConnectStatusFuture;

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsLabel),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: _settingsBloc,
        builder: (context, state) {
          if (state is SettingsInitial) {
            _settingsBloc.add(LoadSettingsEvent());
          } else if (state is SettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoadedState) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _SettingsSection(
                  title: _isEs(context) ? 'Seguimiento' : 'Tracking',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.ac_unit_outlined),
                        title: Text(S.of(context).settingsUnitsLabel),
                        onTap: () => _showUnitsDialog(
                          context,
                          state.usesImperialUnits,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calculate_outlined),
                        title: Text(S.of(context).settingsCalculationsLabel),
                        onTap: () => _showCalculationsDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: Text(_mealReminderTitle(context)),
                        subtitle: Text(
                          state.mealRemindersEnabled
                              ? _mealReminderSummary(state)
                              : _mealReminderOffLabel(context),
                        ),
                        onTap: () => _showMealReminderDialog(context, state),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: _isEs(context) ? 'Apariencia' : 'Appearance',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.brightness_medium_outlined),
                        title: Text(S.of(context).settingsThemeLabel),
                        onTap: () => _showThemeDialog(context, state.appTheme),
                      ),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text(S.of(context).settingsLanguageLabel),
                        onTap: () => _showLanguageDialog(
                          context,
                          state.currentLocale,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: 'Health Connect',
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.health_and_safety_outlined),
                        title: Text(S.of(context).healthConnectAutoSyncTitle),
                        subtitle: Text(
                          S.of(context).healthConnectAutoSyncSubtitle,
                        ),
                        value: state.healthConnectAutoSyncEnabled,
                        onChanged: (value) async {
                          await _settingsBloc
                              .setHealthConnectAutoSyncEnabled(value);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? S
                                          .of(context)
                                          .healthConnectAutoSyncEnabledMessage
                                      : S
                                          .of(context)
                                          .healthConnectAutoSyncDisabledMessage,
                                ),
                              ),
                            );
                          }
                          _settingsBloc.add(LoadSettingsEvent());
                          if (mounted) {
                            setState(() {});
                            _refreshHealthConnectStatus();
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.sync_outlined),
                        title: Text(S.of(context).healthConnectSyncNowTitle),
                        subtitle: FutureBuilder<HealthConnectSyncStatusEntity>(
                          future: _healthConnectStatusFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                S.of(context).healthConnectStatusUnavailable,
                              );
                            }
                            if (!snapshot.hasData) {
                              return Text(
                                S.of(context).healthConnectStatusChecking,
                              );
                            }
                            return Text(
                              _buildHealthConnectStatusText(snapshot.data!),
                            );
                          },
                        ),
                        onTap: () => _syncHealthConnectNow(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: _isEs(context)
                      ? 'Datos y privacidad'
                      : 'Data and privacy',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.import_export),
                        title: Text(S.of(context).exportImportLabel),
                        onTap: () => _showExportImportDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.cloud_upload_outlined),
                        title: Text(
                          _isEs(context)
                              ? 'Backup en Google Drive'
                              : 'Google Drive backup',
                        ),
                        subtitle: Text(
                          _isEs(context)
                              ? 'Copia cifrada manual o diaria en tu Drive'
                              : 'Manual or daily encrypted backup to your Drive',
                        ),
                        onTap: () => _showDriveBackupDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(S.of(context).settingsDisclaimerLabel),
                        onTap: () => _showDisclaimerDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: 'App',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.paid_outlined),
                        title: Text(S.of(context).settingsAiCostLabel),
                        subtitle: Text(
                          'Total \$${state.aiEstimatedCostTotalUsd.toStringAsFixed(3)} | ${S.of(context).todayLabel} \$${state.aiEstimatedCostTodayUsd.toStringAsFixed(3)}',
                        ),
                        onTap: () => _showAiCostDialog(context, state),
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(S.of(context).settingAboutLabel),
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppBannerVersion(versionNumber: state.versionNumber),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, bool usesImperialUnits) async {
    SystemDropDownType selectedUnit = usesImperialUnits
        ? SystemDropDownType.imperial
        : SystemDropDownType.metric;
    final shouldUpdate = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(S.of(context).settingsUnitsLabel),
              content: Wrap(children: [
                Column(
                  children: [
                    DropdownButtonFormField(
                      initialValue: selectedUnit,
                      decoration: InputDecoration(
                        enabled: true,
                        filled: false,
                        labelText: S.of(context).settingsSystemLabel,
                      ),
                      onChanged: (value) {
                        selectedUnit = value ?? SystemDropDownType.metric;
                      },
                      items: [
                        DropdownMenuItem(
                            value: SystemDropDownType.metric,
                            child: Text(S.of(context).settingsMetricLabel)),
                        DropdownMenuItem(
                            value: SystemDropDownType.imperial,
                            child: Text(S.of(context).settingsImperialLabel))
                      ],
                    )
                  ],
                ),
              ]),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(S.of(context).dialogOKLabel))
              ]);
        });
    if (shouldUpdate == true) {
      _settingsBloc
          .setUsesImperialUnits(selectedUnit == SystemDropDownType.imperial);
      _settingsBloc.add(LoadSettingsEvent());

      _profileBloc.add(LoadProfileEvent());
      _homeBloc.add(LoadItemsEvent());
      _diaryBloc.add(const LoadDiaryYearEvent());
    }
  }

  void _showCalculationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CalculationsDialog(
        settingsBloc: _settingsBloc,
        profileBloc: _profileBloc,
        homeBloc: _homeBloc,
        diaryBloc: _diaryBloc,
        calendarDayBloc: _calendarDayBloc,
      ),
    );
  }

  void _showExportImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportImportDialog(),
    );
  }

  void _showDriveBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DriveBackupDialog(),
    );
  }

  Future<void> _showMealReminderDialog(
      BuildContext context, SettingsLoadedState state) async {
    var enabled = state.mealRemindersEnabled;
    var morningMinutes = state.mealReminderMorningMinutes;
    var lunchMinutes = state.mealReminderLunchMinutes;
    var afternoonMinutes = state.mealReminderAfternoonMinutes;
    var eveningMinutes = state.mealReminderEveningMinutes;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(_mealReminderTitle(context)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_mealReminderEnabledLabel(context)),
                    subtitle: Text(_mealReminderSubtitle(context)),
                    value: enabled,
                    onChanged: (value) {
                      setState(() {
                        enabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _ReminderTimeTile(
                    label: _morningReminderLabel(context),
                    value: morningMinutes,
                    enabled: enabled,
                    onTap: () async {
                      final minutes = await _pickReminderTime(
                        context,
                        morningMinutes,
                      );
                      if (minutes == null) {
                        return;
                      }
                      setState(() {
                        morningMinutes = minutes;
                      });
                    },
                  ),
                  _ReminderTimeTile(
                    label: _afterLunchReminderLabel(context),
                    value: lunchMinutes,
                    enabled: enabled,
                    onTap: () async {
                      final minutes =
                          await _pickReminderTime(context, lunchMinutes);
                      if (minutes == null) {
                        return;
                      }
                      setState(() {
                        lunchMinutes = minutes;
                      });
                    },
                  ),
                  _ReminderTimeTile(
                    label: _afternoonReminderLabel(context),
                    value: afternoonMinutes,
                    enabled: enabled,
                    onTap: () async {
                      final minutes = await _pickReminderTime(
                        context,
                        afternoonMinutes,
                      );
                      if (minutes == null) {
                        return;
                      }
                      setState(() {
                        afternoonMinutes = minutes;
                      });
                    },
                  ),
                  _ReminderTimeTile(
                    label: _eveningReminderLabel(context),
                    value: eveningMinutes,
                    enabled: enabled,
                    onTap: () async {
                      final minutes =
                          await _pickReminderTime(context, eveningMinutes);
                      if (minutes == null) {
                        return;
                      }
                      setState(() {
                        eveningMinutes = minutes;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(S.of(context).dialogCancelLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(S.of(context).dialogOKLabel),
              ),
            ],
          ),
        );
      },
    );

    if (saved != true) {
      return;
    }

    final permissionGranted = await _settingsBloc.setMealReminderConfig(
      enabled: enabled,
      morningMinutes: morningMinutes,
      lunchMinutes: lunchMinutes,
      afternoonMinutes: afternoonMinutes,
      eveningMinutes: eveningMinutes,
    );

    _settingsBloc.add(LoadSettingsEvent());
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? (permissionGranted
                  ? _mealReminderSavedMessage(context)
                  : _mealReminderPermissionDeniedMessage(context))
              : _mealReminderDisabledMessage(context),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, AppThemeEntity currentAppTheme) {
    AppThemeEntity selectedTheme = currentAppTheme;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsThemeLabel),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return RadioGroup<AppThemeEntity>(
                  groupValue: selectedTheme,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      selectedTheme = value;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<AppThemeEntity>(
                        title:
                            Text(S.of(context).settingsThemeSystemDefaultLabel),
                        value: AppThemeEntity.system,
                      ),
                      RadioListTile<AppThemeEntity>(
                        title: Text(S.of(context).settingsThemeLightLabel),
                        value: AppThemeEntity.light,
                      ),
                      RadioListTile<AppThemeEntity>(
                        title: Text(S.of(context).settingsThemeDarkLabel),
                        value: AppThemeEntity.dark,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setAppTheme(selectedTheme);
                    _settingsBloc.add(LoadSettingsEvent());
                    setState(() {
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateTheme(selectedTheme);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  void _showLanguageDialog(BuildContext context, String? currentLocale) {
    String? selectedLocale = currentLocale;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsSelectLanguageTitle),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String?>(
                      title: Text(
                          S.of(context).settingsLanguageSystemDefaultLabel),
                      value: null,
                      groupValue: selectedLocale,
                      onChanged: (value) {
                        setState(() => selectedLocale = value);
                      },
                    ),
                    RadioListTile<String?>(
                      title: Text(S.of(context).settingsLanguageEnglish),
                      value: 'en',
                      groupValue: selectedLocale,
                      onChanged: (value) {
                        setState(() => selectedLocale = value);
                      },
                    ),
                    RadioListTile<String?>(
                      title: Text(S.of(context).settingsLanguageSpanish),
                      value: 'es',
                      groupValue: selectedLocale,
                      onChanged: (value) {
                        setState(() => selectedLocale = value);
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogCancelLabel)),
              TextButton(
                  onPressed: () async {
                    _settingsBloc.setLocale(selectedLocale);
                    _settingsBloc.add(LoadSettingsEvent());
                    if (context.mounted) {
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateLocale(selectedLocale != null
                              ? Locale(selectedLocale!)
                              : null);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const DisclaimerDialog();
        });
  }

  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final versionLabel = packageInfo.buildNumber.isNotEmpty
        ? '${packageInfo.version} (${packageInfo.buildNumber})'
        : packageInfo.version;

    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/icon/ont_logo_square.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).appTitle),
                      const SizedBox(height: 2),
                      Text(
                        versionLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).appDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _AboutInfoRow(
                      label: _isEs(context) ? 'Proyecto' : 'Project',
                      value: _isEs(context)
                          ? 'Seguimiento de calorías, macros, hábitos, actividad y backups locales/Drive.'
                          : 'Calorie, macro, habit, activity, and local/Drive backup tracking.',
                    ),
                    _AboutInfoRow(
                      label: _isEs(context) ? 'Licencia' : 'License',
                      value: S.of(context).appLicenseLabel,
                    ),
                    _AboutInfoRow(
                      label: _isEs(context) ? 'Modelo' : 'Model',
                      value: _isEs(context)
                          ? 'App local-first con sincronización opcional y funciones de IA para interpretar comidas.'
                          : 'Local-first app with optional sync and AI-assisted meal interpretation.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).disclaimerText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _launchSourceCodeUrl(context),
                icon: const Icon(Icons.code_outlined),
                label: Text(S.of(context).settingsSourceCodeLabel),
              ),
              TextButton.icon(
                onPressed: () => _launchPrivacyPolicyUrl(context),
                icon: const Icon(Icons.policy_outlined),
                label: Text(S.of(context).privacyPolicyLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(S.of(context).dialogOKLabel),
              ),
            ],
          );
        },
      );
    }
  }

  void _showAiCostDialog(BuildContext context, SettingsLoadedState state) {
    final currency = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '\$',
      decimalDigits: 3,
    );
    final totalCalls = state.aiTextCallsTotal + state.aiPhotoCallsTotal;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).settingsAiCostLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).settingsAiCostTotal(
                currency.format(state.aiEstimatedCostTotalUsd))),
            Text(S.of(context).settingsAiCostToday(
                currency.format(state.aiEstimatedCostTodayUsd))),
            Text(S.of(context).settingsAiCostMonth(
                currency.format(state.aiEstimatedCostMonthUsd))),
            const SizedBox(height: 10),
            Text(S.of(context).settingsAiCallsTotal(totalCalls)),
            Text(S.of(context).settingsAiCallsText(state.aiTextCallsTotal)),
            Text(S.of(context).settingsAiCallsPhoto(state.aiPhotoCallsTotal)),
            const SizedBox(height: 10),
            Text(
              S.of(context).settingsAiCostDescription,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () async {
              await _settingsBloc.resetAiCostTracking();
              if (context.mounted) {
                Navigator.of(context).pop();
                _settingsBloc.add(LoadSettingsEvent());
              }
            },
            child: Text(S.of(context).settingsResetLabel),
          ),
        ],
      ),
    );
  }

  void _launchSourceCodeUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(AppConst.sourceCodeUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchPrivacyPolicyUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(URLConst.privacyPolicyURLEn);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchUrl(BuildContext context, Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorOpeningBrowser)));
      }
    }
  }

  String _buildHealthConnectStatusText(HealthConnectSyncStatusEntity status) {
    if (!status.isAvailable) {
      return S.of(context).healthConnectStatusUnavailable;
    }
    if (!status.isAutoSyncEnabled) {
      return S.of(context).healthConnectStatusAutoSyncDisabled;
    }
    if (!status.hasActivityRecognitionPermission) {
      return S.of(context).healthConnectStatusActivityPermissionRequired;
    }
    if (!status.hasHealthPermissions) {
      return _isEs(context)
          ? 'Health Connect conectado. Si el sync falla, revisa los permisos.'
          : 'Health Connect connected. If sync fails, review permissions.';
    }
    return S.of(context).healthConnectStatusReady;
  }

  Future<void> _syncHealthConnectNow(BuildContext context) async {
    final report = await _settingsBloc.syncHealthConnectNowWithReport();
    final didUpdate = report.didUpdate;
    if (didUpdate) {
      _homeBloc.add(const LoadItemsEvent());
      _diaryBloc.add(const LoadDiaryYearEvent());
      _calendarDayBloc.add(RefreshCalendarDayEvent());
    }
    if (!context.mounted) {
      return;
    }
    _refreshHealthConnectStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _buildHealthConnectSyncMessage(report),
        ),
      ),
    );
    setState(() {});
  }

  String _buildHealthConnectSyncMessage(HealthConnectSyncReport report) {
    if (!report.didUpdate) {
      if (_isEs(context)) {
        return 'Health Connect: 0 cambios. Leidos ${report.workoutsRead}, importables ${report.workoutsFiltered}, descartados ${report.discardedWorkoutIds}.';
      }
      return 'Health Connect: 0 changes. Read ${report.workoutsRead}, importable ${report.workoutsFiltered}, discarded ${report.discardedWorkoutIds}.';
    }
    if (report.workoutsImported > 0 || report.workoutsUpdated > 0) {
      final imported = report.workoutsImported;
      final updated = report.workoutsUpdated;
      if (_isEs(context)) {
        return 'Health Connect: $imported actividades nuevas y $updated reparadas.';
      }
      return 'Health Connect: $imported new workouts and $updated repaired.';
    }
    return S.of(context).healthConnectSyncSuccess;
  }

  void _refreshHealthConnectStatus() {
    _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
  }

  Future<void> _requestHealthConnectPermissions(BuildContext context) async {
    final status = await _settingsBloc.requestHealthConnectPermissions();
    if (!context.mounted) {
      return;
    }
    _refreshHealthConnectStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status.canSync
              ? S.of(context).healthConnectPermissionsUpdated
              : S.of(context).healthConnectPermissionsMissing,
        ),
      ),
    );
    setState(() {});
  }

  Future<int?> _pickReminderTime(
      BuildContext context, int currentMinutes) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return Theme(
          data: theme.copyWith(
            timePickerTheme: theme.timePickerTheme.copyWith(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              hourMinuteTextStyle: theme.textTheme.displayMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
              dayPeriodTextStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              dialBackgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.28 : 0.58,
              ),
              dialHandColor: colorScheme.primary.withValues(
                alpha: isDark ? 0.78 : 0.70,
              ),
              dialTextStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              helpTextStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
    if (time == null) {
      return null;
    }
    return time.hour * 60 + time.minute;
  }

  String _mealReminderTitle(BuildContext context) =>
      _isEs(context) ? 'Recordatorios de comidas' : 'Meal reminders';

  String _mealReminderOffLabel(BuildContext context) =>
      _isEs(context) ? 'Desactivados' : 'Disabled';

  String _mealReminderEnabledLabel(BuildContext context) =>
      _isEs(context) ? 'Activar recordatorios' : 'Enable reminders';

  String _mealReminderSubtitle(BuildContext context) => _isEs(context)
      ? 'Android te avisara para registrar desayuno, comida, snack y cena.'
      : 'Android will remind you to log breakfast, lunch, snack and dinner.';

  String _morningReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Mañana' : 'Morning';

  String _afterLunchReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Después de comer' : 'After lunch';

  String _afternoonReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Tarde' : 'Afternoon';

  String _eveningReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Cena' : 'Dinner';

  String _mealReminderSavedMessage(BuildContext context) => _isEs(context)
      ? 'Recordatorios guardados y programados.'
      : 'Reminders saved and scheduled.';

  String _mealReminderDisabledMessage(BuildContext context) =>
      _isEs(context) ? 'Recordatorios desactivados.' : 'Reminders disabled.';

  String _mealReminderPermissionDeniedMessage(BuildContext context) =>
      _isEs(context)
          ? 'No se pudo activar porque Android no concedio permisos.'
          : 'Could not enable reminders because Android permission was denied.';

  String _mealReminderSummary(SettingsLoadedState state) {
    return [
      _formatMinutesAsTime(context, state.mealReminderMorningMinutes),
      _formatMinutesAsTime(context, state.mealReminderLunchMinutes),
      _formatMinutesAsTime(context, state.mealReminderAfternoonMinutes),
      _formatMinutesAsTime(context, state.mealReminderEveningMinutes),
    ].join(' | ');
  }

  String _formatMinutesAsTime(BuildContext context, int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final time = TimeOfDay(hour: hour, minute: minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: true,
    );
  }

  bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es';
}

class _AboutInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Card(
          child: child,
        ),
      ],
    );
  }
}

class _ReminderTimeTile extends StatelessWidget {
  final String label;
  final int value;
  final bool enabled;
  final VoidCallback onTap;

  const _ReminderTimeTile({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: value ~/ 60, minute: value % 60);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      title: Text(label),
      subtitle: Text(
        MaterialLocalizations.of(context).formatTimeOfDay(
          time,
          alwaysUse24HourFormat: true,
        ),
      ),
      trailing: const Icon(Icons.schedule_outlined),
      onTap: enabled ? onTap : null,
    );
  }
}
