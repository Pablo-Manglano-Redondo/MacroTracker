import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/presentation/widgets/app_banner_version.dart';
import 'package:macrotracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:macrotracker/core/utils/app_const.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
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
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
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
  bool _isPremium = false;
  AiTrialState? _aiTrialState;
  bool _isPlanActionLoading = false;

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    if (_supportsHealthIntegration) {
      _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
    }
    _refreshPlanStatus();
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
                _buildPlanSection(context),
                const SizedBox(height: 18),
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
                if (_supportsHealthIntegration) ...[
                  _SettingsSection(
                    title: _healthIntegrationName(context),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary:
                              const Icon(Icons.health_and_safety_outlined),
                          title: Text(_healthAutoSyncTitle(context)),
                          subtitle: Text(_healthAutoSyncSubtitle(context)),
                          value: state.healthConnectAutoSyncEnabled,
                          onChanged: (value) async {
                            await _settingsBloc
                                .setHealthConnectAutoSyncEnabled(value);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? _healthAutoSyncEnabledMessage(context)
                                        : _healthAutoSyncDisabledMessage(
                                            context),
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
                          title: Text(_healthSyncNowTitle(context)),
                          subtitle:
                              FutureBuilder<HealthConnectSyncStatusEntity>(
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
                ],
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
                          _driveBackupSubtitle(context),
                        ),
                        onTap: () => _showDriveBackupDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.assignment_ind_outlined),
                        title: Text(
                          _isEs(context)
                              ? 'Plan de mi nutricionista'
                              : 'My coach plan',
                        ),
                        subtitle: Text(
                          _isEs(context)
                              ? 'Invitación, consentimiento y acceso compartido.'
                              : 'Invite, consent, and shared access.',
                        ),
                        onTap: () => Navigator.of(context).pushNamed(
                          NavigationOptions.professionalPlanRoute,
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.bug_report_outlined),
                        title: Text(S.of(context).sendAnonymousUserData),
                        subtitle: Text(
                          _isEs(context)
                              ? 'Puedes activarlo o desactivarlo en cualquier momento.'
                              : 'You can turn this on or off at any time.',
                        ),
                        value: state.sendAnonymousData,
                        onChanged: (value) async {
                          await _settingsBloc
                              .setHasAcceptedAnonymousData(value);
                          await locator<ConversionAnalyticsService>()
                              .setEnabled(value);
                          _settingsBloc.add(LoadSettingsEvent());
                        },
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
                  title: _isEs(context)
                      ? 'Soporte y sugerencias'
                      : 'Support and feedback',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bug_report_outlined),
                        title: Text(
                          _isEs(context) ? 'Reportar un bug' : 'Report a bug',
                        ),
                        subtitle: Text(
                          _isEs(context)
                              ? 'Informanos sobre un problema en la aplicacion.'
                              : 'Let us know about an issue in the app.',
                        ),
                        onTap: () => _reportBug(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(
                          _isEs(context)
                              ? 'Sugerir funcionalidad'
                              : 'Suggest a feature',
                        ),
                        subtitle: Text(
                          _isEs(context)
                              ? '¿Que te gustaria ver en MacroTracker?'
                              : 'What would you like to see in MacroTracker?',
                        ),
                        onTap: () => _requestFeature(context),
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
    var selectedLocale = currentLocale ?? 'system';
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).settingsSelectLanguageTitle),
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return RadioGroup<String>(
                  groupValue: selectedLocale,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedLocale = value);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: Text(
                            S.of(context).settingsLanguageSystemDefaultLabel),
                        value: 'system',
                      ),
                      RadioListTile<String>(
                        title: Text(S.of(context).settingsLanguageEnglish),
                        value: 'en',
                      ),
                      RadioListTile<String>(
                        title: Text(S.of(context).settingsLanguageSpanish),
                        value: 'es',
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
                    final localeToSave =
                        selectedLocale == 'system' ? null : selectedLocale;
                    _settingsBloc.setLocale(localeToSave);
                    _settingsBloc.add(LoadSettingsEvent());
                    if (context.mounted) {
                      Provider.of<ThemeModeProvider>(context, listen: false)
                          .updateLocale(localeToSave != null
                              ? Locale(localeToSave)
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
                    'assets/icon/macrotracker_logo_square.png',
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

  void _launchSourceCodeUrl(BuildContext context) async {
    final sourceCodeUri = Uri.parse(AppConst.sourceCodeUrl);
    _launchUrl(context, sourceCodeUri);
  }

  void _launchPrivacyPolicyUrl(BuildContext context) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final privacyPolicyUrl = languageCode == 'es'
        ? URLConst.privacyPolicyURLEs
        : URLConst.privacyPolicyURLEn;
    final sourceCodeUri = Uri.parse(privacyPolicyUrl);
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

  void _reportBug(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: AppConst.reportErrorEmail,
      queryParameters: {
        'subject': 'MacroTracker - Bug Report',
        'body': 'Por favor, describe el bug aqui / Please describe the bug here:\n\n\n\n---\nInformacion del sistema / System info:\nPlatform: ${Platform.isAndroid ? 'Android' : 'iOS'}\n',
      },
    );
    _launchUrl(context, emailUri);
  }

  void _requestFeature(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: AppConst.reportErrorEmail,
      queryParameters: {
        'subject': 'MacroTracker - Feature Request',
        'body': 'Describe la funcionalidad que te gustaria ver / Describe the feature you would like to see:\n\n\n',
      },
    );
    _launchUrl(context, emailUri);
  }

  String _buildHealthConnectStatusText(HealthConnectSyncStatusEntity status) {
    if (!status.isAvailable) {
      return _isEs(context)
          ? '${_healthIntegrationName(context)} no esta disponible en este dispositivo.'
          : '${_healthIntegrationName(context)} is not available on this device.';
    }
    if (!status.isAutoSyncEnabled) {
      return S.of(context).healthConnectStatusAutoSyncDisabled;
    }
    if (!status.hasActivityRecognitionPermission) {
      return S.of(context).healthConnectStatusActivityPermissionRequired;
    }
    if (!status.hasHealthPermissions) {
      return _isEs(context)
          ? '${_healthIntegrationName(context)} conectado. Si el sync falla, revisa los permisos.'
          : '${_healthIntegrationName(context)} connected. If sync fails, review permissions.';
    }
    if (!status.hasStepsPermission) {
      return _isEs(context)
          ? 'Falta permiso de pasos. El sync será parcial.'
          : 'Steps permission missing. Sync will be partial.';
    }
    if (!status.hasWorkoutSupplementPermission) {
      return _isEs(context)
          ? 'Faltan permisos extra de entreno. Algunas calorías pueden quedar en 0.'
          : 'Workout detail permissions missing. Some calories may stay at 0.';
    }
    return _isEs(context)
        ? '${_healthIntegrationName(context)} conectado. Sueño, pasos y entrenamientos pueden sincronizarse automaticamente.'
        : '${_healthIntegrationName(context)} connected. Sleep, steps, and workouts can sync automatically.';
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
        return '${_healthIntegrationName(context)}: 0 cambios. Leidos ${report.workoutsRead}, importables ${report.workoutsFiltered}, descartados ${report.discardedWorkoutIds}.';
      }
      return '${_healthIntegrationName(context)}: 0 changes. Read ${report.workoutsRead}, importable ${report.workoutsFiltered}, discarded ${report.discardedWorkoutIds}.';
    }
    if (report.workoutsImported > 0 || report.workoutsUpdated > 0) {
      final imported = report.workoutsImported;
      final updated = report.workoutsUpdated;
      if (_isEs(context)) {
        return '${_healthIntegrationName(context)}: $imported actividades nuevas y $updated reparadas.';
      }
      return '${_healthIntegrationName(context)}: $imported new workouts and $updated repaired.';
    }
    return _isEs(context)
        ? 'Datos de ${_healthIntegrationName(context)} sincronizados, incluidas actividades.'
        : '${_healthIntegrationName(context)} data synced, including workouts.';
  }

  void _refreshHealthConnectStatus() {
    _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
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
      ? 'Android te avisar\u00e1 para registrar desayuno, comida, snack y cena.'
      : 'Android will remind you to log breakfast, lunch, snack and dinner.';

  String _morningReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Ma\u00f1ana' : 'Morning';

  String _afterLunchReminderLabel(BuildContext context) =>
      _isEs(context) ? 'Despu\u00e9s de comer' : 'After lunch';

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
          ? 'No se pudo activar porque Android no concedi\u00f3 permisos.'
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

  bool get _supportsHealthIntegration => Platform.isAndroid || Platform.isIOS;

  String _healthIntegrationName(BuildContext context) {
    if (Platform.isIOS) {
      return 'Apple Health';
    }
    return 'Health Connect';
  }

  String _healthAutoSyncTitle(BuildContext context) {
    if (Platform.isIOS) {
      return _isEs(context)
          ? 'Auto-sync de Apple Health'
          : 'Apple Health auto-sync';
    }
    return S.of(context).healthConnectAutoSyncTitle;
  }

  String _healthAutoSyncSubtitle(BuildContext context) {
    if (Platform.isIOS) {
      return _isEs(context)
          ? 'Sincroniza sueño, pasos y entrenamientos automáticamente al abrir la app.'
          : 'Sync sleep, steps, and workouts automatically on app open.';
    }
    return S.of(context).healthConnectAutoSyncSubtitle;
  }

  String _healthSyncNowTitle(BuildContext context) {
    if (Platform.isIOS) {
      return _isEs(context)
          ? 'Sincronizar Apple Health ahora'
          : 'Sync Apple Health now';
    }
    return S.of(context).healthConnectSyncNowTitle;
  }

  String _healthAutoSyncEnabledMessage(BuildContext context) {
    if (Platform.isIOS) {
      return _isEs(context)
          ? 'Auto-sync de Apple Health activado.'
          : 'Apple Health auto-sync enabled.';
    }
    return S.of(context).healthConnectAutoSyncEnabledMessage;
  }

  String _healthAutoSyncDisabledMessage(BuildContext context) {
    if (Platform.isIOS) {
      return _isEs(context)
          ? 'Auto-sync de Apple Health desactivado.'
          : 'Apple Health auto-sync disabled.';
    }
    return S.of(context).healthConnectAutoSyncDisabledMessage;
  }

  String _driveBackupSubtitle(BuildContext context) {
    if (Platform.isAndroid) {
      return _isEs(context)
          ? 'Copia cifrada manual o diaria en tu Drive'
          : 'Manual or daily encrypted backup to your Drive';
    }
    return _isEs(context)
        ? 'Copia cifrada manual en tu Drive'
        : 'Manual encrypted backup to your Drive';
  }

  Future<void> _refreshPlanStatus() async {
    final trialState = await locator<MonetizationService>().getAiTrialState();
    if (!mounted) {
      return;
    }
    setState(() {
      _isPremium = trialState.isPremium;
      _aiTrialState = trialState;
    });
  }

  Widget _buildPlanSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEs = _isEs(context);
    final trialState = _aiTrialState;
    final remaining = trialState?.remaining ?? 0;
    final used = trialState?.used ?? 0;
    final limit = trialState?.limit ?? MonetizationService.freeAiTrialLimit;
    final progress = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final aiMealsSaved = trialState?.aiMealsSaved ?? 0;
    final minutesSaved = trialState?.estimatedMinutesSaved ?? 0;

    return _SettingsSection(
      title: isEs ? 'Mi plan' : 'My plan',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _isPremium
                        ? const Color(0xFFF2BF2E).withValues(alpha: 0.18)
                        : colorScheme.primaryContainer.withValues(alpha: 0.45),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isPremium
                        ? Icons.star_rounded
                        : Icons.auto_awesome_outlined,
                    color: _isPremium
                        ? const Color(0xFFB77900)
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPremium
                            ? (isEs
                                ? 'MacroTracker Premium'
                                : 'MacroTracker Premium')
                            : (isEs ? 'Plan gratuito' : 'Free plan'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isPremium
                            ? (isEs
                                ? 'IA por texto y foto desbloqueada.'
                                : 'Text and photo AI logging is unlocked.')
                            : (isEs
                                ? '$remaining de $limit usos gratuitos de IA disponibles.'
                                : '$remaining of $limit free AI uses available.'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!_isPremium) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEs
                    ? '$used usados - $remaining restantes'
                    : '$used used - $remaining remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (aiMealsSaved > 0) ...[
                const SizedBox(height: 10),
                _PlanMetricRow(
                  icon: Icons.timer_outlined,
                  label: isEs
                      ? '$aiMealsSaved comidas IA guardadas - unos $minutesSaved min ahorrados'
                      : '$aiMealsSaved AI meals saved - about $minutesSaved min saved',
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isPlanActionLoading
                    ? null
                    : () => _showSettingsPaywall(context),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(isEs
                    ? 'Activar MacroTracker Premium'
                    : 'Activate MacroTracker Premium'),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.55),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEs
                            ? 'Tu suscripción está activa en este dispositivo.'
                            : 'Your subscription is active on this device.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            TextButton.icon(
              onPressed: _isPlanActionLoading
                  ? null
                  : () => _restorePurchases(context),
              icon: const Icon(Icons.restore_outlined),
              label: Text(isEs ? 'Restaurar compras' : 'Restore purchases'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettingsPaywall(BuildContext context) async {
    setState(() => _isPlanActionLoading = true);
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaywallSheet(
        placement: PaywallPlacement.settings,
        trialState: _aiTrialState,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _isPlanActionLoading = false);
    if (purchased == true) {
      await _refreshPlanStatus();
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    setState(() => _isPlanActionLoading = true);
    final restored = await locator<SubscriptionService>().restorePurchases();
    await locator<ConversionAnalyticsService>()
        .logPurchaseRestored(restored: restored);
    if (!mounted) {
      return;
    }
    setState(() => _isPlanActionLoading = false);
    await _refreshPlanStatus();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(restored
            ? (_isEs(context) ? 'Compras restauradas.' : 'Purchases restored.')
            : (_isEs(context)
                ? 'No se encontraron compras activas.'
                : 'No active purchases found.')),
      ),
    );
  }
}

class _PlanMetricRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlanMetricRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer.withValues(alpha: 0.28),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
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
