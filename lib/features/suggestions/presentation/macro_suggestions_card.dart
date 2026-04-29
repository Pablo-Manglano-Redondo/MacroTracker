import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class MacroSuggestionsCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final UserWeightGoalEntity nutritionPhase;
  final double remainingKcal;
  final double remainingCarbs;
  final double remainingFat;
  final double remainingProtein;

  const MacroSuggestionsCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.dailyFocus,
    required this.nutritionPhase,
    required this.remainingKcal,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.remainingProtein,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldHideCard()) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<MacroSuggestionEntity>>(
            future: locator<GenerateMacroSuggestionsUsecase>().generate(
              dailyFocus: dailyFocus,
              nutritionPhase: nutritionPhase,
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

              final suggestions =
                  snapshot.data ?? const <MacroSuggestionEntity>[];
              if (suggestions.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title(context),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(
                      S.of(context).macroSuggestionsEmpty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text(_title(context),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4.0),
                    Text(
                      _subtitle(context),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  ...suggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
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
    await locator<LogRecipeUsecase>().logRecipe(
      suggestion.recipe,
      suggestion.suggestedServings,
      suggestion.recommendedIntakeType,
      DateTime.now(),
    );
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).macroSuggestionsAddedTo(
                  suggestion.recipe.name,
                  _slotLabel(context, suggestion.recommendedIntakeType),
                ),
          ),
        ),
      );
    }
  }

  String _title(BuildContext context) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return S.of(context).macroSuggestionsTitleDef;
    }
    if (dailyFocus == DailyFocusEntity.lowerBody) {
      return S.of(context).macroSuggestionsTitleLeg;
    }
    if (dailyFocus == DailyFocusEntity.upperBody) {
      return S.of(context).macroSuggestionsTitleTorso;
    }
    if (dailyFocus == DailyFocusEntity.cardio) {
      return S.of(context).macroSuggestionsTitleCardio;
    }
    return S.of(context).macroSuggestionsTitleRest;
  }

  String _subtitle(BuildContext context) {
    if (dailyFocus == DailyFocusEntity.lowerBody ||
        dailyFocus == DailyFocusEntity.upperBody) {
      return S.of(context).macroSuggestionsSubtitleGym;
    }
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return S.of(context).macroSuggestionsSubtitleLoseWeight;
    }
    if (dailyFocus == DailyFocusEntity.rest) {
      return S.of(context).macroSuggestionsSubtitleRest;
    }
    return S.of(context).macroSuggestionsSubtitleDefault;
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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
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
              TextButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 16),
                label: Text(S.of(context).addLabel),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: suggestion.category.icon,
                label: suggestion.category.label,
              ),
              _MetaChip(
                icon: _slotIcon(suggestion.recommendedIntakeType),
                label: _slotText(context, suggestion.recommendedIntakeType),
              ),
              _MetaChip(
                icon: Icons.local_fire_department_outlined,
                label: '${suggestion.predictedKcal.toStringAsFixed(0)} kcal',
              ),
              _MetaChip(
                icon: Icons.egg_alt_outlined,
                label: 'P ${suggestion.predictedProtein.toStringAsFixed(1)}',
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            '${S.of(context).macroSuggestionsServingsPortions(_formatServings(suggestion.suggestedServings))} | C ${suggestion.predictedCarbs.toStringAsFixed(1)} | F ${suggestion.predictedFat.toStringAsFixed(1)} | P ${suggestion.predictedProtein.toStringAsFixed(1)}',
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

  String _slotText(BuildContext context, IntakeTypeEntity intakeType) {
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

  IconData _slotIcon(IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return Icons.bakery_dining_outlined;
      case IntakeTypeEntity.lunch:
        return Icons.lunch_dining_outlined;
      case IntakeTypeEntity.dinner:
        return Icons.dinner_dining_outlined;
      case IntakeTypeEntity.snack:
        return Icons.fastfood_outlined;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
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
