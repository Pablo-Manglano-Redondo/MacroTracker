import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class MealEntryActionSheet extends StatelessWidget {
  final DateTime day;
  final AddMealType? preferredMealType;

  const MealEntryActionSheet({
    super.key,
    required this.day,
    this.preferredMealType,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime day,
    AddMealType? preferredMealType,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => MealEntryActionSheet(
        day: day,
        preferredMealType: preferredMealType,
      ),
    );
  }

  bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = _isEs(context);
    final mealType = preferredMealType ?? _defaultMealTypeForNow();
    final intakeType = mealType.getIntakeType();

    final primaryActions = [
      _EntryAction(
        icon: Icons.search_outlined,
        title: isEs ? 'Buscar producto' : 'Search food',
        subtitle: isEs ? 'Base de datos y recientes' : 'Database and recent meals',
        color: colorScheme.primary,
        onTap: () => _openAddMeal(context, mealType),
      ),
      _EntryAction(
        icon: Icons.qr_code_scanner_outlined,
        title: isEs ? 'Escanear codigo' : 'Scan barcode',
        subtitle: isEs ? 'Producto envasado' : 'Packaged food',
        color: const Color(0xFF0EA5E9),
        onTap: () => _openScanner(context, intakeType),
      ),
      _EntryAction(
        icon: Icons.edit_note_outlined,
        title: isEs ? 'IA texto' : 'AI text',
        subtitle: isEs
            ? 'Revisa cantidades antes de guardar'
            : 'Review amounts before saving',
        color: const Color(0xFF8B5CF6),
        onTap: () => _openTextCapture(context, intakeType),
      ),
      _EntryAction(
        icon: Icons.add_a_photo_outlined,
        title: isEs ? 'IA foto' : 'AI photo',
        subtitle: isEs
            ? 'Revisa cantidades antes de guardar'
            : 'Review amounts before saving',
        color: const Color(0xFFEC4899),
        onTap: () => _openPhotoCapture(context, intakeType),
      ),
      _EntryAction(
        icon: Icons.bookmarks_outlined,
        title: isEs ? 'Recetas y frecuentes' : 'Recipes and frequent',
        subtitle: isEs ? 'Guardadas, fijadas y presets' : 'Saved meals and presets',
        color: const Color(0xFFF59E0B),
        onTap: () => _openRecipeLibrary(context, intakeType),
      ),
      _EntryAction(
        icon: UserActivityEntity.getIconData(),
        title: S.of(context).activityLabel,
        subtitle: isEs ? 'Entrenamiento o gasto extra' : 'Workout or extra burn',
        color: const Color(0xFFEF4444),
        onTap: () => _openAddActivity(context),
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEs ? 'Anadir comida' : 'Add meal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isEs
                  ? 'Elige como quieres registrar. La comida se guardara en ${_mealTypeLabel(context, mealType).toLowerCase()}.'
                  : 'Choose how to log it. The meal will be saved to ${_mealTypeLabel(context, mealType).toLowerCase()}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: primaryActions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.58,
              ),
              itemBuilder: (context, index) {
                return _EntryActionCard(action: primaryActions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  AddMealType _defaultMealTypeForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return AddMealType.breakfastType;
    if (hour < 16) return AddMealType.lunchType;
    if (hour < 20) return AddMealType.snackType;
    return AddMealType.dinnerType;
  }

  String _mealTypeLabel(BuildContext context, AddMealType mealType) {
    switch (mealType) {
      case AddMealType.breakfastType:
        return S.of(context).breakfastLabel;
      case AddMealType.lunchType:
        return S.of(context).lunchLabel;
      case AddMealType.dinnerType:
        return S.of(context).dinnerLabel;
      case AddMealType.snackType:
        return S.of(context).snackLabel;
    }
  }

  void _popAndPush(BuildContext context, String route, Object arguments) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(route, arguments: arguments);
  }

  void _openAddMeal(BuildContext context, AddMealType mealType) {
    _popAndPush(
      context,
      NavigationOptions.addMealRoute,
      AddMealScreenArguments(mealType, day),
    );
  }

  void _openScanner(BuildContext context, IntakeTypeEntity intakeType) {
    _popAndPush(
      context,
      NavigationOptions.scannerRoute,
      ScannerScreenArguments(day, intakeType),
    );
  }

  void _openTextCapture(BuildContext context, IntakeTypeEntity intakeType) {
    _popAndPush(
      context,
      NavigationOptions.mealTextCaptureRoute,
      MealTextCaptureScreenArguments(day, intakeType),
    );
  }

  void _openPhotoCapture(BuildContext context, IntakeTypeEntity intakeType) {
    _popAndPush(
      context,
      NavigationOptions.mealPhotoCaptureRoute,
      MealPhotoCaptureScreenArguments(day, intakeType),
    );
  }

  void _openRecipeLibrary(BuildContext context, IntakeTypeEntity intakeType) {
    _popAndPush(
      context,
      NavigationOptions.recipeLibraryRoute,
      RecipeLibraryScreenArguments(day, intakeType),
    );
  }

  void _openAddActivity(BuildContext context) {
    _popAndPush(
      context,
      NavigationOptions.addActivityRoute,
      AddActivityScreenArguments(day: day),
    );
  }
}

class _EntryAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _EntryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _EntryActionCard extends StatelessWidget {
  final _EntryAction action;

  const _EntryActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          action.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: action.color, size: 22),
              const Spacer(),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.15,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
