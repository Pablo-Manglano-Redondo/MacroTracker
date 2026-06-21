import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

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
  static String title(BuildContext context) =>
      S.of(context).foodQualityTitle;

  static String subtitle(BuildContext context) =>
      S.of(context).foodQualitySubtitle;

  static String partialSubtitle(BuildContext context) =>
      S.of(context).foodQualityPartialSubtitle;

  static String bandLabel(BuildContext context, FoodQualityBandEntity band) {
    switch (band) {
      case FoodQualityBandEntity.excellent:
        return S.of(context).foodQualityBandExcellent;
      case FoodQualityBandEntity.good:
        return S.of(context).foodQualityBandGood;
      case FoodQualityBandEntity.fair:
        return S.of(context).foodQualityBandFair;
      case FoodQualityBandEntity.poor:
        return S.of(context).foodQualityBandPoor;
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
    switch (reason) {
      case FoodQualityReasonCode.highFiber:
        return S.of(context).foodQualityReasonHighFiber;
      case FoodQualityReasonCode.goodProtein:
        return S.of(context).foodQualityReasonGoodProtein;
      case FoodQualityReasonCode.balancedProfile:
        return S.of(context).foodQualityReasonBalancedProfile;
      case FoodQualityReasonCode.lowSugar:
        return S.of(context).foodQualityReasonLowSugar;
      case FoodQualityReasonCode.highSugar:
        return S.of(context).foodQualityReasonHighSugar;
      case FoodQualityReasonCode.highEnergyDensity:
        return S.of(context).foodQualityReasonHighEnergyDensity;
      case FoodQualityReasonCode.lowEnergyDensity:
        return S.of(context).foodQualityReasonLowEnergyDensity;
      case FoodQualityReasonCode.highSaturatedFat:
        return S.of(context).foodQualityReasonHighSaturatedFat;
      case FoodQualityReasonCode.partialData:
        return S.of(context).foodQualityReasonPartialData;
    }
  }
}
