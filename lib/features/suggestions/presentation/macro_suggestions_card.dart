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
                    Text(_title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(
                      'Guarda algunas recetas y esta sección empezará a sugerirte según tu día de entrenamiento.',
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
                            Text(_title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4.0),
                            Text(
                              _subtitle,
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
            '${suggestion.recipe.name} añadida a ${_slotLabel(suggestion.recommendedIntakeType)}',
          ),
        ),
      );
    }
  }

  String get _title {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return 'Opciones para definición';
    }
    if (dailyFocus == DailyFocusEntity.lowerBody) {
      return 'Opciones para pierna';
    }
    if (dailyFocus == DailyFocusEntity.upperBody) {
      return 'Opciones para torso';
    }
    if (dailyFocus == DailyFocusEntity.cardio) {
      return 'Opciones para cardio';
    }
    return 'Opciones para descanso';
  }

  String get _subtitle {
    if (dailyFocus == DailyFocusEntity.lowerBody ||
        dailyFocus == DailyFocusEntity.upperBody) {
      return 'Comidas recomendadas para rendir y recuperar mejor.';
    }
    if (nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return 'Opciones altas en proteína con calorías controladas.';
    }
    if (dailyFocus == DailyFocusEntity.rest) {
      return 'Cierres limpios con proteína alta y sin exceso calórico.';
    }
    return 'Comidas guardadas según lo que aún te falta hoy.';
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
                label: const Text('Añadir'),
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
                label: _slotText(suggestion.recommendedIntakeType),
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
            '${_formatServings(suggestion.suggestedServings)} porciones | C ${suggestion.predictedCarbs.toStringAsFixed(1)} | F ${suggestion.predictedFat.toStringAsFixed(1)} | P ${suggestion.predictedProtein.toStringAsFixed(1)}',
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

  String _slotText(IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return 'Desayuno';
      case IntakeTypeEntity.lunch:
        return 'Comida';
      case IntakeTypeEntity.dinner:
        return 'Cena';
      case IntakeTypeEntity.snack:
        return 'Snack';
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
