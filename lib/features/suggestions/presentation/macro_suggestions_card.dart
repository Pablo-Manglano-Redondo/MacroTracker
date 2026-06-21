import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_editor_screen.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/presentation/widgets/recipe_detail_bottom_sheet.dart';

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
      await locator<ConversionAnalyticsService>().logEvent(
        'macro_coach_locked_viewed',
        parameters: _macroContextParameters(),
      );
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
      languageCode: PlatformDispatcher.instance.locale.languageCode,
    );
    return _MacroCoachState(isPremium: true, suggestions: suggestions);
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldHideCard()) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.22)
        : const Color(0xFFE5E7EB);

    return Padding(
      padding: widget.padding,
      child: Card(
        elevation: 0.0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: borderColor,
          ),
        ),
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
                  title: _title(context),
                  subtitle: _subtitle(context),
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
    await locator<ConversionAnalyticsService>().logEvent(
      'macro_coach_paywall_opened',
      parameters: _macroContextParameters(),
    );
    if (!context.mounted) {
      return;
    }
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
    await locator<ConversionAnalyticsService>().logEvent(
      'macro_coach_suggestion_logged',
      parameters: {
        ..._macroContextParameters(),
        'recipe_id': suggestion.recipe.id,
        'intake_type': suggestion.recommendedIntakeType.name,
        'servings': suggestion.suggestedServings,
      },
    );

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
    if (widget.nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return S.of(context).macroCoachTitleCut;
    }
    if (widget.dailyFocus == DailyFocusEntity.lowerBody) {
      return S.of(context).macroCoachTitleLeg;
    }
    if (widget.dailyFocus == DailyFocusEntity.upperBody) {
      return S.of(context).macroCoachTitleUpper;
    }
    if (widget.dailyFocus == DailyFocusEntity.cardio) {
      return S.of(context).macroCoachTitleCardio;
    }
    return S.of(context).macroCoachTitleToday;
  }

  String _subtitle(BuildContext context) {
    if (widget.dailyFocus == DailyFocusEntity.lowerBody ||
        widget.dailyFocus == DailyFocusEntity.upperBody) {
      return S.of(context).macroCoachSubtitleTraining;
    }
    if (widget.nutritionPhase == UserWeightGoalEntity.loseWeight) {
      return S.of(context).macroCoachSubtitleCut;
    }
    if (widget.dailyFocus == DailyFocusEntity.rest) {
      return S.of(context).macroCoachSubtitleRest;
    }
    return S.of(context).macroCoachSubtitleDefault;
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

  Map<String, Object> _macroContextParameters() {
    return {
      'daily_focus': widget.dailyFocus.name,
      'nutrition_phase': widget.nutritionPhase.name,
      'remaining_kcal': widget.remainingKcal.round(),
      'remaining_carbs': widget.remainingCarbs.round(),
      'remaining_fat': widget.remainingFat.round(),
      'remaining_protein': widget.remainingProtein.round(),
    };
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
  final String title;
  final String subtitle;
  final double remainingKcal;
  final double remainingCarbs;
  final double remainingFat;
  final double remainingProtein;
  final VoidCallback onUpgrade;

  const _LockedMacroCoach({
    required this.title,
    required this.subtitle,
    required this.remainingKcal,
    required this.remainingCarbs,
    required this.remainingFat,
    required this.remainingProtein,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.lock_person_outlined,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
              iconColor: const Color(0xFFEF4444),
              label: '${remainingKcal.clamp(0, double.infinity).round()} kcal',
            ),
            _MacroGapChip(
              dotColor: const Color(0xFF10B981),
              label: 'P ${remainingProtein.clamp(0, double.infinity).round()}g',
            ),
            _MacroGapChip(
              dotColor: const Color(0xFFE7A83B),
              label: 'C ${remainingCarbs.clamp(0, double.infinity).round()}g',
            ),
            _MacroGapChip(
              dotColor: const Color(0xFF3B82F6),
              label: 'F ${remainingFat.clamp(0, double.infinity).round()}g',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            // Blurred mock recommendations list
            Column(
              children: [
                _BlurredSuggestionRow(
                  title: S.of(context).macroCoachPreviewChicken,
                  category: S.of(context).lunchLabel,
                  kcal: '540 kcal',
                  protein: 'P 42g',
                ),
                _BlurredSuggestionRow(
                  title: S.of(context).macroCoachPreviewOmelette,
                  category: S.of(context).dinnerLabel,
                  kcal: '380 kcal',
                  protein: 'P 34g',
                ),
              ],
            ),
            // Lock overlay with call-to-action
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cardBg.withValues(alpha: 0.0),
                      cardBg.withValues(alpha: 0.6),
                      cardBg,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1F)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).macroCoachLockedTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).macroCoachLockedSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: onUpgrade,
                      icon: const Icon(Icons.lock_open_outlined, size: 16),
                      label: Text(
                        S.of(context).macroCoachUnlockAction,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BlurredSuggestionRow extends StatelessWidget {
  final String title;
  final String category;
  final String kcal;
  final String protein;

  const _BlurredSuggestionRow({
    required this.title,
    required this.category,
    required this.kcal,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '|   $kcal   |   $protein',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroGapChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final IconData? icon;
  final Color? iconColor;

  const _MacroGapChip({
    required this.label,
    this.dotColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final macroColor = iconColor ?? dotColor ?? colorScheme.primary;

    final Color bgColor = isDark
        ? macroColor.withValues(alpha: 0.08)
        : macroColor.withValues(alpha: 0.06);
    final Border border = Border.all(
      color: macroColor.withValues(alpha: isDark ? 0.20 : 0.15),
      width: 1.0,
    );
    final Color textColor = isDark
        ? Color.lerp(macroColor, Colors.white, 0.25) ?? macroColor
        : Color.lerp(macroColor, Colors.black, 0.2) ?? macroColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bgColor,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: textColor)
          else if (dotColor != null)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
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
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.45),
        ),
      ),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.35),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (sheetContext) => RecipeDetailBottomSheet(
              recipe: suggestion.recipe,
              category: suggestion.category,
              intakeType: suggestion.recommendedIntakeType,
              servings: suggestion.suggestedServings,
              kcal: suggestion.predictedKcal,
              carbs: suggestion.predictedCarbs,
              fat: suggestion.predictedFat,
              protein: suggestion.predictedProtein,
              rationale: suggestion.rationale,
              isCoachSuggestion: true,
              onLogPressed: () {
                Navigator.of(sheetContext).pop();
                onAddPressed();
              },
              onEditPressed: () async {
                Navigator.of(sheetContext).pop();
                final didSave = await Navigator.of(context).pushNamed(
                  NavigationOptions.recipeEditorRoute,
                  arguments: RecipeEditorScreenArguments(suggestion.recipe),
                );
                if (didSave == true) {
                  locator<HomeBloc>().add(const LoadItemsEvent());
                }
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.recipe.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
        ),
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
