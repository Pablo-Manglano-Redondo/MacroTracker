import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_frequent_intake_preset_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_pinned_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_saved_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/presentation/widgets/recipe_detail_bottom_sheet.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';

import 'recipe_editor_screen.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

enum _RecipeLibraryFilter {
  all,
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout,
  shake,
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  late DateTime _day;
  late IntakeTypeEntity _intakeTypeEntity;
  final _searchController = TextEditingController();
  _RecipeLibraryFilter _selectedFilter = _RecipeLibraryFilter.all;

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is RecipeLibraryScreenArguments) {
      _day = routeArgs.day;
      _intakeTypeEntity = routeArgs.intakeTypeEntity;
    } else if (routeArgs is Map) {
      _day = routeArgs['day'] as DateTime? ?? DateTime.now();
      _intakeTypeEntity = routeArgs['mealType'] as IntakeTypeEntity? ??
          IntakeTypeEntity.breakfast;
    } else {
      _day = DateTime.now();
      _intakeTypeEntity = IntakeTypeEntity.breakfast;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).recipeLibraryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_outlined),
                hintText: S.of(context).recipeLibrarySearchHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _RecipeLibraryFilter.values
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filterLabel(filter)),
                        selected: _selectedFilter == filter,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<RecipeEntity>>(
              future: locator<GetRecipeLibraryUsecase>().getAllRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return FutureBuilder<List<FrequentIntakePresetEntity>>(
                  future: locator<GetFrequentIntakePresetsUsecase>()
                      .getTopPresets(limit: 12),
                  builder: (context, frequentSnapshot) {
                    if (frequentSnapshot.connectionState !=
                        ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final recipes =
                        _filterRecipes(snapshot.data ?? const <RecipeEntity>[]);
                    final frequentPresets = _filterFrequentPresets(
                      frequentSnapshot.data ??
                          const <FrequentIntakePresetEntity>[],
                    );

                    if (recipes.isEmpty && frequentPresets.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            S.of(context).recipeLibraryEmpty,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      children: [
                        if (_searchController.text.trim().isEmpty)
                          const _LibraryIntroCard(),
                        if (recipes.isNotEmpty) ...[
                          _LibrarySectionHeader(
                            title: _manualSectionTitle(context),
                            subtitle: _manualSectionSubtitle(context),
                          ),
                          ...recipes.map(_buildRecipeTile),
                        ],
                        if (frequentPresets.isNotEmpty) ...[
                          _LibrarySectionHeader(
                            title: _frequentSectionTitle(context),
                            subtitle: _frequentSectionSubtitle(context),
                          ),
                          ...frequentPresets.map(_buildFrequentTile),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<RecipeEntity> _filterRecipes(List<RecipeEntity> recipes) {
    final query = _searchController.text.trim().toLowerCase();
    return recipes.where((recipe) {
      final matchesText =
          query.isEmpty || recipe.name.toLowerCase().contains(query);
      return matchesText && _matchesRecipeFilter(recipe, _selectedFilter);
    }).toList(growable: false);
  }

  List<FrequentIntakePresetEntity> _filterFrequentPresets(
    List<FrequentIntakePresetEntity> presets,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return presets.where((preset) {
      final matchesText =
          query.isEmpty || preset.title.toLowerCase().contains(query);
      return matchesText && _matchesFrequentFilter(preset, _selectedFilter);
    }).toList(growable: false);
  }

  Widget _buildRecipeTile(RecipeEntity recipe) {
    final category = RecipeSaveCategoryEntityX.fromRecipe(recipe);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.5),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: () => _showRecipeDetailSheet(recipe),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.12 : 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _filterIcon(category),
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${S.of(context).recipeLibraryIngredientsCount(recipe.ingredients.length)} | ${S.of(context).recipeLibraryServingsCount(recipe.defaultServings % 1 == 0 ? recipe.defaultServings.toInt() : recipe.defaultServings)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _RecipeMetaChip(
                            icon: _filterIcon(category),
                            label: _categoryLabel(category),
                          ),
                          if (recipe.pinned)
                            _RecipeMetaChip(
                              icon: Icons.push_pin_outlined,
                              label: _isEs(context) ? 'Fijada' : 'Pinned',
                            ),
                          if (recipe.timesUsed > 0)
                            _RecipeMetaChip(
                              icon: Icons.repeat_outlined,
                              label: _isEs(context)
                                  ? '${recipe.timesUsed} usos'
                                  : '${recipe.timesUsed} uses',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _togglePinned(recipe),
                      icon: Icon(
                        recipe.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 20,
                        color: recipe.pinned ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      tooltip: recipe.pinned
                          ? (_isEs(context) ? 'Quitar pin' : 'Unpin')
                          : (_isEs(context) ? 'Fijar' : 'Pin'),
                    ),
                    IconButton(
                      onPressed: () => _showRecipeActions(recipe),
                      icon: Icon(
                        Icons.more_horiz,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      tooltip: _isEs(context) ? 'Acciones' : 'Actions',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequentTile(FrequentIntakePresetEntity preset) {
    final amountText = preset.amount.toStringAsFixed(
      preset.amount % 1 == 0 ? 0 : 1,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.5),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: () => _logFrequentPreset(preset),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: isDark ? 0.12 : 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_outlined,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preset.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$amountText ${preset.unit} | ${_frequentUses(context, preset.uses)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddRecipeDialog(RecipeEntity recipe) async {
    final controller = TextEditingController(
        text: recipe.defaultServings.toStringAsFixed(
      recipe.defaultServings % 1 == 0 ? 0 : 1,
    ));
    final confirmed = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(recipe.name),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: S.of(context).servingsLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(S.of(context).dialogCancelLabel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                    double.tryParse(controller.text.replaceAll(',', '.')) ?? 1);
              },
              child: Text(S.of(context).addLabel),
            ),
          ],
        );
      },
    );

    if (confirmed == null) {
      return;
    }

    await locator<LogRecipeUsecase>()
        .logRecipe(recipe, confirmed, _intakeTypeEntity, _day);
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).recipeLibraryAddedSnackbar(recipe.name)),
        ),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    }
  }

  void _showRecipeDetailSheet(RecipeEntity recipe) {
    final category = RecipeSaveCategoryEntityX.fromRecipe(recipe).quickCategory;
    final intakeType = RecipeSaveCategoryEntityX.fromRecipe(recipe).explicitIntakeType ?? _intakeTypeEntity;
    final aggregateMeal = MealAggregateFactory.fromRecipe(recipe);
    final servings = recipe.defaultServings;
    final kcal = (aggregateMeal.nutriments.energyPerUnit ?? 0) * servings;
    final carbs = (aggregateMeal.nutriments.carbohydratesPerUnit ?? 0) * servings;
    final fat = (aggregateMeal.nutriments.fatPerUnit ?? 0) * servings;
    final protein = (aggregateMeal.nutriments.proteinsPerUnit ?? 0) * servings;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => RecipeDetailBottomSheet(
        recipe: recipe,
        category: category,
        intakeType: intakeType,
        servings: servings,
        kcal: kcal,
        carbs: carbs,
        fat: fat,
        protein: protein,
        rationale: _displayRecipeNotes(recipe.notes),
        rationaleTitle: isEs ? 'Notas de la receta' : 'Recipe notes',
        onLogPressed: () async {
          Navigator.of(sheetContext).pop();
          await locator<LogRecipeUsecase>()
              .logRecipe(recipe, servings, _intakeTypeEntity, _day);
          locator<HomeBloc>().add(const LoadItemsEvent());
          locator<DiaryBloc>().add(const LoadDiaryYearEvent());
          locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).recipeLibraryAddedSnackbar(recipe.name)),
              ),
            );
            Navigator.of(context)
                .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
          }
        },
        onEditPressed: () async {
          Navigator.of(sheetContext).pop();
          await _openEditor(recipe);
        },
      ),
    );
  }

  String? _displayRecipeNotes(String? notes) {
    if (notes == null) {
      return null;
    }

    final cleaned = notes
        .replaceAll(RegExp(r'#breakfast\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#desayuno\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#lunch\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#comida\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#dinner\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#cena\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#snack\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempie\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempiÃ©\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isEmpty ? null : cleaned;
  }

  Future<void> _togglePinned(RecipeEntity recipe) async {
    await locator<SetRecipePinnedUsecase>()
        .setPinned(recipe.id, !recipe.pinned);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleSaved(RecipeEntity recipe) async {
    await locator<SetRecipeSavedUsecase>().setSaved(recipe.id, !recipe.saved);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openEditor(RecipeEntity recipe) async {
    final didSave = await Navigator.of(context).pushNamed(
      NavigationOptions.recipeEditorRoute,
      arguments: RecipeEditorScreenArguments(recipe),
    );
    if (didSave == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _showRecipeActions(RecipeEntity recipe) async {
    final action = await showModalBottomSheet<_RecipeAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(_isEs(context) ? 'Editar' : 'Edit'),
                onTap: () => Navigator.of(sheetContext).pop(_RecipeAction.edit),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_remove_outlined),
                title: Text(_removeSavedLabel(context)),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_RecipeAction.toggleSaved),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(S.of(context).dialogCancelLabel),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
    if (action == null) {
      return;
    }
    await _onRecipeAction(recipe, action);
  }

  Future<void> _onRecipeAction(
      RecipeEntity recipe, _RecipeAction action) async {
    switch (action) {
      case _RecipeAction.edit:
        await _openEditor(recipe);
        break;
      case _RecipeAction.toggleSaved:
        await _toggleSaved(recipe);
        break;
    }
  }

  Future<void> _logFrequentPreset(FrequentIntakePresetEntity preset) async {
    await locator<LogFrequentIntakePresetUsecase>()
        .logPreset(preset, day: _day);
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).recipeLibraryAddedSnackbar(preset.title)),
        ),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    }
  }

  bool _matchesRecipeFilter(
    RecipeEntity recipe,
    _RecipeLibraryFilter filter,
  ) {
    if (filter == _RecipeLibraryFilter.all) {
      return true;
    }
    return _mapFilterToCategory(filter) ==
        RecipeSaveCategoryEntityX.fromRecipe(recipe);
  }

  bool _matchesFrequentFilter(
    FrequentIntakePresetEntity preset,
    _RecipeLibraryFilter filter,
  ) {
    if (filter == _RecipeLibraryFilter.all) {
      return true;
    }

    final presetCategory = _inferPresetCategory(preset);
    return presetCategory == _mapFilterToCategory(filter);
  }

  RecipeSaveCategoryEntity _inferPresetCategory(
      FrequentIntakePresetEntity preset) {
    switch (preset.intakeType) {
      case IntakeTypeEntity.breakfast:
        return RecipeSaveCategoryEntity.breakfast;
      case IntakeTypeEntity.lunch:
        return RecipeSaveCategoryEntity.lunch;
      case IntakeTypeEntity.dinner:
        return RecipeSaveCategoryEntity.dinner;
      case IntakeTypeEntity.snack:
        final text = preset.title.toLowerCase();
        if (text.contains('pre')) {
          return RecipeSaveCategoryEntity.preWorkout;
        }
        if (text.contains('post')) {
          return RecipeSaveCategoryEntity.postWorkout;
        }
        if (text.contains('shake') || text.contains('batido')) {
          return RecipeSaveCategoryEntity.shake;
        }
        return RecipeSaveCategoryEntity.snack;
    }
  }

  RecipeSaveCategoryEntity _mapFilterToCategory(_RecipeLibraryFilter filter) {
    switch (filter) {
      case _RecipeLibraryFilter.all:
        return RecipeSaveCategoryEntity.snack;
      case _RecipeLibraryFilter.breakfast:
        return RecipeSaveCategoryEntity.breakfast;
      case _RecipeLibraryFilter.lunch:
        return RecipeSaveCategoryEntity.lunch;
      case _RecipeLibraryFilter.dinner:
        return RecipeSaveCategoryEntity.dinner;
      case _RecipeLibraryFilter.snack:
        return RecipeSaveCategoryEntity.snack;
      case _RecipeLibraryFilter.preWorkout:
        return RecipeSaveCategoryEntity.preWorkout;
      case _RecipeLibraryFilter.postWorkout:
        return RecipeSaveCategoryEntity.postWorkout;
      case _RecipeLibraryFilter.shake:
        return RecipeSaveCategoryEntity.shake;
    }
  }

  String _filterLabel(_RecipeLibraryFilter filter) {
    switch (filter) {
      case _RecipeLibraryFilter.all:
        return _isEs(context) ? 'Todo' : 'All';
      case _RecipeLibraryFilter.breakfast:
        return S.of(context).breakfastLabel;
      case _RecipeLibraryFilter.lunch:
        return S.of(context).lunchLabel;
      case _RecipeLibraryFilter.dinner:
        return S.of(context).dinnerLabel;
      case _RecipeLibraryFilter.snack:
        return S.of(context).snackLabel;
      case _RecipeLibraryFilter.preWorkout:
        return S.of(context).quickCategoryPreWorkout;
      case _RecipeLibraryFilter.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case _RecipeLibraryFilter.shake:
        return S.of(context).quickCategoryShake;
    }
  }

  String _categoryLabel(RecipeSaveCategoryEntity category) {
    switch (category) {
      case RecipeSaveCategoryEntity.breakfast:
        return S.of(context).breakfastLabel;
      case RecipeSaveCategoryEntity.lunch:
        return S.of(context).lunchLabel;
      case RecipeSaveCategoryEntity.dinner:
        return S.of(context).dinnerLabel;
      case RecipeSaveCategoryEntity.snack:
        return S.of(context).snackLabel;
      case RecipeSaveCategoryEntity.preWorkout:
        return S.of(context).quickCategoryPreWorkout;
      case RecipeSaveCategoryEntity.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case RecipeSaveCategoryEntity.shake:
        return S.of(context).quickCategoryShake;
    }
  }

  IconData _filterIcon(RecipeSaveCategoryEntity category) {
    switch (category) {
      case RecipeSaveCategoryEntity.breakfast:
        return IntakeTypeEntity.breakfast.getIconData();
      case RecipeSaveCategoryEntity.lunch:
        return IntakeTypeEntity.lunch.getIconData();
      case RecipeSaveCategoryEntity.dinner:
        return IntakeTypeEntity.dinner.getIconData();
      case RecipeSaveCategoryEntity.snack:
        return IntakeTypeEntity.snack.getIconData();
      case RecipeSaveCategoryEntity.preWorkout:
        return QuickRecipeCategoryEntity.preWorkout.icon;
      case RecipeSaveCategoryEntity.postWorkout:
        return QuickRecipeCategoryEntity.postWorkout.icon;
      case RecipeSaveCategoryEntity.shake:
        return QuickRecipeCategoryEntity.shake.icon;
    }
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _manualSectionTitle(BuildContext context) =>
      _isEs(context) ? 'Recetas guardadas' : 'Saved recipes';

  String _removeSavedLabel(BuildContext context) =>
      _isEs(context) ? 'Quitar guardada' : 'Remove saved';

  String _manualSectionSubtitle(BuildContext context) => _isEs(context)
      ? 'Se ordenan por pin y por uso reciente para que tengas primero las que más repites.'
      : 'They are ordered by pin and recent usage so the ones you repeat most stay first.';

  String _frequentSectionTitle(BuildContext context) =>
      _isEs(context) ? 'Sugeridas por repetición' : 'Repeated suggestions';

  String _frequentSectionSubtitle(BuildContext context) => _isEs(context)
      ? 'Se detectan desde tu historial para repetirlas más rápido.'
      : 'Detected from your history so you can repeat them faster.';

  String _frequentUses(BuildContext context, int count) =>
      _isEs(context) ? '$count usos' : '$count times';
}

enum _RecipeAction {
  edit,
  toggleSaved,
}

class RecipeLibraryScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  RecipeLibraryScreenArguments(this.day, this.intakeTypeEntity);
}

class _RecipeMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RecipeMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LibraryIntroCard extends StatelessWidget {
  const _LibraryIntroCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
        child: Text(
          isEs
              ? 'Filtra por bloque real, fija tus recetas clave y edítalas sin salir de la librería.'
              : 'Filter by real category, pin key recipes, and edit them directly from the library.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _LibrarySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LibrarySectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
