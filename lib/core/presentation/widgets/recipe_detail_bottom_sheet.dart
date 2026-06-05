import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class RecipeDetailBottomSheet extends StatelessWidget {
  final RecipeEntity recipe;
  final QuickRecipeCategoryEntity category;
  final IntakeTypeEntity intakeType;
  final double servings;
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final String? rationale;
  final String? rationaleTitle;
  final bool isCoachSuggestion;
  final VoidCallback onLogPressed;
  final VoidCallback onEditPressed;

  const RecipeDetailBottomSheet({
    super.key,
    required this.recipe,
    required this.category,
    required this.intakeType,
    required this.servings,
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    this.rationale,
    this.rationaleTitle,
    this.isCoachSuggestion = false,
    required this.onLogPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    
    final defaultServings = recipe.defaultServings;
    final scaleFactor = defaultServings > 0 ? (servings / defaultServings) : 1.0;
    final displayedRationale =
        isCoachSuggestion ? rationale : _cleanRecipeNotes(rationale);
    
    final formattedServings = servings.toStringAsFixed(
      servings % 1 == 0 ? 0 : 1,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isCoachSuggestion
                                      ? (isEs
                                          ? 'Sugerencia de consumo: $formattedServings ${servings == 1 ? "racion" : "raciones"}'
                                          : 'Suggested intake: $formattedServings ${servings == 1 ? "serving" : "servings"}')
                                      : (isEs
                                          ? 'Racion: $formattedServings ${servings == 1 ? "racion" : "raciones"}'
                                          : 'Serving: $formattedServings ${servings == 1 ? "serving" : "servings"}'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: category.icon,
                            label: category.label,
                          ),
                          _MetaChip(
                            icon: _slotIcon(intakeType),
                            label: _slotText(context, intakeType),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MacroPanel(
                              label: isEs ? 'Calorías' : 'Calories',
                              value: '${kcal.toStringAsFixed(0)} kcal',
                              color: const Color(0xFFEF4444),
                              icon: Icons.local_fire_department_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MacroPanel(
                              label: isEs ? 'Proteína' : 'Protein',
                              value: '${protein.toStringAsFixed(1)} g',
                              color: const Color(0xFF10B981),
                              icon: Icons.egg_alt_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MacroPanel(
                              label: isEs ? 'Carb.' : 'Carbs',
                              value: '${carbs.toStringAsFixed(1)} g',
                              color: const Color(0xFFF59E0B),
                              icon: Icons.cookie_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MacroPanel(
                              label: isEs ? 'Grasa' : 'Fat',
                              value: '${fat.toStringAsFixed(1)} g',
                              color: const Color(0xFF3B82F6),
                              icon: Icons.opacity_outlined,
                            ),
                          ),
                        ],
                      ),
                      if (displayedRationale != null &&
                          displayedRationale.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isCoachSuggestion
                                ? colorScheme.tertiaryContainer.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                            border: Border.all(
                              color: isCoachSuggestion
                                  ? colorScheme.tertiary.withValues(alpha: 0.15)
                                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCoachSuggestion
                                        ? Icons.psychology_alt_outlined
                                        : Icons.notes_outlined,
                                    size: 18,
                                    color: isCoachSuggestion
                                        ? colorScheme.tertiary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rationaleTitle ??
                                        (isCoachSuggestion
                                            ? (isEs ? 'Recomendacion del Coach' : 'Coach Recommendation')
                                            : (isEs ? 'Notas de la receta' : 'Recipe notes')),
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: isCoachSuggestion
                                              ? colorScheme.tertiary
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                displayedRationale,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        isEs ? 'Ingredientes' : 'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      if (recipe.ingredients.isEmpty)
                        Text(
                          isEs
                              ? 'No hay ingredientes detallados para esta receta.'
                              : 'No detailed ingredients for this recipe.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                        )
                      else
                        ...recipe.ingredients.map((ingredient) {
                          final scaledAmt = ingredient.amount * scaleFactor;
                          final displayAmt = _formatAmount(scaledAmt);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? const Color(0xFF222224)
                                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient.mealSnapshot.name ?? (isEs ? 'Ingrediente' : 'Ingredient'),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                  ),
                                  child: Text(
                                    '$displayAmt ${ingredient.unit}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    FilledButton.icon(
                      onPressed: onLogPressed,
                      icon: const Icon(Icons.add_task_outlined, size: 18),
                      label: Text(
                        isEs ? 'Registrar en el Diario' : 'Log to Diary',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: onEditPressed,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(
                        isCoachSuggestion
                            ? (isEs ? 'Personalizar receta' : 'Customize recipe')
                            : (isEs ? 'Editar receta' : 'Edit recipe'),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(1);
  }

  String? _cleanRecipeNotes(String? notes) {
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
        .replaceAll(RegExp(r'#tentempi.\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
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
