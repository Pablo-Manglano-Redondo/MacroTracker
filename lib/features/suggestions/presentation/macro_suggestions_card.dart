import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class MacroSuggestionsCard extends StatefulWidget {
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
  State<MacroSuggestionsCard> createState() => _MacroSuggestionsCardState();
}

class _MacroSuggestionsCardState extends State<MacroSuggestionsCard> {
  late Future<_MacroCoachState> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadState();
  }

  @override
  void didUpdateWidget(covariant MacroSuggestionsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyFocus != widget.dailyFocus ||
        oldWidget.nutritionPhase != widget.nutritionPhase ||
        oldWidget.remainingKcal != widget.remainingKcal ||
        oldWidget.remainingCarbs != widget.remainingCarbs ||
        oldWidget.remainingFat != widget.remainingFat ||
        oldWidget.remainingProtein != widget.remainingProtein) {
      _future = _loadState();
    }
  }

  Future<_MacroCoachState> _loadState() async {
    final trialState = await locator<MonetizationService>().getAiTrialState();
    if (!trialState.isPremium) {
      return _MacroCoachState(
        isPremium: false,
        suggestions: const <MacroSuggestionEntity>[],
      );
    }

    final suggestions =
        await locator<GenerateMacroSuggestionsUsecase>().generate(
      dailyFocus: widget.dailyFocus,
      nutritionPhase: widget.nutritionPhase,
      remainingKcal: widget.remainingKcal,
      remainingCarbs: widget.remainingCarbs,
      remainingFat: widget.remainingFat,
      remainingProtein: widget.remainingProtein,
    );
    return _MacroCoachState(isPremium: true, suggestions: suggestions);
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldHideCard()) return const SizedBox.shrink();

    return Padding(
      padding: widget.padding,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<_MacroCoachState>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 88,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final state = snapshot.data ??
                  const _MacroCoachState(
                    isPremium: false,
                    suggestions: <MacroSuggestionEntity>[],
                  );
              if (!state.isPremium) {
                return _LockedMacroCoach(
                  remainingKcal: widget.remainingKcal,
                  remainingCarbs: widget.remainingCarbs,
                  remainingFat: widget.remainingFat,
                  remainingProtein: widget.remainingProtein,
                  onUpgrade: () => _openPaywall(context),
                );
              }

              final suggestions = state.suggestions;
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
                          Icons.psychology_alt_outlined,
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
    return widget.remainingKcal <= 120 &&
        widget.remainingProtein <= 10 &&
        widget.remainingCarbs <= 15 &&
        widget.remainingFat <= 7;
  }

  Future<void> _openPaywall(BuildContext context) async {
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PaywallSheet(
        placement: PaywallPlacement.macroCoach,
      ),
    );
    if (purchased == true && mounted) {
      setState(() => _future = _loadState());
    }
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (widget.nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return isEs ? 'Coach de macros para definir' : 'Cut-focused Macro Coach';
    }
    if (widget.dailyFocus == DailyFocusEntity.lowerBody) {
      return isEs ? 'Coach para pierna hoy' : 'Leg day Macro Coach';
    }
    if (widget.dailyFocus == DailyFocusEntity.upperBody) {
      return isEs ? 'Coach para torso hoy' : 'Upper day Macro Coach';
    }
    if (widget.dailyFocus == DailyFocusEntity.cardio) {
      return isEs ? 'Coach para cardio hoy' : 'Cardio day Macro Coach';
    }
    return isEs ? 'Coach de macros para hoy' : 'Today Macro Coach';
  }

  String _subtitle(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    if (widget.dailyFocus == DailyFocusEntity.lowerBody ||
        widget.dailyFocus == DailyFocusEntity.upperBody) {
      return isEs
          ? 'Premium ajusta comidas reales a tu entrenamiento y macros restantes.'
          : 'Premium adjusts real meals to your workout and remaining macros.';
    }
    if (widget.nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return isEs
          ? 'Cierra el dia con proteina alta y calorias controladas.'
          : 'Close the day with high protein and controlled calories.';
    }
    if (widget.dailyFocus == DailyFocusEntity.rest) {
      return isEs
          ? 'Opciones ligeras para mantener adherencia sin pasarte.'
          : 'Light options to keep adherence without overshooting.';
    }
    return isEs
        ? 'Elige que comer ahora segun lo que te falta hoy.'
        : 'Choose what to eat now based on what is left today.';
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

class _MacroCoachState {
  final bool isPremium;
  final List<MacroSuggestionEntity> suggestions;

  const _MacroCoachState({
    required this.isPremium,
    required this.suggestions,
  });
}

class _LockedMacroCoach extends StatelessWidget {
  final double remainingKcal;
  final double remainingCarbs;
  final double remainingFat;
  final double remainingProtein;
  final VoidCallback onUpgrade;

  const _LockedMacroCoach({
    required this.remainingKcal,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.remainingProtein,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.lock_outline,
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
                    isEs ? 'Coach de macros para hoy' : 'Today Macro Coach',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEs
                        ? 'Gratis ves lo que te falta. Premium te dice que comer, cuanto y donde registrarlo.'
                        : 'Free shows what is left. Premium tells you what to eat, how much, and where to log it.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MacroGapChip(
              icon: Icons.local_fire_department_outlined,
              label: '${remainingKcal.clamp(0, double.infinity).round()} kcal',
            ),
            _MacroGapChip(
              icon: Icons.egg_alt_outlined,
              label: 'P ${remainingProtein.clamp(0, double.infinity).round()}g',
            ),
            _MacroGapChip(
              icon: Icons.grain_outlined,
              label: 'C ${remainingCarbs.clamp(0, double.infinity).round()}g',
            ),
            _MacroGapChip(
              icon: Icons.water_drop_outlined,
              label: 'F ${remainingFat.clamp(0, double.infinity).round()}g',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEs
                      ? '3 recomendaciones listas con cantidades ajustadas a tus macros restantes.'
                      : '3 recommendations ready with servings adjusted to your remaining macros.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onUpgrade,
          icon: const Icon(Icons.workspace_premium_outlined, size: 18),
          label: Text(isEs ? 'Desbloquear Coach' : 'Unlock Coach'),
        ),
      ],
    );
  }
}

class _MacroGapChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MacroGapChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
          Icon(icon, size: 13),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
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
