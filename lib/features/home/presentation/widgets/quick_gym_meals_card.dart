import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_quick_recipe_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_saved_usecase.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class QuickGymMealsCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final UserWeightGoalEntity nutritionPhase;

  const QuickGymMealsCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.dailyFocus,
    required this.nutritionPhase,
  });

  @override
  State<QuickGymMealsCard> createState() => _QuickGymMealsCardState();
}

enum _QuickGymMealsFilter {
  all,
  breakfast,
  lunch,
  dinner,
  preWorkout,
  postWorkout,
  shake,
  snack,
}

class _QuickGymMealsCardState extends State<QuickGymMealsCard> {
  late _QuickGymMealsFilter _selectedFilter;
  late Future<List<QuickRecipePresetEntity>> _presetsFuture;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _defaultFilter(widget.dailyFocus, widget.nutritionPhase);
    _presetsFuture = _loadPresets(_selectedFilter);
  }

  @override
  void didUpdateWidget(covariant QuickGymMealsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyFocus != widget.dailyFocus ||
        oldWidget.nutritionPhase != widget.nutritionPhase) {
      _selectedFilter =
          _defaultFilter(widget.dailyFocus, widget.nutritionPhase);
      _presetsFuture = _loadPresets(_selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardBackground =
        isDark ? const Color(0xFF121212) : Colors.white;

    return Padding(
      padding: widget.padding,
      child: Card(
        elevation: 0.5,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE7A83B),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _title(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Tooltip(
                    message: _savedTooltip(context),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          NavigationOptions.recipeLibraryRoute,
                          arguments: RecipeLibraryScreenArguments(
                            DateTime.now(),
                            IntakeTypeEntity.snack,
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_outline, size: 18),
                      label: Text(
                        S.of(context).recipeLibraryManualSectionTitle,
                        textAlign: TextAlign.center,
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  _subtitle(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _QuickGymMealsFilter.values.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    final Color bgColor = isSelected
                        ? const Color(0xFF10B981)
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4));
                    final Color textColor = isSelected
                        ? Colors.black
                        : colorScheme.onSurfaceVariant;
                    final Border border = Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : colorScheme.outlineVariant.withValues(alpha: 0.25)),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                            _presetsFuture = _loadPresets(_selectedFilter);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(999),
                            border: border,
                          ),
                          child: Text(
                            _labelForFilter(context, filter),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<QuickRecipePresetEntity>>(
                future: _presetsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData &&
                      snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 108,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final presets =
                      snapshot.data ?? const <QuickRecipePresetEntity>[];
                  if (presets.isEmpty) {
                    return CustomPaint(
                      painter: DashedRectPainter(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                        radius: 16,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          _selectedFilter == _QuickGymMealsFilter.all
                              ? _emptyAll(context)
                              : _emptyFiltered(context),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: presets
                        .map(
                          (preset) => Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _QuickRecipeTile(
                              preset: preset,
                              onAddPressed: () => _logPreset(context, preset),
                              onRemoveSavedPressed: () =>
                                  _removeSavedPreset(context, preset),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logPreset(
    BuildContext context,
    QuickRecipePresetEntity preset,
  ) async {
    await locator<LogRecipeUsecase>().logRecipe(
      preset.recipe,
      1,
      preset.defaultIntakeType,
      DateTime.now(),
    );
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _addedTo(
              context,
              preset.recipe.name,
              _slotLabel(context, preset.defaultIntakeType),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _removeSavedPreset(
    BuildContext context,
    QuickRecipePresetEntity preset,
  ) async {
    if (!preset.recipe.saved) {
      return;
    }

    final shouldRemove = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_remove_outlined),
                title: Text(S.of(context).recipeLibraryRemoveFavorite),
                onTap: () => Navigator.of(sheetContext).pop(true),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(S.of(context).dialogCancelLabel),
                onTap: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    await locator<SetRecipeSavedUsecase>().setSaved(preset.recipe.id, false);

    if (mounted) {
      setState(() {
        _presetsFuture = _loadPresets(_selectedFilter);
      });
    }
  }

  Future<List<QuickRecipePresetEntity>> _loadPresets(
    _QuickGymMealsFilter filter,
  ) async {
    final presets = await locator<GetQuickRecipePresetsUsecase>().getPresets(
      limit: 24,
    );
    final filtered = _applyFilter(presets, filter);
    return filtered.take(3).toList(growable: false);
  }

  _QuickGymMealsFilter _defaultFilter(
    DailyFocusEntity dailyFocus,
    UserWeightGoalEntity nutritionPhase,
  ) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return _QuickGymMealsFilter.snack;
    }
    switch (dailyFocus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return _QuickGymMealsFilter.postWorkout;
      case DailyFocusEntity.cardio:
        return _QuickGymMealsFilter.shake;
      case DailyFocusEntity.rest:
        return _QuickGymMealsFilter.snack;
    }
  }

  List<QuickRecipePresetEntity> _applyFilter(
    List<QuickRecipePresetEntity> presets,
    _QuickGymMealsFilter filter,
  ) {
    switch (filter) {
      case _QuickGymMealsFilter.all:
        return presets;
      case _QuickGymMealsFilter.breakfast:
        return presets
            .where(
              (preset) =>
                  preset.defaultIntakeType == IntakeTypeEntity.breakfast,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.lunch:
        return presets
            .where(
              (preset) => preset.defaultIntakeType == IntakeTypeEntity.lunch,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.dinner:
        return presets
            .where(
              (preset) => preset.defaultIntakeType == IntakeTypeEntity.dinner,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.preWorkout:
        return presets
            .where(
              (preset) =>
                  preset.category == QuickRecipeCategoryEntity.preWorkout,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.postWorkout:
        return presets
            .where(
              (preset) =>
                  preset.category == QuickRecipeCategoryEntity.postWorkout,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.shake:
        return presets
            .where(
              (preset) => preset.category == QuickRecipeCategoryEntity.shake,
            )
            .toList(growable: false);
      case _QuickGymMealsFilter.snack:
        return presets
            .where(
              (preset) =>
                  preset.defaultIntakeType == IntakeTypeEntity.snack ||
                  preset.category == QuickRecipeCategoryEntity.leanMeal,
            )
            .toList(growable: false);
    }
  }

  String _labelForFilter(BuildContext context, _QuickGymMealsFilter filter) {
    switch (filter) {
      case _QuickGymMealsFilter.all:
        return S.of(context).quickMealsFilterAll;
      case _QuickGymMealsFilter.breakfast:
        return S.of(context).breakfastLabel;
      case _QuickGymMealsFilter.lunch:
        return S.of(context).lunchLabel;
      case _QuickGymMealsFilter.dinner:
        return S.of(context).dinnerLabel;
      case _QuickGymMealsFilter.preWorkout:
        return S.of(context).quickMealsFilterPreWorkout;
      case _QuickGymMealsFilter.postWorkout:
        return S.of(context).quickMealsFilterPostWorkout;
      case _QuickGymMealsFilter.shake:
        return S.of(context).quickMealsFilterShake;
      case _QuickGymMealsFilter.snack:
        return S.of(context).snackLabel;
    }
  }

  String _slotLabel(BuildContext context, IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return S.of(context).breakfastLabel.toLowerCase();
      case IntakeTypeEntity.lunch:
        return S.of(context).lunchLabel.toLowerCase();
      case IntakeTypeEntity.dinner:
        return S.of(context).dinnerLabel.toLowerCase();
      case IntakeTypeEntity.snack:
        return S.of(context).snackLabel.toLowerCase();
    }
  }

  String _title(BuildContext context) =>
      S.of(context).quickMealsTitle;

  String _subtitle(BuildContext context) => S.of(context).quickMealsSubtitle;

  String _savedTooltip(BuildContext context) =>
      S.of(context).quickMealsSavedTooltip;

  String _emptyAll(BuildContext context) => S.of(context).quickMealsEmptyAll;

  String _emptyFiltered(BuildContext context) =>
      S.of(context).quickMealsEmptyFiltered;

  String _addedTo(BuildContext context, String recipe, String slot) =>
      S.of(context).quickMealsAddedTo(recipe, slot);
}

class _QuickRecipeTile extends StatelessWidget {
  final QuickRecipePresetEntity preset;
  final VoidCallback onAddPressed;
  final VoidCallback onRemoveSavedPressed;

  const _QuickRecipeTile({
    required this.preset,
    required this.onAddPressed,
    required this.onRemoveSavedPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taggedIntakeType = QuickRecipeCategoryEntityX.inferTaggedIntakeType(
      preset.recipe,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preset.recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRemoveSavedPressed,
                    icon: const Icon(Icons.bookmark_remove_outlined),
                    tooltip: S.of(context).recipeLibraryRemoveFavorite,
                  ),
                  IconButton.filledTonal(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    tooltip: S.of(context).quickMealsLogServing,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon:
                        taggedIntakeType?.getIconData() ?? preset.category.icon,
                    label: taggedIntakeType == null
                        ? _categoryLabel(context, preset.category)
                        : _intakeTypeLabel(context, taggedIntakeType),
                  ),
                  _InfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${preset.kcalPerServing.toStringAsFixed(0)} kcal',
                  ),
                  _InfoChip(
                    icon: Icons.egg_alt_outlined,
                    label: _proteinShort(context, preset.proteinPerServing),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _macrosSummary(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(
    BuildContext context,
    QuickRecipeCategoryEntity category,
  ) {
    switch (category) {
      case QuickRecipeCategoryEntity.preWorkout:
        return S.of(context).quickCategoryPreWorkout;
      case QuickRecipeCategoryEntity.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case QuickRecipeCategoryEntity.shake:
        return S.of(context).quickCategoryShake;
      case QuickRecipeCategoryEntity.leanMeal:
        return S.of(context).quickCategoryLeanMeal;
    }
  }

  String _proteinShort(BuildContext context, double amount) {
    return S.of(context).quickMealsProteinShort(amount.toStringAsFixed(1));
  }

  String _intakeTypeLabel(
    BuildContext context,
    IntakeTypeEntity intakeType,
  ) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return S.of(context).breakfastLabel;
      case IntakeTypeEntity.lunch:
        return S.of(context).lunchLabel;
      case IntakeTypeEntity.dinner:
        return S.of(context).dinnerLabel;
      case IntakeTypeEntity.snack:
        return S.of(context).snackLabel;
    }
  }

  String _macrosSummary(BuildContext context) {
    final carbs = preset.carbsPerServing.toStringAsFixed(1);
    final fat = preset.fatPerServing.toStringAsFixed(1);
    final protein = preset.proteinPerServing.toStringAsFixed(1);
    return S.of(context).quickMealsMacrosSummary(carbs, fat, protein);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dash = 5.0,
    this.radius = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      gap != oldDelegate.gap ||
      dash != oldDelegate.dash ||
      radius != oldDelegate.radius;
}
