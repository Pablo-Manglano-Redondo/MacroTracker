import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/services/backup_nudge_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/presentation/widgets/meal_entry_action_sheet.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/diary_page.dart';
import 'package:macrotracker/core/presentation/widgets/home_appbar.dart';
import 'package:macrotracker/features/home/home_page.dart';
import 'package:macrotracker/core/presentation/widgets/main_appbar.dart';
import 'package:macrotracker/features/profile/profile_page.dart';
import 'package:macrotracker/features/professional_plan/presentation/professional_plan_screen.dart';
import 'package:macrotracker/features/settings/presentation/widgets/drive_backup_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPageIndex = 0;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinkSubscription;

  late List<Widget> _bodyPages;
  late List<PreferredSizeWidget> _appbarPages;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initInviteLinks();

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
    _bodyPages = [
      const HomePage(),
      const DiaryPage(),
      const ProfilePage(),
    ];
    _appbarPages = [
      const HomeAppbar(),
      MainAppbar(title: S.of(context).diaryLabel, iconData: Icons.book),
      MainAppbar(
          title: S.of(context).profileLabel, iconData: Icons.account_circle),
    ];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initInviteLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _openInviteLink(initialUri);
      }
      _appLinkSubscription = _appLinks.uriLinkStream.listen(_openInviteLink);
    } catch (_) {
      // Deep links are a convenience path. Manual invite-code entry remains available.
    }
  }

  void _openInviteLink(Uri uri) {
    final code = _extractInviteCode(uri);
    if (code == null || code.isEmpty || !mounted) {
      return;
    }
    Navigator.of(context).pushNamed(
      NavigationOptions.professionalPlanRoute,
      arguments: ProfessionalPlanScreenArguments(inviteCode: code),
    );
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

  void _toggleFab() {
    HapticFeedback.selectionClick();
    MealEntryActionSheet.show(context, day: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarPages[_selectedPageIndex],
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _bodyPages,
      ),
      floatingActionButton:
          _selectedPageIndex == 0 ? _buildSpeedDial(context) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: _setPage,
        destinations: [
          NavigationDestination(
              icon: _selectedPageIndex == 0
                  ? const Icon(Icons.home)
                  : const Icon(Icons.home_outlined),
              label: S.of(context).homeLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 1
                  ? const Icon(Icons.book)
                  : const Icon(Icons.book_outlined),
              label: S.of(context).diaryLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 2
                  ? const Icon(Icons.account_circle)
                  : const Icon(Icons.account_circle_outlined),
              label: S.of(context).profileLabel),
        ],
      ),
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _toggleFab,
          tooltip: isEs ? 'Añadir comida' : 'Add meal',
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
  }
}
