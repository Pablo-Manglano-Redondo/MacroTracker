import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';

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
    final args = ModalRoute.of(context)?.settings.arguments
        as RecipeLibraryScreenArguments?;
    _day = args?.day ?? DateTime.now();
    _intakeTypeEntity = args?.intakeTypeEntity ?? IntakeTypeEntity.breakfast;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved meals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                hintText: 'Search saved meals',
                border: OutlineInputBorder(),
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

                final recipes = _filterRecipes(snapshot.data ?? const <RecipeEntity>[]);
                if (recipes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No saved meals yet.\nSave meals as recipes to reuse them here.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: recipes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Text(
                          '${recipe.ingredients.length} ingredients | ${recipe.defaultServings.toStringAsFixed(recipe.defaultServings % 1 == 0 ? 0 : 1)} servings'),
                      trailing: recipe.favorite
                          ? const Icon(Icons.favorite, color: Colors.redAccent)
                          : null,
                      onTap: () => _showAddRecipeDialog(recipe),
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

  Future<void> _showAddRecipeDialog(RecipeEntity recipe) async {
    final controller = TextEditingController(text: '1');
    final confirmed = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(recipe.name),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Servings',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                    double.tryParse(controller.text.replaceAll(',', '.')) ?? 1);
              },
              child: const Text('Add'),
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
        SnackBar(content: Text('${recipe.name} added')),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    }
  }
}

class RecipeLibraryScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  RecipeLibraryScreenArguments(this.day, this.intakeTypeEntity);
}
