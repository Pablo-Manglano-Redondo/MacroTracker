import 'package:flutter/material.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/core/presentation/widgets/copy_dialog.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';

class MacroSuggestionsCard extends StatelessWidget {
  final double remainingKcal;
  final double remainingCarbs;
  final double remainingFat;
  final double remainingProtein;

  const MacroSuggestionsCard({
    super.key,
    required this.remainingKcal,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.remainingProtein,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldHideCard()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<MacroSuggestionEntity>>(
            future: locator<GenerateMacroSuggestionsUsecase>().generate(
              remainingKcal: remainingKcal,
              remainingCarbs: remainingCarbs,
              remainingFat: remainingFat,
              remainingProtein: remainingProtein,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 88,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final suggestions = snapshot.data ?? const <MacroSuggestionEntity>[];
              if (suggestions.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ideas for the rest of your day',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Save a few meals as recipes to get quick suggestions here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ideas for the rest of your day',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4.0),
                  Text(
                    'Based on your remaining calories and macros.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12.0),
                  ...suggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _SuggestionTile(
                          suggestion: suggestion,
                          onAddPressed: () =>
                              _logSuggestion(context, suggestion),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _shouldHideCard() {
    return remainingKcal <= 120 &&
        remainingProtein <= 10 &&
        remainingCarbs <= 15 &&
        remainingFat <= 7;
  }

  Future<void> _logSuggestion(
      BuildContext context, MacroSuggestionEntity suggestion) async {
    final mealType = await showDialog<AddMealType>(
        context: context, builder: (_) => const CopyDialog());
    if (mealType == null) {
      return;
    }

    await locator<LogRecipeUsecase>().logRecipe(
      suggestion.recipe,
      suggestion.suggestedServings,
      mealType.getIntakeType(),
      DateTime.now(),
    );
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${suggestion.recipe.name} added')),
      );
    }
  }
}

class _SuggestionTile extends StatelessWidget {
  final MacroSuggestionEntity suggestion;
  final VoidCallback onAddPressed;

  const _SuggestionTile({
    required this.suggestion,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.recipe.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: onAddPressed,
                child: const Text('Add'),
              ),
            ],
          ),
          Text(
            '${_formatServings(suggestion.suggestedServings)} servings | ${suggestion.predictedKcal.toStringAsFixed(0)} kcal | P ${suggestion.predictedProtein.toStringAsFixed(1)}g',
          ),
          const SizedBox(height: 4.0),
          Text(
            suggestion.rationale,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatServings(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }
}
