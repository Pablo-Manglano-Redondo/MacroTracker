import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_recipe_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';

// Usecase & Entity Imports for 1-Tap Logging
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';

class PlanTab extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;

  const PlanTab({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final plan = summary.activePlan;
    final colorScheme = Theme.of(context).colorScheme;
    if (plan == null) {
      return _EmptyPlanCard(summary: summary);
    }
    final fallbackDays = summary.weekPlan.where((day) => day.usesWeekdayFallback).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          accent: Color.alphaBlend(
            colorScheme.secondary.withValues(alpha: 0.10),
            colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Plan activo', en: 'Active plan'),
                title: plan.name,
                subtitle: plan.objective.isEmpty
                    ? uiText(
                        context,
                        es: 'Tu profesional ha preparado esta estructura para guiar tu semana.',
                        en: 'Your professional prepared this structure to guide your week.',
                      )
                    : plan.objective,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CompactStat(
                    label: uiText(context, es: 'Comidas sugeridas', en: 'Suggested meals'),
                    value: plan.meals.length.toString(),
                  ),
                  CompactStat(
                    label: uiText(context, es: 'Días plantilla', en: 'Template days'),
                    value: fallbackDays.toString(),
                  ),
                  CompactStat(
                    label: uiText(context, es: 'Actualizado', en: 'Updated'),
                    value: formatShortDate(context, plan.updatedAt ?? plan.createdAt),
                  ),
                ],
              ),
              if (plan.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.surfaceContainerLow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          plan.notes!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Visión semanal', en: 'Weekly view'),
                title: S.of(context).professionalPlanWeeklyView,
                subtitle: uiText(
                  context,
                  es: 'Toca un día para abrir su desglose calórico detallado y registrar sus comidas.',
                  en: 'Tap a day to view its detailed caloric breakdown and log its meals.',
                ),
              ),
              const SizedBox(height: 14),
              for (final day in summary.weekPlan)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WeekPlanRow(
                    day: day,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (sheetContext) => WeekdayDetailBottomSheet(
                          day: day,
                          meals: plan.meals,
                          onLogMeal: (meal) => _handleLogSuggestedMeal(context, meal),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (plan.meals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  eyebrow: uiText(context, es: 'Guía de comidas', en: 'Meal guide'),
                  title: S.of(context).professionalPlanSuggestedMeals,
                  subtitle: uiText(
                    context,
                    es: 'Toca una comida para ver su desglose de macronutrientes, o usa "+" para añadirla a tu diario de hoy.',
                    en: 'Tap a meal to view its macronutrient breakdown, or use "+" to add it to today\'s diary.',
                  ),
                ),
                const SizedBox(height: 14),
                for (final meal in plan.meals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SuggestedMealRow(
                      meal: meal,
                      onLogMeal: () => _handleLogSuggestedMeal(context, meal),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) => SuggestedMealDetailBottomSheet(
                            meal: meal,
                            onLogPressed: () => _handleLogSuggestedMeal(context, meal),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleLogSuggestedMeal(BuildContext context, NutritionPlanMealEntity suggestedMeal) async {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final slotName = _slotDisplayName(context, suggestedMeal.slot);
    final kcal = suggestedMeal.kcal?.round() ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEs ? '¿Registrar comida sugerida?' : 'Log suggested meal?'),
        content: Text(
          isEs
              ? '¿Deseas añadir "${suggestedMeal.title}" ($kcal kcal) a tu diario de hoy en la sección de "$slotName"?'
              : 'Do you want to add "${suggestedMeal.title}" ($kcal kcal) to today\'s diary under "$slotName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isEs ? 'Registrar' : 'Log Meal'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final addIntakeUseCase = locator<AddIntakeUsecase>();
      final addTrackedDayUsecase = locator<AddTrackedDayUsecase>();
      final getGymTargetsUsecase = locator<GetGymTargetsUsecase>();
      
      final today = DateTime.now();
      final type = _parseSlotToType(suggestedMeal.slot);
      
      final carbs = suggestedMeal.carbs ?? 0;
      final fat = suggestedMeal.fat ?? 0;
      final protein = suggestedMeal.protein ?? 0;

      // MealNutrimentsEntity contains per 100g. Since amount = 1.0 (serving), set per100 as total * 100
      final nutriments = MealNutrimentsEntity(
        energyKcal100: kcal.toDouble() * 100,
        carbohydrates100: carbs * 100,
        fat100: fat * 100,
        proteins100: protein * 100,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      );

      final meal = MealEntity(
        code: IdGenerator.getUniqueID(),
        name: suggestedMeal.title,
        brands: null,
        thumbnailImageUrl: null,
        mainImageUrl: null,
        url: null,
        mealQuantity: '1',
        mealUnit: 'serving',
        servingQuantity: 1.0,
        servingUnit: 'serving',
        servingSize: '1 serving',
        nutriments: nutriments,
        source: MealSourceEntity.custom,
      );

      final intake = IntakeEntity(
        id: IdGenerator.getUniqueID(),
        unit: 'serving',
        amount: 1.0,
        type: type,
        meal: meal,
        dateTime: today,
      );

      // Save to databases
      await addIntakeUseCase.addIntake(intake);

      final hasTrackedDay = await addTrackedDayUsecase.hasTrackedDay(today);
      if (!hasTrackedDay) {
        final targets = await getGymTargetsUsecase.getTargetsForDay(today);
        await addTrackedDayUsecase.addNewTrackedDay(
          today,
          targets.kcalGoal,
          targets.carbsGoal,
          targets.fatGoal,
          targets.proteinGoal,
        );
      }

      await addTrackedDayUsecase.addDayCaloriesTracked(today, intake.totalKcal);
      await addTrackedDayUsecase.addDayMacrosTracked(
        today,
        carbsTracked: intake.totalCarbsGram,
        fatTracked: intake.totalFatsGram,
        proteinTracked: intake.totalProteinsGram,
      );

      // Trigger Bloc Refreshes
      locator<HomeBloc>().add(const LoadItemsEvent(
        refreshRemotePlan: false,
        uploadProfessionalSnapshot: true,
      ));
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEs
                  ? '"${suggestedMeal.title}" registrada con éxito.'
                  : '"${suggestedMeal.title}" logged successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEs
                  ? 'Error al registrar la comida.'
                  : 'Error logging the meal.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  IntakeTypeEntity _parseSlotToType(String slot) {
    final clean = slot.trim().toLowerCase();
    switch (clean) {
      case 'breakfast':
      case 'desayuno':
        return IntakeTypeEntity.breakfast;
      case 'lunch':
      case 'comida':
      case 'almuerzo':
        return IntakeTypeEntity.lunch;
      case 'dinner':
      case 'cena':
        return IntakeTypeEntity.dinner;
      case 'snack':
      case 'merienda':
      case 'tentempié':
      case 'tentempie':
        return IntakeTypeEntity.snack;
      default:
        return IntakeTypeEntity.snack;
    }
  }

  String _slotDisplayName(BuildContext context, String slot) {
    final clean = slot.trim().toLowerCase();
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (clean) {
      case 'breakfast':
      case 'desayuno':
        return isEs ? 'Desayuno' : 'Breakfast';
      case 'lunch':
      case 'comida':
      case 'almuerzo':
        return isEs ? 'Comida' : 'Lunch';
      case 'dinner':
      case 'cena':
        return isEs ? 'Cena' : 'Dinner';
      case 'snack':
      case 'merienda':
      case 'tentempié':
      case 'tentempie':
        return isEs ? 'Merienda/Snack' : 'Snack';
      default:
        return slot;
    }
  }
}

class _WeekPlanRow extends StatelessWidget {
  final NutritionPlanResolvedDayEntity day;
  final VoidCallback onTap;

  const _WeekPlanRow({
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final target = day.target;
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: day.isToday
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: day.isToday
                ? colorScheme.primary.withValues(alpha: 0.18)
                : colorScheme.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatWeekday(context, day.effectiveDate),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                if (day.isToday)
                  StatusPill(
                    icon: Icons.today_outlined,
                    label: uiText(context, es: 'Hoy', en: 'Today'),
                  ),
                if (day.usesWeekdayFallback) ...[
                  const SizedBox(width: 8),
                  StatusPill(
                    icon: Icons.auto_awesome_motion_outlined,
                    label: S.of(context).professionalWeekTemplate,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              target == null
                  ? S.of(context).professionalWeekNoTarget
                  : '${target.kcalGoal.round()} kcal | ${target.proteinGoal.round()}P | ${target.carbsGoal.round()}C | ${target.fatGoal.round()}F',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedMealRow extends StatelessWidget {
  final NutritionPlanMealEntity meal;
  final VoidCallback onLogMeal;
  final VoidCallback onTap;

  const _SuggestedMealRow({
    required this.meal,
    required this.onLogMeal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final slotLabel = _slotDisplayName(context, meal.slot);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              slotLabel,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (meal.kcal != null) ...[
                        const SizedBox(width: 8),
                        StatusPill(
                          icon: Icons.local_fire_department_outlined,
                          label: '${meal.kcal!.round()} kcal',
                        ),
                      ],
                    ],
                  ),
                  if (meal.protein != null || meal.carbs != null || meal.fat != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${meal.protein?.round() ?? 0}g P | ${meal.carbs?.round() ?? 0}g C | ${meal.fat?.round() ?? 0}g F',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                  if (meal.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      meal.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.35,
                          ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onLogMeal,
                      icon: const Icon(Icons.playlist_add_rounded, size: 20),
                      label: Text(
                        isEs ? 'Registrar en Diario' : 'Log to Diary',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _slotDisplayName(BuildContext context, String slot) {
    final clean = slot.trim().toLowerCase();
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (clean) {
      case 'breakfast':
      case 'desayuno':
        return isEs ? 'Desayuno' : 'Breakfast';
      case 'lunch':
      case 'comida':
      case 'almuerzo':
        return isEs ? 'Comida' : 'Lunch';
      case 'dinner':
      case 'cena':
        return isEs ? 'Cena' : 'Dinner';
      case 'snack':
      case 'merienda':
      case 'tentempié':
      case 'tentempie':
        return isEs ? 'Merienda/Snack' : 'Snack';
      default:
        return slot;
    }
  }
}

class _EmptyPlanCard extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;

  const _EmptyPlanCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      accent: Color.alphaBlend(
        colorScheme.secondary.withValues(alpha: 0.08),
        colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: uiText(context, es: 'Sin plan publicado', en: 'No published plan'),
            title: S.of(context).professionalConnectedNoPlan,
            subtitle: S.of(context).professionalEmptyPlanBody,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusPill(
                icon: Icons.schedule_outlined,
                label: S.of(context).professionalEmptyPlanSync(
                  formatDateTime(context, summary.syncStatus.lastPlanSyncAt),
                ),
              ),
              StatusPill(
                icon: Icons.link_outlined,
                label: summary.connection.professionalName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Interactive Sheets and Details Helpers
// -------------------------------------------------------------

class SuggestedMealDetailBottomSheet extends StatelessWidget {
  final NutritionPlanMealEntity meal;
  final VoidCallback onLogPressed;

  const SuggestedMealDetailBottomSheet({
    super.key,
    required this.meal,
    required this.onLogPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    final kcal = meal.kcal ?? 0;
    final protein = meal.protein ?? 0;
    final carbs = meal.carbs ?? 0;
    final fat = meal.fat ?? 0;

    final totalMacroKcal = (protein * 4) + (carbs * 4) + (fat * 9);
    final pPct = totalMacroKcal <= 0 ? 0 : ((protein * 4) / totalMacroKcal * 100).round();
    final cPct = totalMacroKcal <= 0 ? 0 : ((carbs * 4) / totalMacroKcal * 100).round();
    final fPct = totalMacroKcal <= 0 ? 0 : ((fat * 9) / totalMacroKcal * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEs ? 'Comida sugerida del plan' : 'Suggested plan meal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MacroPanel(
                      label: isEs ? 'Calorías' : 'Calories',
                      value: '${kcal.round()} kcal',
                      color: const Color(0xFFEF4444),
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroPanel(
                      label: isEs ? 'Proteína' : 'Protein',
                      value: '${protein.round()} g',
                      color: const Color(0xFF10B981),
                      icon: Icons.egg_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroPanel(
                      label: isEs ? 'Carb.' : 'Carbs',
                      value: '${carbs.round()} g',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.cookie_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroPanel(
                      label: isEs ? 'Grasa' : 'Fat',
                      value: '${fat.round()} g',
                      color: const Color(0xFF3B82F6),
                      icon: Icons.opacity_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Caloric distribution percentages row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerLow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEs ? 'Aporte de Energía de Macros' : 'Macronutrient Energy Split',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _PctPill(label: isEs ? 'Proteína' : 'Protein', pct: pPct, color: const Color(0xFF10B981)),
                        _PctPill(label: isEs ? 'Carbos' : 'Carbs', pct: cPct, color: const Color(0xFFF59E0B)),
                        _PctPill(label: isEs ? 'Grasas' : 'Fats', pct: fPct, color: const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (meal.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text(
                  isEs ? 'Pautas del Nutricionista' : 'Nutritionist Guidelines',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    meal.notes!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _MealSubstitutionsWidget(
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),
              const SizedBox(height: 24),
              if (meal.recipeId != null) ...[
                OutlinedButton.icon(
                  onPressed: () => _handleViewRecipe(context, meal.recipeId!),
                  icon: const Icon(Icons.menu_book_outlined, size: 20),
                  label: Text(
                    isEs ? 'Ver Receta' : 'View Recipe',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLogPressed();
                },
                icon: const Icon(Icons.playlist_add_rounded, size: 22),
                label: Text(
                  isEs ? 'Registrar en Diario de Hoy' : 'Log to Today\'s Diary',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleViewRecipe(BuildContext context, String recipeId) async {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final recipe = await locator<GetProfessionalRecipeUsecase>().execute(recipeId: recipeId);

      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading
      }

      if (recipe == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEs ? 'No se pudo cargar la receta.' : 'Could not load recipe.',
              ),
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => ProfessionalRecipeDetailBottomSheet(recipe: recipe),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEs ? 'Error al cargar la receta: $e' : 'Error loading recipe: $e',
            ),
          ),
        );
      }
    }
  }
}

class ProfessionalRecipeDetailBottomSheet extends StatelessWidget {
  final ProfessionalRecipeData recipe;

  const ProfessionalRecipeDetailBottomSheet({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEs ? 'Detalle de Receta' : 'Recipe Details',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  if (recipe.description?.isNotEmpty == true) ...[
                    Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (recipe.prepTimeMin != null)
                        _RecipeInfoIcon(
                          icon: Icons.timer_outlined,
                          label: isEs ? 'Prep' : 'Prep',
                          value: '${recipe.prepTimeMin}m',
                        ),
                      if (recipe.cookTimeMin != null)
                        _RecipeInfoIcon(
                          icon: Icons.soup_kitchen_outlined,
                          label: isEs ? 'Cocción' : 'Cook',
                          value: '${recipe.cookTimeMin}m',
                        ),
                      if (recipe.servings != null)
                        _RecipeInfoIcon(
                          icon: Icons.restaurant_outlined,
                          label: isEs ? 'Porciones' : 'Servings',
                          value: '${recipe.servings}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isEs ? 'Ingredientes' : 'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceContainerLow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.ingredients == null || recipe.ingredients!.isEmpty)
                          Text(isEs ? 'Sin ingredientes especificados' : 'No ingredients specified')
                        else
                          for (final rawIng in recipe.ingredients!)
                            if (rawIng is Map)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.fiber_manual_record, size: 8, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${rawIng['name'] ?? ''}',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text(
                                      '${rawIng['amount'] ?? ''} ${rawIng['unit'] ?? ''}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isEs ? 'Preparación' : 'Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (recipe.instructions == null || recipe.instructions!.trim().isEmpty)
                    Text(isEs ? 'Sin instrucciones' : 'No instructions')
                  else
                    Text(
                      recipe.instructions!,
                      style: const TextStyle(height: 1.5),
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

class _RecipeInfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RecipeInfoIcon({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class WeekdayDetailBottomSheet extends StatelessWidget {
  final NutritionPlanResolvedDayEntity day;
  final List<NutritionPlanMealEntity> meals;
  final ValueChanged<NutritionPlanMealEntity> onLogMeal;

  const WeekdayDetailBottomSheet({
    super.key,
    required this.day,
    required this.meals,
    required this.onLogMeal,
  });

  @override
  Widget build(BuildContext context) {
    final target = day.target;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    if (target == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(S.of(context).professionalWeekNoTarget),
        ),
      );
    }

    final kcal = target.kcalGoal;
    final protein = target.proteinGoal;
    final carbs = target.carbsGoal;
    final fat = target.fatGoal;

    final totalMacroKcal = (protein * 4) + (carbs * 4) + (fat * 9);
    final pPct = totalMacroKcal <= 0 ? 0 : ((protein * 4) / totalMacroKcal * 100).round();
    final cPct = totalMacroKcal <= 0 ? 0 : ((carbs * 4) / totalMacroKcal * 100).round();
    final fPct = totalMacroKcal <= 0 ? 0 : ((fat * 9) / totalMacroKcal * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatWeekday(context, day.effectiveDate),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StatusPill(
                                icon: day.usesWeekdayFallback
                                    ? Icons.auto_awesome_motion_outlined
                                    : Icons.today_outlined,
                                label: day.usesWeekdayFallback
                                    ? S.of(context).professionalWeekTemplate
                                    : (isEs ? 'Objetivo específico' : 'Specific target'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MacroPanel(
                            label: isEs ? 'Calorías' : 'Calories',
                            value: '${kcal.round()} kcal',
                            color: const Color(0xFFEF4444),
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroPanel(
                            label: isEs ? 'Proteína' : 'Protein',
                            value: '${protein.round()} g',
                            color: const Color(0xFF10B981),
                            icon: Icons.egg_alt_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroPanel(
                            label: isEs ? 'Carb.' : 'Carbs',
                            value: '${carbs.round()} g',
                            color: const Color(0xFFF59E0B),
                            icon: Icons.cookie_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroPanel(
                            label: isEs ? 'Grasa' : 'Fat',
                            value: '${fat.round()} g',
                            color: const Color(0xFF3B82F6),
                            icon: Icons.opacity_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.surfaceContainerLow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEs ? 'Aporte de Energía de Macros' : 'Macronutrient Energy Split',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _PctPill(label: isEs ? 'Proteína' : 'Protein', pct: pPct, color: const Color(0xFF10B981)),
                              _PctPill(label: isEs ? 'Carbos' : 'Carbs', pct: cPct, color: const Color(0xFFF59E0B)),
                              _PctPill(label: isEs ? 'Grasas' : 'Fats', pct: fPct, color: const Color(0xFF3B82F6)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isEs ? 'Comidas recomendadas' : 'Suggested meals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (meals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            isEs ? 'No hay comidas sugeridas' : 'No suggested meals',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      for (final meal in meals)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isDark ? const Color(0xFF222224) : colorScheme.surfaceContainerLow,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${meal.kcal?.round() ?? 0} kcal | ${meal.protein?.round() ?? 0}P | ${meal.carbs?.round() ?? 0}C | ${meal.fat?.round() ?? 0}F',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onLogMeal(meal);
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPanel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroPanel({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? color.withValues(alpha: 0.08)
            : color.withValues(alpha: 0.05),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.22 : 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? colorScheme.onSurface : color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PctPill extends StatelessWidget {
  final String label;
  final int pct;
  final Color color;

  const _PctPill({
    required this.label,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $pct%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Substitutions Helper Classes & Widgets
// -------------------------------------------------------------

class _SubstituteFood {
  final String nameEs;
  final String nameEn;
  final double density; // target grams per 100g of food
  final double kcalPer100g;
  final IconData icon;

  const _SubstituteFood({
    required this.nameEs,
    required this.nameEn,
    required this.density,
    required this.kcalPer100g,
    required this.icon,
  });
}

final _proteinSubstitutes = [
  const _SubstituteFood(nameEs: 'Pechuga de pollo', nameEn: 'Chicken breast', density: 23, kcalPer100g: 165, icon: Icons.restaurant),
  const _SubstituteFood(nameEs: 'Lomo de pavo', nameEn: 'Turkey breast', density: 22, kcalPer100g: 135, icon: Icons.restaurant),
  const _SubstituteFood(nameEs: 'Tofu firme', nameEn: 'Firm tofu', density: 8, kcalPer100g: 76, icon: Icons.eco),
  const _SubstituteFood(nameEs: 'Claras de huevo', nameEn: 'Egg whites', density: 11, kcalPer100g: 52, icon: Icons.egg_outlined),
  const _SubstituteFood(nameEs: 'Salmón fresco', nameEn: 'Salmon fillet', density: 20, kcalPer100g: 208, icon: Icons.set_meal_outlined),
  const _SubstituteFood(nameEs: 'Yogur griego 0%', nameEn: 'Greek Yogurt 0%', density: 10, kcalPer100g: 59, icon: Icons.egg_alt_outlined),
];

final _carbsSubstitutes = [
  const _SubstituteFood(nameEs: 'Arroz cocido', nameEn: 'Cooked rice', density: 28, kcalPer100g: 130, icon: Icons.rice_bowl_outlined),
  const _SubstituteFood(nameEs: 'Patata cocida', nameEn: 'Boiled potato', density: 20, kcalPer100g: 87, icon: Icons.restaurant),
  const _SubstituteFood(nameEs: 'Batata asada', nameEn: 'Sweet potato', density: 20, kcalPer100g: 86, icon: Icons.restaurant),
  const _SubstituteFood(nameEs: 'Copos de avena', nameEn: 'Oats', density: 60, kcalPer100g: 389, icon: Icons.breakfast_dining_outlined),
  const _SubstituteFood(nameEs: 'Pasta hervida', nameEn: 'Boiled pasta', density: 25, kcalPer100g: 131, icon: Icons.dinner_dining_outlined),
  const _SubstituteFood(nameEs: 'Quinoa cocida', nameEn: 'Cooked quinoa', density: 21, kcalPer100g: 120, icon: Icons.grass_outlined),
];

final _fatSubstitutes = [
  const _SubstituteFood(nameEs: 'Aguacate', nameEn: 'Avocado', density: 15, kcalPer100g: 160, icon: Icons.eco_outlined),
  const _SubstituteFood(nameEs: 'Aceite de oliva', nameEn: 'Olive oil', density: 92, kcalPer100g: 884, icon: Icons.opacity_outlined),
  const _SubstituteFood(nameEs: 'Almendras', nameEn: 'Almonds', density: 54, kcalPer100g: 579, icon: Icons.grain_outlined),
  const _SubstituteFood(nameEs: 'Nueces', nameEn: 'Walnuts', density: 65, kcalPer100g: 654, icon: Icons.grain_outlined),
  const _SubstituteFood(nameEs: 'Crema de cacahuete', nameEn: 'Peanut butter', density: 50, kcalPer100g: 588, icon: Icons.cookie_outlined),
];

class _MealSubstitutionsWidget extends StatefulWidget {
  final double protein;
  final double carbs;
  final double fat;

  const _MealSubstitutionsWidget({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  State<_MealSubstitutionsWidget> createState() => _MealSubstitutionsWidgetState();
}

class _MealSubstitutionsWidgetState extends State<_MealSubstitutionsWidget> {
  String _selectedMacro = 'protein';

  @override
  void initState() {
    super.initState();
    if (widget.protein >= 5) {
      _selectedMacro = 'protein';
    } else if (widget.carbs >= 5) {
      _selectedMacro = 'carbs';
    } else if (widget.fat >= 5) {
      _selectedMacro = 'fat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    final hasProtein = widget.protein >= 5;
    final hasCarbs = widget.carbs >= 5;
    final hasFat = widget.fat >= 5;

    if (!hasProtein && !hasCarbs && !hasFat) {
      return const SizedBox.shrink();
    }

    List<_SubstituteFood> substitutes = [];
    double targetGrams = 0.0;
    Color themeColor = colorScheme.primary;

    if (_selectedMacro == 'protein' && hasProtein) {
      substitutes = _proteinSubstitutes;
      targetGrams = widget.protein;
      themeColor = const Color(0xFF10B981);
    } else if (_selectedMacro == 'carbs' && hasCarbs) {
      substitutes = _carbsSubstitutes;
      targetGrams = widget.carbs;
      themeColor = const Color(0xFFF59E0B);
    } else if (_selectedMacro == 'fat' && hasFat) {
      substitutes = _fatSubstitutes;
      targetGrams = widget.fat;
      themeColor = const Color(0xFF3B82F6);
    } else {
      if (hasProtein) {
        substitutes = _proteinSubstitutes;
        targetGrams = widget.protein;
        themeColor = const Color(0xFF10B981);
      } else if (hasCarbs) {
        substitutes = _carbsSubstitutes;
        targetGrams = widget.carbs;
        themeColor = const Color(0xFFF59E0B);
      } else {
        substitutes = _fatSubstitutes;
        targetGrams = widget.fat;
        themeColor = const Color(0xFF3B82F6);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEs ? 'Alternativas y Sustitutos' : 'Equivalent Substitutes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isEs
                ? 'Equivalencias calculadas para aportar los mismos gramos de macronutrientes.'
                : 'Portions scaled to match the exact target macronutrients of this meal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (hasProtein)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _MacroSelectorButton(
                      label: isEs ? 'Proteína' : 'Protein',
                      isSelected: _selectedMacro == 'protein',
                      color: const Color(0xFF10B981),
                      onTap: () => setState(() => _selectedMacro = 'protein'),
                    ),
                  ),
                ),
              if (hasCarbs)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _MacroSelectorButton(
                      label: isEs ? 'Carbos' : 'Carbs',
                      isSelected: _selectedMacro == 'carbs',
                      color: const Color(0xFFF59E0B),
                      onTap: () => setState(() => _selectedMacro = 'carbs'),
                    ),
                  ),
                ),
              if (hasFat)
                Expanded(
                  child: _MacroSelectorButton(
                    label: isEs ? 'Grasa' : 'Fat',
                    isSelected: _selectedMacro == 'fat',
                    color: const Color(0xFF3B82F6),
                    onTap: () => setState(() => _selectedMacro = 'fat'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: substitutes.length,
            separatorBuilder: (context, index) => Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
              height: 12,
            ),
            itemBuilder: (context, index) {
              final food = substitutes[index];
              final portionGrams = (targetGrams / (food.density / 100)).round();
              final portionKcal = ((portionGrams / 100) * food.kcalPer100g).round();
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      food.icon,
                      size: 18,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEs ? food.nameEs : food.nameEn,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${portionGrams}g',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                            ),
                      ),
                      Text(
                        '${portionKcal} kcal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MacroSelectorButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _MacroSelectorButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
