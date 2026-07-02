import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/services/backup_nudge_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/push_notification_service.dart';
import 'package:macrotracker/core/presentation/widgets/meal_entry_action_sheet.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/diary_screen.dart';
import 'package:macrotracker/core/presentation/widgets/home_appbar.dart';
import 'package:macrotracker/features/home/home_screen.dart';
import 'package:macrotracker/core/presentation/widgets/main_appbar.dart';
import 'package:macrotracker/features/profile/profile_screen.dart';
import 'package:macrotracker/features/professional_plan/presentation/professional_plan_screen.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_unseen_section_count_usecase.dart';
import 'package:macrotracker/features/settings/presentation/widgets/drive_backup_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/feature_tour/presentation/bloc/feature_tour_bloc.dart';
import 'package:macrotracker/features/feature_tour/presentation/widgets/product_tour_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _activeProfessionalConnectionKey = 'activeProfessionalConnection';

  int _selectedPageIndex = 0;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinkSubscription;
  StreamSubscription<BoxEvent>? _professionalConnectionSubscription;
  StreamSubscription<Map<String, dynamic>>? _pushTapSubscription;
  bool _hasProfessionalTab = false;
  int _professionalBadgeCount = 0;
  late final FeatureTourBloc _featureTourBloc;
  bool _hasCheckedRestartTour = false;

  @override
  void initState() {
    super.initState();
    _featureTourBloc = locator<FeatureTourBloc>();
    _featureTourBloc.add(const LoadFeatureTourEvent());
    _appLinks = AppLinks();
    _hasProfessionalTab = _hasActiveProfessionalConnection();
    unawaited(_refreshProfessionalBadgeCount());
    _initInviteLinks();
    _pushTapSubscription =
        locator<PushNotificationService>().onNotificationTap.listen(
              _handleNotificationTap,
            );
    _professionalConnectionSubscription =
        locator<HiveDBProvider>().professionalPlanBox.watch().listen((_) {
      if (!mounted) {
        return;
      }
      _syncProfessionalTabVisibility();
      unawaited(_refreshProfessionalBadgeCount());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final nudgeService = locator<BackupNudgeService>();
      await nudgeService.recordAppOpen();

      // Record daily usage for review triggers
      await locator<AppReviewService>().recordDailyUsage();

      // Ensure onboarding bonus is granted for legacy users who updated the app
      await locator<MonetizationService>().grantOnboardingBonus();

      if (await nudgeService.shouldShowBackupNudge()) {
        await nudgeService.markNudgeShown();
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const DriveBackupDialog(),
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedRestartTour) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['restart_tour'] == true) {
        _hasCheckedRestartTour = true;
        setState(() {
          _selectedPageIndex = 0;
        });
        _featureTourBloc.add(const LoadFeatureTourEvent(force: true));
      }
    }
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    _professionalConnectionSubscription?.cancel();
    _pushTapSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initInviteLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
      _appLinkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
    } catch (_) {
      // Deep links are a convenience path. Manual invite-code entry remains available.
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (!mounted) return;

    if (uri.scheme == 'macrotracker') {
      if (uri.host == 'add_water') {
        try {
          await locator<UpdateDailyHabitLogUsecase>().adjustWater(
            day: DateTime.now(),
            deltaLiters: 0.25,
          );
          locator<HomeBloc>().add(const LoadItemsEvent());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).mainWaterAddedSnack),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (_) {
          // Silent error handling
        }
        return;
      } else if (uri.host == 'scan') {
        final hour = DateTime.now().hour;
        IntakeTypeEntity intakeType;
        if (hour < 11) {
          intakeType = IntakeTypeEntity.breakfast;
        } else if (hour < 16) {
          intakeType = IntakeTypeEntity.lunch;
        } else if (hour < 20) {
          intakeType = IntakeTypeEntity.snack;
        } else {
          intakeType = IntakeTypeEntity.dinner;
        }

        Navigator.of(context).pushNamed(
          NavigationOptions.scannerRoute,
          arguments: ScannerScreenArguments(DateTime.now(), intakeType),
        );
        return;
      }
    }

    final code = _extractInviteCode(uri);
    if (code == null || code.isEmpty) {
      return;
    }
    final result = await Navigator.of(context).pushNamed(
      NavigationOptions.professionalPlanRoute,
      arguments: ProfessionalPlanScreenArguments(
        inviteCode: code,
        preferEmbeddedTabAfterAccept: true,
      ),
    );
    _syncProfessionalTabVisibility();
    await _refreshProfessionalBadgeCount();
    if (result == true && mounted && _hasProfessionalTab) {
      setState(() {
        _selectedPageIndex = 1;
      });
    }
  }

  String? _extractInviteCode(Uri uri) {
    final queryCode = uri.queryParameters['code'];
    if (queryCode != null && queryCode.trim().isNotEmpty) {
      return queryCode.trim();
    }
    final segments = uri.pathSegments;
    if (uri.scheme == 'macrotracker' &&
        uri.host == 'invite' &&
        segments.isNotEmpty) {
      return segments.first;
    }
    final inviteIndex = segments.indexOf('invite');
    if (inviteIndex >= 0 && inviteIndex + 1 < segments.length) {
      return segments[inviteIndex + 1];
    }
    return null;
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (!mounted) {
      return;
    }
    final tab = _professionalTabForNotification(data);
    if (tab == null) {
      return;
    }
    Navigator.of(context).pushNamed(
      NavigationOptions.professionalPlanRoute,
      arguments: ProfessionalPlanScreenArguments(initialTab: tab),
    );
  }

  ProfessionalHubTab? _professionalTabForNotification(
    Map<String, dynamic> data,
  ) {
    final type = data['type']?.toString();
    return switch (type) {
      'checkin_requested' => ProfessionalHubTab.checkin,
      'new_message' => ProfessionalHubTab.messages,
      'recipe_proposal' => ProfessionalHubTab.recipes,
      'plan_updated' => ProfessionalHubTab.plan,
      _ => null,
    };
  }

  void _toggleFab() {
    HapticFeedback.selectionClick();
    MealEntryActionSheet.show(context, day: DateTime.now());
    if (!_featureTourBloc.state.isCompleted &&
        _featureTourBloc.state.currentSlideIndex == 1) {
      _featureTourBloc.add(NextSlideEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyPages = _buildBodyPages();
    final appbarPages = _buildAppbarPages(context);
    final destinations = _buildDestinations(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appbarPages[_selectedPageIndex],
          body: IndexedStack(
            index: _selectedPageIndex,
            children: bodyPages,
          ),
          floatingActionButton:
              _selectedPageIndex == 0 ? _buildSpeedDial(context) : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedPageIndex,
            onDestinationSelected: _setPage,
            destinations: destinations,
          ),
        ),
        ProductTourOverlay(
          featureTourBloc: _featureTourBloc,
          hasProfessionalTab: _hasProfessionalTab,
          activePageIndex: _selectedPageIndex,
          onTabChanged: _setPage,
        ),
      ],
    );
  }

  List<Widget> _buildBodyPages() {
    return [
      const HomeScreen(),
      if (_hasProfessionalTab) const ProfessionalPlanScreen(),
      const DiaryScreen(),
      const ProfileScreen(),
    ];
  }

  List<PreferredSizeWidget> _buildAppbarPages(BuildContext context) {
    return [
      const HomeAppbar(),
      if (_hasProfessionalTab)
        MainAppbar(
          title: S.of(context).professionalScreenTitle,
          iconData: Icons.medical_services_outlined,
        ),
      MainAppbar(title: S.of(context).diaryLabel, iconData: Icons.book),
      MainAppbar(
        title: S.of(context).profileLabel,
        iconData: Icons.account_circle,
      ),
    ];
  }

  List<NavigationDestination> _buildDestinations(BuildContext context) {
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: _selectedPageIndex == 0
            ? const Icon(Icons.home)
            : const Icon(Icons.home_outlined),
        label: S.of(context).homeLabel,
      ),
    ];
    if (_hasProfessionalTab) {
      destinations.add(
        NavigationDestination(
          icon: _professionalTabIcon(selected: _selectedPageIndex == 1),
          label: S.of(context).professionalScreenTitle,
        ),
      );
    }
    final diaryIndex = _hasProfessionalTab ? 2 : 1;
    final profileIndex = _hasProfessionalTab ? 3 : 2;
    destinations.addAll([
      NavigationDestination(
        icon: _selectedPageIndex == diaryIndex
            ? const Icon(Icons.book)
            : const Icon(Icons.book_outlined),
        label: S.of(context).diaryLabel,
      ),
      NavigationDestination(
        icon: _selectedPageIndex == profileIndex
            ? const Icon(Icons.account_circle)
            : const Icon(Icons.account_circle_outlined),
        label: S.of(context).profileLabel,
      ),
    ]);
    return destinations;
  }

  Widget _buildSpeedDial(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          key: ProductTourKeys.fabKey,
          onPressed: _toggleFab,
          tooltip: S.of(context).mealEntryTitle,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _setPage(int selectedIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPageIndex = selectedIndex;
    });
    if (!_featureTourBloc.state.isCompleted) {
      final currentStep = _featureTourBloc.state.currentSlideIndex;
      final diaryIndex = _hasProfessionalTab ? 2 : 1;
      final profileIndex = _hasProfessionalTab ? 3 : 2;
      if (currentStep == 6 && _hasProfessionalTab && selectedIndex == 1) {
        _featureTourBloc.add(NextSlideEvent());
      } else if (currentStep == 7 && selectedIndex == diaryIndex) {
        _featureTourBloc.add(NextSlideEvent());
      } else if (currentStep == 10 && selectedIndex == profileIndex) {
        _featureTourBloc.add(NextSlideEvent());
      }
    }
  }

  bool _hasActiveProfessionalConnection() {
    final value = locator<HiveDBProvider>()
        .professionalPlanBox
        .get(_activeProfessionalConnectionKey);
    return value is Map && value.isNotEmpty;
  }

  void _syncProfessionalTabVisibility() {
    final hasProfessionalConnection = _hasActiveProfessionalConnection();
    if (hasProfessionalConnection == _hasProfessionalTab) {
      return;
    }
    setState(() {
      if (!_hasProfessionalTab && hasProfessionalConnection) {
        if (_selectedPageIndex > 0) {
          _selectedPageIndex += 1;
        }
      } else if (_hasProfessionalTab && !hasProfessionalConnection) {
        if (_selectedPageIndex == 1) {
          _selectedPageIndex = 0;
        } else if (_selectedPageIndex > 1) {
          _selectedPageIndex -= 1;
        }
      }
      _hasProfessionalTab = hasProfessionalConnection;
    });
  }

  Future<void> _refreshProfessionalBadgeCount() async {
    final count =
        await locator<GetProfessionalUnseenSectionCountUsecase>().execute();
    if (!mounted) {
      return;
    }
    setState(() {
      _professionalBadgeCount = count;
    });
  }

  Widget _professionalTabIcon({required bool selected}) {
    final icon = Icon(
      selected ? Icons.medical_services : Icons.medical_services_outlined,
    );
    if (_professionalBadgeCount <= 0) {
      return icon;
    }
    final badgeText =
        _professionalBadgeCount > 9 ? '9+' : _professionalBadgeCount.toString();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(999),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            child: Text(
              badgeText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
