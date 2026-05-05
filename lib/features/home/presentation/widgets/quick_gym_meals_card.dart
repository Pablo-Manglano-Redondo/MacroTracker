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
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_favorite_usecase.dart';
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
                          _title(context),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(context),
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
                    tooltip: _savedTooltip(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_QuickGymMealsFilter>(
                  showSelectedIcon: false,
                  segments: _QuickGymMealsFilter.values
                      .map(
                        (filter) => ButtonSegment<_QuickGymMealsFilter>(
                          value: filter,
                          label: Text(_labelForFilter(context, filter)),
                        ),
                      )
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
                            ? _emptyAll(context)
                            : _emptyFiltered(context),
                        style: Theme.of(context).textTheme.bodyMedium,
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
                              onLongPress: () =>
                                  _handlePresetLongPress(context, preset),
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

  Future<void> _handlePresetLongPress(
    BuildContext context,
    QuickRecipePresetEntity preset,
  ) async {
    if (!preset.recipe.favorite) {
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
                leading: const Icon(Icons.heart_broken_outlined),
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

    await locator<SetRecipeFavoriteUsecase>()
        .setFavorite(preset.recipe.id, false);

    if (mounted) {
      setState(() {});
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

  String _labelForFilter(BuildContext context, _QuickGymMealsFilter filter) {
    switch (filter) {
      case _QuickGymMealsFilter.all:
        return _isEs(context) ? 'Todo' : 'All';
      case _QuickGymMealsFilter.preWorkout:
        return _isEs(context) ? 'Preentreno' : 'Pre-workout';
      case _QuickGymMealsFilter.postWorkout:
        return _isEs(context) ? 'Postentreno' : 'Post-workout';
      case _QuickGymMealsFilter.shake:
        return _isEs(context) ? 'Batido' : 'Shake';
      case _QuickGymMealsFilter.leanMeal:
        return _isEs(context) ? 'Ligera' : 'Light meal';
    }
  }

  String _slotLabel(BuildContext context, IntakeTypeEntity intakeType) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return isEs ? 'desayuno' : 'breakfast';
      case IntakeTypeEntity.lunch:
        return isEs ? 'comida' : 'lunch';
      case IntakeTypeEntity.dinner:
        return isEs ? 'cena' : 'dinner';
      case IntakeTypeEntity.snack:
        return 'snack';
    }
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _title(BuildContext context) =>
      _isEs(context) ? 'Comidas rápidas' : 'Quick meals';

  String _subtitle(BuildContext context) => _isEs(context)
      ? 'Tira primero de tus recetas guardadas. Un toque registra una ración.'
      : 'Use your saved recipes first. One tap logs a serving fast.';

  String _savedTooltip(BuildContext context) =>
      _isEs(context) ? 'Abrir comidas guardadas' : 'Open saved meals';

  String _emptyAll(BuildContext context) => _isEs(context)
      ? 'Guarda comidas como recetas para tenerlas a un toque aquí.'
      : 'Save meals as recipes to keep them one tap away here.';

  String _emptyFiltered(BuildContext context) => _isEs(context)
      ? 'Aún no hay comidas rápidas en este bloque. Usa nombres claros de entreno para reconocerlas mejor después.'
      : 'No quick meals in this lane yet. Use clear workout-style names so they are easier to recognize later.';

  String _addedTo(BuildContext context, String recipe, String slot) =>
      _isEs(context) ? '$recipe añadida a $slot' : '$recipe added to $slot';
}

class _QuickRecipeTile extends StatelessWidget {
  final QuickRecipePresetEntity preset;
  final VoidCallback onAddPressed;
  final VoidCallback onLongPress;

  const _QuickRecipeTile({
    required this.preset,
    required this.onAddPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: onLongPress,
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    tooltip: _isEs(context)
                        ? 'Registrar una ración'
                        : 'Log one serving',
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
                    label: _categoryLabel(context, preset.category),
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
        return _isEs(context) ? 'Preentreno' : 'Pre-workout';
      case QuickRecipeCategoryEntity.postWorkout:
        return _isEs(context) ? 'Postentreno' : 'Post-workout';
      case QuickRecipeCategoryEntity.shake:
        return _isEs(context) ? 'Batido' : 'Shake';
      case QuickRecipeCategoryEntity.leanMeal:
        return _isEs(context) ? 'Ligera' : 'Light meal';
    }
  }

  String _proteinShort(BuildContext context, double amount) {
    return _isEs(context)
        ? 'P ${amount.toStringAsFixed(1)}'
        : 'P ${amount.toStringAsFixed(1)}';
  }

  String _macrosSummary(BuildContext context) {
    final carbs = preset.carbsPerServing.toStringAsFixed(1);
    final fat = preset.fatPerServing.toStringAsFixed(1);
    final protein = preset.proteinPerServing.toStringAsFixed(1);
    return 'C $carbs | F $fat | P $protein';
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
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
