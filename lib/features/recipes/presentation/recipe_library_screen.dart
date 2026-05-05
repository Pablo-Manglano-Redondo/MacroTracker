import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/generated/l10n.dart';
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
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_favorite_usecase.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  late DateTime _day;
  late IntakeTypeEntity _intakeTypeEntity;
  final _searchController = TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).recipeLibraryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
    if (query.isEmpty) {
      return recipes;
    }

    return recipes
        .where((recipe) => recipe.name.toLowerCase().contains(query))
        .toList();
  }

  List<FrequentIntakePresetEntity> _filterFrequentPresets(
    List<FrequentIntakePresetEntity> presets,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return presets;
    }

    return presets
        .where((preset) => preset.title.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildRecipeTile(RecipeEntity recipe) {
    final category = QuickRecipeCategoryEntityX.inferFromRecipe(recipe);
    return ListTile(
      title: Text(recipe.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${S.of(context).recipeLibraryIngredientsCount(recipe.ingredients.length)} | ${S.of(context).recipeLibraryServingsCount(recipe.defaultServings % 1 == 0 ? recipe.defaultServings.toInt() : recipe.defaultServings)}',
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RecipeMetaChip(
                icon: category.icon,
                label: _categoryLabel(category),
              ),
              if (recipe.favorite)
                _RecipeMetaChip(
                  icon: Icons.favorite,
                  label: S.of(context).recipeLibraryFavorite,
                ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _toggleFavorite(recipe),
        icon: Icon(
          recipe.favorite ? Icons.favorite : Icons.favorite_border_outlined,
          color: recipe.favorite ? Colors.redAccent : null,
        ),
        tooltip: recipe.favorite
            ? S.of(context).recipeLibraryRemoveFavorite
            : S.of(context).recipeLibraryMarkFavorite,
      ),
      onTap: () => _showAddRecipeDialog(recipe),
    );
  }

  Widget _buildFrequentTile(FrequentIntakePresetEntity preset) {
    final amountText = preset.amount.toStringAsFixed(
      preset.amount % 1 == 0 ? 0 : 1,
    );
    return ListTile(
      title: Text(preset.title),
      subtitle: Text(
        '$amountText ${preset.unit} | ${_frequentUses(context, preset.uses)}',
      ),
      leading: const Icon(Icons.history_outlined),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: () => _logFrequentPreset(preset),
    );
  }

  Future<void> _showAddRecipeDialog(RecipeEntity recipe) async {
    final controller = TextEditingController(text: '1');
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
            content:
                Text(S.of(context).recipeLibraryAddedSnackbar(recipe.name))),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    }
  }

  Future<void> _toggleFavorite(RecipeEntity recipe) async {
    await locator<SetRecipeFavoriteUsecase>()
        .setFavorite(recipe.id, !recipe.favorite);
    if (mounted) {
      setState(() {});
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
            content:
                Text(S.of(context).recipeLibraryAddedSnackbar(preset.title))),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    }
  }

  String _categoryLabel(QuickRecipeCategoryEntity category) {
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

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _manualSectionTitle(BuildContext context) =>
      _isEs(context) ? 'Recetas guardadas' : 'Saved recipes';

  String _manualSectionSubtitle(BuildContext context) => _isEs(context)
      ? 'Las guardas a propósito para reutilizarlas cuando quieras.'
      : 'You save these on purpose to reuse them whenever you want.';

  String _frequentSectionTitle(BuildContext context) =>
      _isEs(context) ? 'Sugeridas por repetición' : 'Repeated suggestions';

  String _frequentSectionSubtitle(BuildContext context) => _isEs(context)
      ? 'Se detectan desde tu historial para repetirlas más rápido.'
      : 'Detected from your history so you can repeat them faster.';

  String _frequentUses(BuildContext context, int count) =>
      _isEs(context) ? '$count usos' : '$count times';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
        child: Text(
          _isEs(context)
              ? 'Una sola librería, dos fuentes: recetas que guardas a mano y comidas repetidas detectadas automáticamente.'
              : 'One library, two sources: meals you save manually and repeated meals detected automatically.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
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
