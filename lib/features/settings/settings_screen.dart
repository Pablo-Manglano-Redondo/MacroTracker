import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/presentation/widgets/app_banner_version.dart';

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
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/referral_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  String? _referralCode;
  bool _hasRedeemedCode = false;
  bool _isRedeeming = false;
  CloudAccountStatus? _cloudAccountStatus;
  StreamSubscription<AuthState>? _authSubscription;
  final _redeemController = TextEditingController();

  @override
  void initState() {
    _settingsBloc = locator<SettingsBloc>();
    _profileBloc = locator<ProfileBloc>();
    _homeBloc = locator<HomeBloc>();
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    _authSubscription =
        locator<SupabaseClient>().auth.onAuthStateChange.listen((_) {
      _loadCloudAccountStatus();
    });
    if (_supportsHealthIntegration) {
      _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
    }
    _refreshPlanStatus();
    _loadReferralInfo();
    _loadCloudAccountStatus();
    super.initState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _redeemController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralInfo() async {
    final referralService = locator<ReferralService>();
    final code = await referralService.getOrCreateReferralCode();
    final hasRedeemed = await referralService.hasRedeemedAnyCode();
    if (!mounted) return;
    setState(() {
      _referralCode = code;
      _hasRedeemedCode = hasRedeemed;
    });
  }

  Future<void> _loadCloudAccountStatus() async {
    try {
      final status = await locator<CloudAccountService>().getStatus();
      if (!mounted) return;
      setState(() => _cloudAccountStatus = status);
    } catch (_) {
      if (!mounted) return;
      setState(() => _cloudAccountStatus = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsLabel),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        bloc: _settingsBloc,
        listener: (context, state) {
          if (state is SettingsAccountDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEs(context)
                      ? 'Cuenta y datos eliminados con éxito.'
                      : 'Account and data successfully deleted.',
                ),
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              NavigationOptions.onboardingRoute,
              (route) => false,
            );
          }
        },
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
                _buildReferralSection(context),
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
                        subtitle: Text(
                          _isEs(context)
                              ? (state.macroGoalMode == MacroGoalModeEntity.percentage
                                  ? 'Distribución por porcentaje (%)'
                                  : 'Distribución por gramos por kilo (g/kg)')
                              : (state.macroGoalMode == MacroGoalModeEntity.percentage
                                  ? 'Percentage distribution (%)'
                                  : 'Grams per kg distribution (g/kg)'),
                        ),
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
                _buildAccountSecuritySection(context, state),
                const SizedBox(height: 18),
                _buildProfessionalNutritionistSection(context),
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
                _buildPrivacyAndDataSection(context, state),
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
        'body':
            'Por favor, describe el bug aqui / Please describe the bug here:\n\n\n\n---\nInformacion del sistema / System info:\nPlatform: ${Platform.isAndroid ? 'Android' : 'iOS'}\n',
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
        'body':
            'Describe la funcionalidad que te gustaria ver / Describe the feature you would like to see:\n\n\n',
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
        return 'Tus datos de ${_healthIntegrationName(context)} ya están al día.';
      }
      return 'Your ${_healthIntegrationName(context)} data is already up to date.';
    }
    if (report.workoutsImported > 0 || report.workoutsUpdated > 0) {
      final imported = report.workoutsImported;
      final updated = report.workoutsUpdated;
      if (_isEs(context)) {
        return '${_healthIntegrationName(context)}: $imported actividades nuevas y $updated actualizadas.';
      }
      return '${_healthIntegrationName(context)}: $imported new workouts and $updated updated.';
    }
    return _isEs(context)
        ? 'Datos de ${_healthIntegrationName(context)} sincronizados con éxito.'
        : '${_healthIntegrationName(context)} data successfully synced.';
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
      return _isEs(context) ? 'Drive diario' : 'Daily Drive';
    }
    return _isEs(context) ? 'Drive manual' : 'Manual Drive';
  }

  Widget _buildAccountSecuritySection(
    BuildContext context,
    SettingsLoadedState state,
  ) {
    final isEs = _isEs(context);
    final status = _cloudAccountStatus;
    final isProtected = status?.isProtected == true;

    return _SettingsSection(
      title: isEs ? 'Cuenta y copias' : 'Account and backups',
      child: Column(
        children: [
          _DataProtectionPanel(
            isEs: isEs,
            isProtected: isProtected,
            accountEmail: status?.email,
            driveSubtitle: _driveBackupSubtitle(context),
            onProtectAccount: isProtected
                ? _loadCloudAccountStatus
                : () => _protectCloudAccount(context),
            onConfigureBackup: () => _showDriveBackupDialog(context),
            onExportZip: () => _showExportImportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalNutritionistSection(BuildContext context) {
    final isEs = _isEs(context);
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: isEs ? 'Nutricionista profesional' : 'Professional nutritionist',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _ProtectionActionTile(
        icon: Icons.medical_information_outlined,
        title: isEs ? 'Conexión con nutricionista' : 'Nutritionist connection',
        body: isEs
            ? 'Vincula tu cuenta con un profesional por invitación y consentimiento.'
            : 'Connect your account with a professional by invite and consent.',
        statusLabel: isEs ? 'Profesional' : 'Professional',
        accentColor: colorScheme.primary,
        centerIcon: true,
        onTap: () => Navigator.of(context).pushNamed(
          NavigationOptions.professionalPlanRoute,
        ),
        ),
      ),
    );
  }

  Widget _buildPrivacyAndDataSection(
    BuildContext context,
    SettingsLoadedState state,
  ) {
    final isEs = _isEs(context);

    return _SettingsSection(
      title: isEs ? 'Privacidad y datos' : 'Privacy and data',
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: Text(S.of(context).sendAnonymousUserData),
            subtitle: Text(
              isEs
                  ? 'Puedes activarlo o desactivarlo en cualquier momento.'
                  : 'You can turn this on or off at any time.',
            ),
            value: state.sendAnonymousData,
            onChanged: (value) async {
              await _settingsBloc.setHasAcceptedAnonymousData(value);
              await locator<ConversionAnalyticsService>().setEnabled(value);
              _settingsBloc.add(LoadSettingsEvent());
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Material(
              color: Colors.red.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
                title: Text(
                  isEs ? 'Eliminar cuenta y datos' : 'Delete account and data',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  isEs
                      ? 'Borra permanentemente el perfil, los registros locales y los datos cloud vinculados.'
                      : 'Permanently deletes your profile, local logs, and linked cloud data.',
                ),
                onTap: () => _confirmDeleteAccount(context),
              ),
            ),
          ),
        ],
      ),
    );
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _isPremium
                        ? const Color(0xFFF2BF2E).withValues(alpha: 0.12)
                        : colorScheme.primaryContainer.withValues(alpha: 0.45),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isPremium ? Icons.star_rounded : Icons.auto_awesome_outlined,
                    color: _isPremium ? const Color(0xFFD97706) : colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPremium ? 'MacroTracker Premium' : (isEs ? 'Plan gratuito' : 'Free plan'),
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
                isEs ? '$used usados - $remaining restantes' : '$used used - $remaining remaining',
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
                      ? '$aiMealsSaved comidas IA guardadas - $minutesSaved min ahorrados'
                      : '$aiMealsSaved AI meals saved - $minutesSaved min saved',
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isPlanActionLoading
                    ? null
                    : () => _showSettingsPaywall(context),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  isEs ? 'Activar MacroTracker Premium' : 'Activate MacroTracker Premium',
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
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
                    if (trialState?.isFoundingMember == true) ...[
                      const SizedBox(height: 10),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2BF2E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD97706).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Color(0xFFD97706),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isEs ? 'Miembro Fundador' : 'Founding Member',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFFD97706),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (!_isPremium) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _isPlanActionLoading ? null : () => _restorePurchases(context),
                icon: const Icon(Icons.restore_outlined, size: 18),
                label: Text(
                  isEs ? 'Restaurar compras' : 'Restore purchases',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferralSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEs = _isEs(context);

    return _SettingsSection(
      title: isEs ? 'Invitar amigos' : 'Invite friends',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEs
                  ? 'Comparte tu código de invitación con un amigo y ambos obtendréis usos extra de IA gratis cuando lo canjee.'
                  : 'Share your invitation code with a friend and you both get extra free AI uses when they redeem it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Referral code box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEs
                              ? 'TU CÓDIGO DE INVITACIÓN'
                              : 'YOUR REFERRAL CODE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _referralCode ?? '------',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_referralCode != null) ...[
                    IconButton(
                      onPressed: () {
                        final referralService = locator<ReferralService>();
                        final msg = referralService
                            .buildShareMessage(_referralCode!, isEs: isEs);
                        Clipboard.setData(ClipboardData(text: msg));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEs
                                  ? 'Enlace y código de invitación copiados al portapapeles.'
                                  : 'Invitation link and code copied to clipboard.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: isEs ? 'Copiar' : 'Copy',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 12),

            // Redeem Section
            if (_hasRedeemedCode) ...[
              Row(
                children: [
                  Icon(Icons.check_circle_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEs
                          ? '¡Ya has canjeado un código de invitación!'
                          : 'You have already redeemed an invitation code!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                isEs
                    ? '¿Te ha invitado un amigo?'
                    : 'Were you invited by a friend?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        controller: _redeemController,
                        decoration: InputDecoration(
                          hintText:
                              isEs ? 'Introduce su código' : 'Enter their code',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isRedeeming ? null : _redeemFriendCode,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isRedeeming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEs ? 'Canjear' : 'Redeem'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _protectCloudAccount(BuildContext context) async {
    try {
      final opened = await locator<CloudAccountService>().protectWithGoogle();
      if (!mounted) return;
      await _loadCloudAccountStatus();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(opened
              ? (_isEs(context)
                  ? 'Completa Google y vuelve a MacroTracker.'
                  : 'Complete Google and return to MacroTracker.')
              : (_isEs(context)
                  ? 'No se pudo abrir Google.'
                  : 'Could not open Google.')),
        ),
      );
    } catch (e, s) {
      debugPrint('Error linking Google account: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEs(context)
              ? 'No se pudo iniciar la vinculacion con Google.'
              : 'Could not start Google linking.'),
        ),
      );
    }
  }

  Future<void> _redeemFriendCode() async {
    final code = _redeemController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isRedeeming = true);
    final referralService = locator<ReferralService>();
    final result = await referralService.redeemCode(code);

    if (!mounted) return;
    setState(() => _isRedeeming = false);

    final isEs = _isEs(context);
    String message;
    switch (result) {
      case ReferralRedemptionResult.success:
        message = isEs
            ? '¡Código canjeado con éxito! Has ganado usos de IA gratis.'
            : 'Code redeemed successfully! You earned free AI uses.';
        _redeemController.clear();
        _loadReferralInfo();
        _refreshPlanStatus();
        break;
      case ReferralRedemptionResult.codeNotFound:
        message = isEs
            ? 'El código de invitación no existe.'
            : 'Invitation code not found.';
        break;
      case ReferralRedemptionResult.selfReferral:
        message = isEs
            ? 'No puedes canjear tu propio código.'
            : 'You cannot redeem your own code.';
        break;
      case ReferralRedemptionResult.alreadyRedeemed:
        message = isEs
            ? 'Ya has canjeado un código de invitación.'
            : 'You have already redeemed an invitation code.';
        break;
      case ReferralRedemptionResult.notAuthenticated:
        message = isEs
            ? 'Inicia sesión para canjear códigos.'
            : 'Log in to redeem codes.';
        break;
      case ReferralRedemptionResult.unknownError:
        message = isEs
            ? 'Error al canjear el código. Inténtalo de nuevo.'
            : 'Error redeeming code. Please try again.';
        break;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  void _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isEs = _isEs(context);
        final targetText = isEs ? 'ELIMINAR' : 'DELETE';
        String typedText = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final isValid = typedText.trim().toUpperCase() == targetText;

            return AlertDialog(
              title: Text(
                isEs ? '¿Eliminar cuenta y datos?' : 'Delete account and data?',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEs
                        ? 'Esta acción es irreversible y borrará para siempre todos tus registros de comidas, actividades, recetas, pesos y tu perfil de usuario.'
                        : 'This action is irreversible and will permanently delete all your logged meals, activities, recipes, weight history, and user profile.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEs
                        ? 'Para confirmar, escribe "$targetText" en la casilla de abajo:'
                        : 'To confirm, type "$targetText" in the box below:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        typedText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: targetText,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(isEs ? 'Cancelar' : 'Cancel'),
                ),
                FilledButton(
                  onPressed:
                      isValid ? () => Navigator.of(context).pop(true) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isValid ? Colors.red : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEs ? 'Eliminar todo' : 'Delete all'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      _settingsBloc.add(DeleteAccountEvent());
    }
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

class _DataProtectionPanel extends StatelessWidget {
  final bool isEs;
  final bool isProtected;
  final String? accountEmail;
  final String driveSubtitle;
  final VoidCallback onProtectAccount;
  final VoidCallback onConfigureBackup;
  final VoidCallback onExportZip;

  const _DataProtectionPanel({
    required this.isEs,
    required this.isProtected,
    required this.accountEmail,
    required this.driveSubtitle,
    required this.onProtectAccount,
    required this.onConfigureBackup,
    required this.onExportZip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountLabel = accountEmail?.isNotEmpty == true
        ? accountEmail!
        : (isEs
            ? 'Identidad para recuperacion y conexiones profesionales'
            : 'Identity for recovery and coach connections');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isProtected
                      ? Icons.verified_user_outlined
                      : Icons.shield_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEs ? 'Proteccion de datos' : 'Data protection',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(
                          label: isProtected
                              ? (isEs ? 'Cuenta protegida' : 'Protected')
                              : (isEs ? 'Sin cuenta' : 'No account'),
                          color: isProtected
                              ? colorScheme.primary
                              : colorScheme.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEs
                          ? 'Gestiona desde aqui la recuperacion de cuenta, las copias cifradas y la exportacion manual.'
                          : 'Manage account recovery, encrypted backups, and manual export from one place.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProtectionActionTile(
            icon: isProtected
                ? Icons.verified_user_outlined
                : Icons.g_mobiledata_outlined,
            title: isEs ? 'Cuenta cloud' : 'Cloud account',
            body: isProtected
                ? accountLabel
                : (isEs
                    ? 'Recupera la cuenta al cambiar de movil.'
                    : 'Recover your account when changing phones.'),
            statusLabel: isProtected
                ? (isEs ? 'Activa' : 'Active')
                : (isEs ? 'Opcional' : 'Optional'),
            accentColor:
                isProtected ? colorScheme.primary : colorScheme.tertiary,
            onTap: onProtectAccount,
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _ProtectionActionTile(
            icon: Icons.cloud_upload_outlined,
            title: isEs ? 'Backup cifrado' : 'Encrypted backup',
            body: isEs
                ? 'Guarda una copia en tu propio Google Drive.'
                : 'Store a copy in your own Google Drive.',
            statusLabel: driveSubtitle,
            accentColor: const Color(0xFF0EA5E9),
            onTap: onConfigureBackup,
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _ProtectionActionTile(
            icon: Icons.folder_zip_outlined,
            title: isEs ? 'Exportar ZIP' : 'Export ZIP',
            body: isEs
                ? 'Copia local/manual para guardar o mover datos.'
                : 'Manual local copy to store or move data.',
            statusLabel: isEs ? 'Manual' : 'Manual',
            accentColor: const Color(0xFFF59E0B),
            onTap: onExportZip,
          ),
        ],
      ),
    );
  }
}

class _ProtectionActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String statusLabel;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool centerIcon;

  const _ProtectionActionTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.statusLabel,
    required this.accentColor,
    this.onTap,
    this.centerIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            crossAxisAlignment:
                centerIcon ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accentColor.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(label: statusLabel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color? color;

  const _StatusPill({
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color == null
              ? colorScheme.surfaceContainerHighest
              : effectiveColor.withValues(alpha: 0.12),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: effectiveColor,
            fontWeight: FontWeight.w800,
          ),
        ),
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
