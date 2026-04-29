import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_quick_recipe_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_frequent_intake_preset_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';

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
  preWorkout,
  postWorkout,
  shake,
  leanMeal,
}

class _QuickGymMealsCardState extends State<QuickGymMealsCard> {
  late _QuickGymMealsFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _defaultFilter(widget.dailyFocus, widget.nutritionPhase);
  }

  @override
  void didUpdateWidget(covariant QuickGymMealsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyFocus != widget.dailyFocus ||
        oldWidget.nutritionPhase != widget.nutritionPhase) {
      _selectedFilter =
          _defaultFilter(widget.dailyFocus, widget.nutritionPhase);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardBackground =
        isDark ? colorScheme.surfaceContainerLow : colorScheme.surface;

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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.bolt_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comidas rápidas de gimnasio',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tus favoritas primero. Un toque registra una ración en la mejor franja.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        NavigationOptions.recipeLibraryRoute,
                        arguments: RecipeLibraryScreenArguments(
                          DateTime.now(),
                          IntakeTypeEntity.snack,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmarks_outlined),
                    tooltip: 'Comidas guardadas',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_QuickGymMealsFilter>(
                  showSelectedIcon: false,
                  segments: _QuickGymMealsFilter.values
                      .map((filter) => ButtonSegment<_QuickGymMealsFilter>(
                            value: filter,
                            label: Text(_labelForFilter(filter)),
                          ))
                      .toList(),
                  selected: {_selectedFilter},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedFilter = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<QuickRecipePresetEntity>>(
                future: locator<GetQuickRecipePresetsUsecase>().getPresets(
                  category: _categoryForFilter(_selectedFilter),
                  limit: 3,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 108,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final presets =
                      snapshot.data ?? const <QuickRecipePresetEntity>[];
                  if (presets.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.40),
                      ),
                      child: Text(
                        _selectedFilter == _QuickGymMealsFilter.all
                            ? 'Guarda comidas como recetas y marca tus repetidas como favoritas.'
                            : 'Aún no hay comidas rápidas en este carril. Añade una receta con pre, post, shake o cut en el nombre.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    children: presets
                        .map((preset) => Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _QuickRecipeTile(
                                preset: preset,
                                onAddPressed: () => _logPreset(context, preset),
                              ),
                            ))
                        .toList(growable: false),
                  );
                },
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<FrequentIntakePresetEntity>>(
                future: locator<GetFrequentIntakePresetsUsecase>()
                    .getTopPresets(limit: 10),
                builder: (context, snapshot) {
                  final presets =
                      snapshot.data ?? const <FrequentIntakePresetEntity>[];
                  if (presets.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comidas frecuentes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acceso rápido a tus raciones guardadas.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: presets
                            .map(
                              (preset) => ActionChip(
                                avatar: const Icon(
                                  Icons.flash_on_outlined,
                                  size: 16,
                                ),
                                label: Text(
                                  '${preset.title} (${preset.amount.toStringAsFixed(preset.amount % 1 == 0 ? 0 : 1)} ${preset.unit})',
                                ),
                                onPressed: () =>
                                    _logFrequentPreset(context, preset),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logFrequentPreset(
    BuildContext context,
    FrequentIntakePresetEntity preset,
  ) async {
    await locator<LogFrequentIntakePresetUsecase>().logPreset(preset);
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${preset.title} añadida (${preset.amount.toStringAsFixed(1)} ${preset.unit})',
          ),
        ),
      );
    }
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
            '${preset.recipe.name} añadida a ${_slotLabel(preset.defaultIntakeType)}',
          ),
        ),
      );
    }
  }

  _QuickGymMealsFilter _defaultFilter(
    DailyFocusEntity dailyFocus,
    UserWeightGoalEntity nutritionPhase,
  ) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return _QuickGymMealsFilter.leanMeal;
    }
    switch (dailyFocus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return _QuickGymMealsFilter.postWorkout;
      case DailyFocusEntity.cardio:
        return _QuickGymMealsFilter.shake;
      case DailyFocusEntity.rest:
        return _QuickGymMealsFilter.leanMeal;
    }
  }

  QuickRecipeCategoryEntity? _categoryForFilter(_QuickGymMealsFilter filter) {
    switch (filter) {
      case _QuickGymMealsFilter.all:
        return null;
      case _QuickGymMealsFilter.preWorkout:
        return QuickRecipeCategoryEntity.preWorkout;
      case _QuickGymMealsFilter.postWorkout:
        return QuickRecipeCategoryEntity.postWorkout;
      case _QuickGymMealsFilter.shake:
        return QuickRecipeCategoryEntity.shake;
      case _QuickGymMealsFilter.leanMeal:
        return QuickRecipeCategoryEntity.leanMeal;
    }
  }

  String _labelForFilter(_QuickGymMealsFilter filter) {
    switch (filter) {
      case _QuickGymMealsFilter.all:
        return 'Todo';
      case _QuickGymMealsFilter.preWorkout:
        return 'Pre';
      case _QuickGymMealsFilter.postWorkout:
        return 'Post';
      case _QuickGymMealsFilter.shake:
        return 'Batido';
      case _QuickGymMealsFilter.leanMeal:
        return 'Magra';
    }
  }

  String _slotLabel(IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return 'desayuno';
      case IntakeTypeEntity.lunch:
        return 'comida';
      case IntakeTypeEntity.dinner:
        return 'cena';
      case IntakeTypeEntity.snack:
        return 'snack';
    }
  }
}

class _QuickRecipeTile extends StatelessWidget {
  final QuickRecipePresetEntity preset;
  final VoidCallback onAddPressed;

  const _QuickRecipeTile({
    required this.preset,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (preset.recipe.favorite)
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: colorScheme.error,
                ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                tooltip: 'Registrar una ración',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: preset.category.icon,
                label: preset.category.label,
              ),
              _InfoChip(
                icon: Icons.local_fire_department_outlined,
                label: '${preset.kcalPerServing.toStringAsFixed(0)} kcal',
              ),
              _InfoChip(
                icon: Icons.egg_alt_outlined,
                label: 'P ${preset.proteinPerServing.toStringAsFixed(1)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'C ${preset.carbsPerServing.toStringAsFixed(1)} | F ${preset.fatPerServing.toStringAsFixed(1)} | P ${preset.proteinPerServing.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
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
