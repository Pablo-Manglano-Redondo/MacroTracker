import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/i18n/generated_supported_locales.dart';
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
import 'package:macrotracker/features/settings/presentation/widgets/feedback_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/cloud_account_deletion_service.dart';
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
      _refreshPlanStatus();
    });
    if (_supportsHealthIntegration) {
      _healthConnectStatusFuture = _settingsBloc.getHealthConnectStatus();
    }
    final cached = locator<MonetizationService>().cachedTrialState;
    if (cached != null) {
      _isPremium = cached.isPremium;
      _aiTrialState = cached;
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
                content: Text(S.of(context).settingsAccountDeletedMessage),
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              NavigationOptions.onboardingRoute,
              (route) => false,
            );
          } else if (state is SettingsAccountDeletionFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_localizedDeletionError(context, state.message)),
                duration: const Duration(seconds: 6),
              ),
            );
            _settingsBloc.add(LoadSettingsEvent());
          }
        },
        builder: (context, state) {
          if (state is SettingsInitial) {
            _settingsBloc.add(LoadSettingsEvent());
          } else if (state is SettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsAccountDeletionFailedState) {
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
                  title: S.of(context).settingsTrackingSection,
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
                          state.macroGoalMode ==
                                  MacroGoalModeEntity.percentage
                              ? S.of(context).settingsCalculationPercentageMode
                              : S.of(context).settingsCalculationGramsKgMode,
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
                  title: S.of(context).settingsAppearanceSection,
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
                  title: S.of(context).settingsSupportSection,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bug_report_outlined),
                        title: Text(S.of(context).settingsReportBugTitle),
                        subtitle: Text(S.of(context).settingsReportBugSubtitle),
                        onTap: () => _reportBug(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(S.of(context).settingsSuggestFeatureTitle),
                        subtitle:
                            Text(S.of(context).settingsSuggestFeatureSubtitle),
                        onTap: () => _requestFeature(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildPrivacyAndDataSection(context, state),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: S.of(context).settingsAppSection,
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
    final supportedLocales = getSupportedLocalesMetadata();
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
                      ...supportedLocales.map(
                        (supportedLocale) => RadioListTile<String>(
                          title: Text(_localeDisplayName(context, supportedLocale)),
                          value: supportedLocale.code,
                        ),
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
                          .updateLocale(buildSupportedLocale(localeToSave));
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).dialogOKLabel)),
            ],
          );
        });
  }

  String _localeDisplayName(
    BuildContext context,
    AppSupportedLocale supportedLocale,
  ) {
    switch (supportedLocale.code) {
      case 'en':
        return S.of(context).settingsLanguageEnglish;
      case 'es':
        return S.of(context).settingsLanguageSpanish;
      default:
        return supportedLocale.nativeName;
    }
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
                      label: S.of(context).settingsAboutProjectLabel,
                      value: S.of(context).settingsAboutProjectValue,
                    ),
                    _AboutInfoRow(
                      label: S.of(context).settingsAboutModelLabel,
                      value: S.of(context).settingsAboutModelValue,
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
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(initialType: 'bug'),
    );
  }

  void _requestFeature(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(initialType: 'feature'),
    );
  }

  String _buildHealthConnectStatusText(HealthConnectSyncStatusEntity status) {
    final copy = S.of(context);
    final integration = _healthIntegrationName(context);

    if (!status.isAvailable) {
      return copy.healthStatusUnavailableName(integration);
    }
    if (!status.isAutoSyncEnabled) {
      return copy.healthConnectStatusAutoSyncDisabled;
    }
    if (!status.hasActivityRecognitionPermission) {
      return copy.healthConnectStatusActivityPermissionRequired;
    }
    if (!status.hasHealthPermissions) {
      return copy.healthStatusPermissionsReview(integration);
    }
    if (!status.hasStepsPermission) {
      return copy.healthStatusStepsPermissionMissing;
    }
    if (!status.hasWorkoutSupplementPermission) {
      return copy.healthStatusWorkoutPermissionMissing;
    }
    return copy.healthConnectStatusReady;
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
    final copy = S.of(context);
    final integration = _healthIntegrationName(context);

    if (!report.didUpdate) {
      return copy.healthSyncAlreadyCurrent(integration);
    }
    if (report.workoutsImported > 0 || report.workoutsUpdated > 0) {
      return copy.healthSyncWorkoutSummary(
        integration,
        report.workoutsImported,
        report.workoutsUpdated,
      );
    }
    return copy.healthSyncSuccessName(integration);
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
      S.of(context).mealReminderTitle;

  String _mealReminderOffLabel(BuildContext context) =>
      S.of(context).mealReminderDisabledStatus;

  String _mealReminderEnabledLabel(BuildContext context) =>
      S.of(context).mealReminderEnableLabel;

  String _mealReminderSubtitle(BuildContext context) =>
      S.of(context).mealReminderSubtitle;

  String _morningReminderLabel(BuildContext context) =>
      S.of(context).mealReminderMorning;

  String _afterLunchReminderLabel(BuildContext context) =>
      S.of(context).mealReminderAfterLunch;

  String _afternoonReminderLabel(BuildContext context) =>
      S.of(context).mealReminderAfternoon;

  String _eveningReminderLabel(BuildContext context) =>
      S.of(context).mealReminderDinner;

  String _mealReminderSavedMessage(BuildContext context) =>
      S.of(context).mealReminderSavedMessage;

  String _mealReminderDisabledMessage(BuildContext context) =>
      S.of(context).mealReminderDisabledMessage;

  String _mealReminderPermissionDeniedMessage(BuildContext context) =>
      S.of(context).mealReminderPermissionDeniedMessage;
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

  bool get _supportsHealthIntegration => Platform.isAndroid || Platform.isIOS;

  String _healthIntegrationName(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthLabel;
    }
    return S.of(context).habitSourceHealthConnect;
  }

  String _healthAutoSyncTitle(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthAutoSyncTitle;
    }
    return S.of(context).healthConnectAutoSyncTitle;
  }

  String _healthAutoSyncSubtitle(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthAutoSyncSubtitle;
    }
    return S.of(context).healthConnectAutoSyncSubtitle;
  }

  String _healthSyncNowTitle(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthSyncNowTitle;
    }
    return S.of(context).healthConnectSyncNowTitle;
  }

  String _healthAutoSyncEnabledMessage(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthAutoSyncEnabledMessage;
    }
    return S.of(context).healthConnectAutoSyncEnabledMessage;
  }

  String _healthAutoSyncDisabledMessage(BuildContext context) {
    if (Platform.isIOS) {
      return S.of(context).appleHealthAutoSyncDisabledMessage;
    }
    return S.of(context).healthConnectAutoSyncDisabledMessage;
  }

  String _driveBackupSubtitle(BuildContext context) {
    if (Platform.isAndroid) {
      return S.of(context).settingsDailyDriveBackup;
    }
    return S.of(context).settingsManualDriveBackup;
  }
  Widget _buildAccountSecuritySection(
    BuildContext context,
    SettingsLoadedState state,
  ) {
    final status = _cloudAccountStatus;
    final isProtected = status?.isProtected == true;

    return _SettingsSection(
      title: S.of(context).settingsAccountBackupsSection,
      child: Column(
        children: [
          _DataProtectionPanel(
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
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: S.of(context).settingsProfessionalNutritionistSection,
      child: _ProtectionActionTile(
        icon: Icons.medical_information_outlined,
        title: S.of(context).settingsNutritionistConnectionTitle,
        body: S.of(context).settingsNutritionistConnectionBody,
        statusLabel: S.of(context).settingsProfessionalStatus,
        accentColor: colorScheme.primary,
        centerIcon: true,
        onTap: () => Navigator.of(context).pushNamed(
          NavigationOptions.professionalPlanRoute,
        ),
      ),
    );
  }

  Widget _buildPrivacyAndDataSection(
    BuildContext context,
    SettingsLoadedState state,
  ) {
    return _SettingsSection(
      title: S.of(context).settingsPrivacyDataSection,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.bug_report_outlined),
            title: Text(S.of(context).sendAnonymousUserData),
            subtitle: Text(S.of(context).settingsAnonymousDataSubtitle),
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
                  S.of(context).settingsDeleteCloudAccountTitle,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(S.of(context).settingsDeleteCloudAccountSubtitle),
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
    final copy = S.of(context);
    final trialState = _aiTrialState;
    final remaining = trialState?.remaining ?? 0;
    final used = trialState?.used ?? 0;
    final limit = trialState?.limit ?? MonetizationService.freeAiTrialLimit;
    final fullLimit = trialState?.fullLimit ?? limit;
    final progress = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final aiMealsSaved = trialState?.aiMealsSaved ?? 0;
    final minutesSaved = trialState?.estimatedMinutesSaved ?? 0;
    final needsProtectedAccount = trialState?.requiresProtectedAccount == true;
    final lockedFreeUses = trialState?.lockedFreeUses ?? 0;

    final planBody = _isPremium
        ? copy.settingsPremiumUnlockedMessage
        : needsProtectedAccount
            ? copy.settingsGuestAllowanceUsedBody(lockedFreeUses)
            : (trialState != null &&
                    !trialState.isProtectedAccount &&
                    fullLimit > limit)
                ? copy.settingsTrialProtectBody(
                    remaining,
                    limit,
                    fullLimit - limit,
                  )
                : copy.settingsTrialRemainingBody(remaining, limit);

    return _SettingsSection(
      title: copy.settingsPlanTitle,
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
                    _isPremium
                        ? Icons.star_rounded
                        : Icons.auto_awesome_outlined,
                    color: _isPremium
                        ? const Color(0xFFD97706)
                        : colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPremium ? copy.paywallPremiumTitle : copy.settingsFreePlan,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        planBody,
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
                needsProtectedAccount
                    ? copy.settingsPlanLockedProgress(used, lockedFreeUses)
                    : copy.settingsPlanProgress(used, remaining),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (aiMealsSaved > 0) ...[
                const SizedBox(height: 10),
                _PlanMetricRow(
                  icon: Icons.timer_outlined,
                  label: copy.settingsPlanMetricAiMeals(
                    aiMealsSaved,
                    minutesSaved,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (trialState != null && !trialState.isProtectedAccount) ...[
                FilledButton.tonalIcon(
                  onPressed: _isPlanActionLoading
                      ? null
                      : () => _protectCloudAccount(context),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: Text(copy.paywallProtectWithGoogle),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isPlanActionLoading
                      ? null
                      : () => _showSettingsPaywall(context),
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: Text(copy.settingsViewPremium),
                ),
              ] else
                FilledButton.icon(
                  onPressed: _isPlanActionLoading
                      ? null
                      : () => _showSettingsPaywall(context),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(copy.settingsActivatePremium),
                ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
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
                            copy.settingsSubscriptionActive,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2BF2E)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD97706)
                                    .withValues(alpha: 0.4),
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
                                  copy.settingsFoundingMember,
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
                onPressed: _isPlanActionLoading
                    ? null
                    : () => _restorePurchases(context),
                icon: const Icon(Icons.restore_outlined, size: 18),
                label: Text(copy.paywallRestorePurchases),
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
    final copy = S.of(context);

    return _SettingsSection(
      title: copy.settingsInviteFriendsTitle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              copy.settingsInviteFriendsBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
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
                          copy.settingsReferralCodeLabel,
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
                        final url =
                            'https://macrotracker.app/referral?code=${_referralCode!}';
                        final msg = copy.settingsReferralShareMessage(
                          _referralCode!,
                          url,
                        );
                        Clipboard.setData(ClipboardData(text: msg));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(copy.settingsReferralCopiedMessage),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: copy.settingsCopyReferralTooltip,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            if (_hasRedeemedCode) ...[
              Row(
                children: [
                  Icon(Icons.check_circle_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      copy.settingsReferralAlreadyRedeemedMessage,
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
                copy.settingsInvitedByFriendQuestion,
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
                          hintText: copy.settingsEnterReferralCodeHint,
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
                        : Text(copy.settingsRedeemReferralButton),
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
      await _refreshPlanStatus();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? S.of(context).paywallGoogleComplete
                : S.of(context).paywallGoogleOpenFailed,
          ),
        ),
      );
    } catch (e, s) {
      debugPrint('Error linking Google account: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).paywallGoogleLinkStartFailed),
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

    final copy = S.of(context);
    String message;
    switch (result) {
      case ReferralRedemptionResult.success:
        message = copy.settingsReferralRedeemSuccess;
        _redeemController.clear();
        _loadReferralInfo();
        _refreshPlanStatus();
        break;
      case ReferralRedemptionResult.codeNotFound:
        message = copy.settingsReferralCodeNotFound;
        break;
      case ReferralRedemptionResult.selfReferral:
        message = copy.settingsReferralSelfReferral;
        break;
      case ReferralRedemptionResult.alreadyRedeemed:
        message = copy.settingsReferralAlreadyRedeemedMessage;
        break;
      case ReferralRedemptionResult.notAuthenticated:
        message = copy.settingsReferralLoginRequired;
        break;
      case ReferralRedemptionResult.unknownError:
        message = copy.settingsReferralRedeemError;
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
        content: Text(
          restored
              ? S.of(context).settingsPurchasesRestored
              : S.of(context).paywallNoActivePurchases,
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final copy = S.of(context);
        final targetText = copy.settingsDeleteConfirmationTarget;
        String typedText = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final isValid = typedText.trim().toUpperCase() == targetText;

            return AlertDialog(
              title: Text(
                copy.settingsDeleteConfirmTitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.settingsDeleteConfirmBody),
                  const SizedBox(height: 12),
                  Text(copy.settingsDeleteConfirmFailureGuard),
                  const SizedBox(height: 16),
                  Text(
                    copy.settingsDeleteConfirmTypePrompt(targetText),
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
                  child: Text(copy.dialogCancelLabel),
                ),
                FilledButton(
                  onPressed:
                      isValid ? () => Navigator.of(context).pop(true) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isValid ? Colors.red : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(copy.deleteAllLabel),
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
String _localizedDeletionError(BuildContext context, String message) {
  final copy = S.of(context);
  if (message.contains(CloudAccountDeletionService.sessionInvalidErrorCode)) {
    return copy.settingsDeleteErrorSessionInvalid;
  }
  if (message.contains(CloudAccountDeletionService.cloudUnreachableErrorCode)) {
    return copy.settingsDeleteErrorCloudUnreachable;
  }
  if (message.contains(CloudAccountDeletionService.noActiveSessionErrorCode) ||
      message.contains(CloudAccountDeletionService.localDataKeptErrorCode)) {
    return copy.settingsDeleteErrorLocalKept;
  }
  return copy.settingsDeleteErrorGeneric;
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
  final bool isProtected;
  final String? accountEmail;
  final String driveSubtitle;
  final VoidCallback onProtectAccount;
  final VoidCallback onConfigureBackup;
  final VoidCallback onExportZip;

  const _DataProtectionPanel({
    required this.isProtected,
    required this.accountEmail,
    required this.driveSubtitle,
    required this.onProtectAccount,
    required this.onConfigureBackup,
    required this.onExportZip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final copy = S.of(context);
    final accountLabel = accountEmail?.isNotEmpty == true
        ? accountEmail!
        : copy.settingsCloudIdentityFallback;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _ProtectionActionTile(
        icon:
            isProtected ? Icons.verified_user_outlined : Icons.shield_outlined,
        title: copy.settingsAccountBackupsSection,
        body: isProtected
            ? '$accountLabel - $driveSubtitle'
            : copy.settingsProtectAccountBackupsBody,
        statusLabel: isProtected
            ? copy.settingsAccountProtectedStatus
            : copy.settingsNoAccountStatus,
        accentColor: isProtected ? colorScheme.primary : colorScheme.tertiary,
        centerIcon: true,
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _AccountBackupsSheet(
            isProtected: isProtected,
            accountLabel: accountLabel,
            driveSubtitle: driveSubtitle,
            onProtectAccount: () {
              Navigator.of(sheetContext).pop();
              onProtectAccount();
            },
            onConfigureBackup: () {
              Navigator.of(sheetContext).pop();
              onConfigureBackup();
            },
            onExportZip: () {
              Navigator.of(sheetContext).pop();
              onExportZip();
            },
          ),
        ),
      ),
    );
  }
}

class _AccountBackupsSheet extends StatelessWidget {
  final bool isProtected;
  final String accountLabel;
  final String driveSubtitle;
  final VoidCallback onProtectAccount;
  final VoidCallback onConfigureBackup;
  final VoidCallback onExportZip;

  const _AccountBackupsSheet({
    required this.isProtected,
    required this.accountLabel,
    required this.driveSubtitle,
    required this.onProtectAccount,
    required this.onConfigureBackup,
    required this.onExportZip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final copy = S.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    copy.settingsAccountBackupsSection,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _ProtectionActionTile(
            icon: isProtected
                ? Icons.verified_user_outlined
                : Icons.g_mobiledata_outlined,
            title: copy.settingsGoogleAccountTitle,
            body: isProtected ? accountLabel : copy.settingsGoogleAccountBody,
            statusLabel: isProtected
                ? copy.settingsActiveStatus
                : copy.settingsNotLinkedStatus,
            accentColor:
                isProtected ? colorScheme.primary : colorScheme.tertiary,
            onTap: onProtectAccount,
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _ProtectionActionTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Google Drive',
            body: copy.settingsGoogleDriveBackupBody,
            statusLabel: driveSubtitle,
            accentColor: const Color(0xFF0EA5E9),
            onTap: onConfigureBackup,
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          _ProtectionActionTile(
            icon: Icons.folder_zip_outlined,
            title: copy.settingsExportZipTitle,
            body: copy.settingsExportZipBody,
            statusLabel: copy.settingsManualStatus,
            accentColor: const Color(0xFFF59E0B),
            onTap: onExportZip,
          ),
          const SizedBox(height: 16),
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusPill(label: statusLabel),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: colorScheme.surfaceContainerHighest,
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
