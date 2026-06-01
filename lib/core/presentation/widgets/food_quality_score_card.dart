import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';

class FoodQualityScoreCard extends StatelessWidget {
  final FoodQualityScoreEntity score;
  final String? title;
  final String? subtitle;

  const FoodQualityScoreCard({
    super.key,
    required this.score,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = FoodQualityUiMeta.bandColor(context, score.band);
    final resolvedTitle = title ?? FoodQualityUiMeta.title(context);
    final resolvedSubtitle = subtitle ??
        (score.isPartial
            ? FoodQualityUiMeta.partialSubtitle(context)
            : FoodQualityUiMeta.subtitle(context));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.eco_outlined,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resolvedSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: accentColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        score.score.toString(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                      ),
                      Text(
                        FoodQualityUiMeta.bandLabel(context, score.band),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (score.reasons.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: score.reasons
                    .map(
                      (reason) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.70),
                        ),
                        child: Text(
                          FoodQualityUiMeta.reasonLabel(context, reason),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FoodQualityUiMeta {
  static bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  static String title(BuildContext context) =>
      _isEs(context) ? 'Calidad alimentaria' : 'Food quality';

  static String subtitle(BuildContext context) => _isEs(context)
      ? 'Nota nutricional estimada'
      : 'Estimated nutrition score';

  static String partialSubtitle(BuildContext context) => _isEs(context)
      ? 'Estimacion basada en datos parciales'
      : 'Estimate based on partial data';

  static String bandLabel(BuildContext context, FoodQualityBandEntity band) {
    final isEs = _isEs(context);
    switch (band) {
      case FoodQualityBandEntity.excellent:
        return isEs ? 'Excelente' : 'Excellent';
      case FoodQualityBandEntity.good:
        return isEs ? 'Buena' : 'Good';
      case FoodQualityBandEntity.fair:
        return isEs ? 'Aceptable' : 'Fair';
      case FoodQualityBandEntity.poor:
        return isEs ? 'Baja' : 'Poor';
    }
  }

  static Color bandColor(BuildContext context, FoodQualityBandEntity band) {
    switch (band) {
      case FoodQualityBandEntity.excellent:
        return Colors.green;
      case FoodQualityBandEntity.good:
        return Colors.lightGreen;
      case FoodQualityBandEntity.fair:
        return Colors.orange;
      case FoodQualityBandEntity.poor:
        return Colors.red;
    }
  }

  static String reasonLabel(
      BuildContext context, FoodQualityReasonCode reason) {
    final isEs = _isEs(context);
    switch (reason) {
      case FoodQualityReasonCode.highFiber:
        return isEs ? 'Alta en fibra' : 'High fiber';
      case FoodQualityReasonCode.goodProtein:
        return isEs ? 'Buena proteina' : 'Good protein';
      case FoodQualityReasonCode.balancedProfile:
        return isEs ? 'Perfil equilibrado' : 'Balanced profile';
      case FoodQualityReasonCode.lowSugar:
        return isEs ? 'Azucar contenido' : 'Moderate sugar';
      case FoodQualityReasonCode.highSugar:
        return isEs ? 'Azucar alto' : 'High sugar';
      case FoodQualityReasonCode.highEnergyDensity:
        return isEs ? 'Muy densa en calorias' : 'Calorie dense';
      case FoodQualityReasonCode.lowEnergyDensity:
        return isEs
            ? 'Densidad calorica razonable'
            : 'Reasonable calorie density';
      case FoodQualityReasonCode.highSaturatedFat:
        return isEs ? 'Grasas saturadas altas' : 'High saturated fat';
      case FoodQualityReasonCode.partialData:
        return isEs ? 'Datos parciales' : 'Partial data';
    }
  }
}
