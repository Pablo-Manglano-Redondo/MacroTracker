import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/services/backup_nudge_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/diary/diary_page.dart';
import 'package:macrotracker/core/presentation/widgets/home_appbar.dart';
import 'package:macrotracker/features/home/home_page.dart';
import 'package:macrotracker/core/presentation/widgets/main_appbar.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';
import 'package:macrotracker/features/profile/profile_page.dart';
import 'package:macrotracker/features/professional_plan/presentation/professional_plan_screen.dart';
import 'package:macrotracker/features/settings/presentation/widgets/drive_backup_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPageIndex = 0;
  bool _fabExpanded = false;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinkSubscription;

  late AnimationController _fabAnimController;
  late Animation<double> _fabRotation;
  late Animation<double> _fabScale;

  late List<Widget> _bodyPages;
  late List<PreferredSizeWidget> _appbarPages;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _fabRotation = Tween<double>(begin: 0.0, end: 0.375).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
    _fabScale = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
    );
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
    _fabAnimController.dispose();
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
    setState(() => _fabExpanded = !_fabExpanded);
    if (_fabExpanded) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }
  }

  void _closeFab() {
    if (_fabExpanded) {
      setState(() => _fabExpanded = false);
      _fabAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _fabExpanded ? _closeFab : null,
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    final actions = [
      _SpeedDialAction(
        icon: Icons.add_a_photo_outlined,
        label: isEs ? 'Foto IA' : 'AI Photo',
        color: colorScheme.primary,
        onTap: () => _navigateTo(_openPhotoCapture),
      ),
      _SpeedDialAction(
        icon: Icons.edit_note_outlined,
        label: isEs ? 'Texto IA' : 'AI Text',
        color: colorScheme.secondary,
        onTap: () => _navigateTo(_openTextCapture),
      ),
      _SpeedDialAction(
        icon: Icons.wb_sunny_outlined,
        label: isEs ? 'Desayuno' : 'Breakfast',
        color: const Color(0xFFF59E0B),
        onTap: () => _navigateTo(() => _openAddMeal(AddMealType.breakfastType)),
      ),
      _SpeedDialAction(
        icon: Icons.restaurant_outlined,
        label: isEs ? 'Almuerzo' : 'Lunch',
        color: const Color(0xFF10B981),
        onTap: () => _navigateTo(() => _openAddMeal(AddMealType.lunchType)),
      ),
      _SpeedDialAction(
        icon: Icons.nights_stay_outlined,
        label: isEs ? 'Cena' : 'Dinner',
        color: const Color(0xFF6366F1),
        onTap: () => _navigateTo(() => _openAddMeal(AddMealType.dinnerType)),
      ),
      _SpeedDialAction(
        icon: Icons.fitness_center_outlined,
        label: isEs ? 'Ejercicio' : 'Activity',
        color: const Color(0xFFEF4444),
        onTap: () => _navigateTo(_openAddActivity),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed dial items (bottom to top, so reversed in list)
        ...actions.reversed.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          final delay = index * 0.08;
          return _SpeedDialItem(
            action: action,
            animation: _fabScale,
            delay: delay,
            visible: _fabExpanded,
          );
        }),
        const SizedBox(height: 8),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggleFab,
          tooltip: S.of(context).addLabel,
          child: AnimatedBuilder(
            animation: _fabRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _fabRotation.value * 2 * 3.14159,
                child: child,
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _navigateTo(VoidCallback action) {
    _closeFab();
    // Small delay so the FAB closes before pushing route
    Future.delayed(const Duration(milliseconds: 100), action);
  }

  void _setPage(int selectedIndex) {
    HapticFeedback.selectionClick();
    _closeFab();
    setState(() {
      _selectedPageIndex = selectedIndex;
    });
  }

  void _openTextCapture() {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealTextCaptureRoute,
      arguments: MealTextCaptureScreenArguments(
          DateTime.now(), IntakeTypeEntity.lunch),
    );
  }

  void _openPhotoCapture() {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealPhotoCaptureRoute,
      arguments: MealPhotoCaptureScreenArguments(
          DateTime.now(), IntakeTypeEntity.lunch),
    );
  }

  void _openAddMeal(AddMealType mealType) {
    Navigator.of(context).pushNamed(
      NavigationOptions.addMealRoute,
      arguments: AddMealScreenArguments(mealType, DateTime.now()),
    );
  }

  void _openAddActivity() {
    Navigator.of(context).pushNamed(
      NavigationOptions.addActivityRoute,
      arguments: AddActivityScreenArguments(day: DateTime.now()),
    );
  }
}

// --- Speed Dial helpers ---

class _SpeedDialAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _SpeedDialItem extends StatelessWidget {
  final _SpeedDialAction action;
  final Animation<double> animation;
  final double delay;
  final bool visible;

  const _SpeedDialItem({
    required this.action,
    required this.animation,
    required this.delay,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: Duration(milliseconds: visible ? 220 : 160),
        offset: visible ? Offset.zero : const Offset(0, 0.3),
        curve: visible ? Curves.easeOutBack : Curves.easeIn,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: visible ? 200 : 140),
          opacity: visible ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: visible ? 1.0 : 0.0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      action.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Mini FAB
                SizedBox(
                  width: 46,
                  height: 46,
                  child: FloatingActionButton.small(
                    heroTag: 'speed_dial_${action.label}',
                    onPressed: action.onTap,
                    backgroundColor: action.color,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    child: Icon(action.icon, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
