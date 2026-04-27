import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
import 'package:macrotracker/core/presentation/widgets/info_dialog.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:macrotracker/generated/l10n.dart';

class BMIOverview extends StatelessWidget {
  final double bmiValue;
  final UserNutritionalStatus nutritionalStatus;

  const BMIOverview(
      {super.key, required this.bmiValue, required this.nutritionalStatus});

  @override
  Widget build(BuildContext context) {
    final accentColor = getAccentColorTheme(context);
    final accentSurface = getContainerColorTheme(context);
    final accentText = getContainerTextStyle(
          context,
          Theme.of(context).textTheme.bodyMedium,
        )?.color ??
        Theme.of(context).colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body composition',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use BMI as context, not as the main score for gym progress.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => InfoDialog(
                              title: S.of(context).bmiLabel,
                              body: S.of(context).bmiInfo,
                            ));
                  },
                  icon: const Icon(Icons.help_outline_outlined),
                  tooltip: S.of(context).bmiLabel,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: accentSurface,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bmiValue.roundToPrecision(1)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accentText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).bmiLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: accentText.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: accentColor.withValues(alpha: 0.14),
                        ),
                        child: Text(
                          nutritionalStatus.getName(context),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        S.of(context).nutritionalStatusRiskLabel(
                            nutritionalStatus.getRiskStatus(context)),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _coachingCopy(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _coachingCopy() {
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        return 'Prioritize consistent calories, protein and progressive training.';
      case UserNutritionalStatus.normalWeight:
        return 'Good baseline. Let waist, performance and weekly trend lead decisions.';
      case UserNutritionalStatus.preObesity:
        return 'Track waist and weekly average closely so the phase stays controlled.';
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        return 'Use body-weight trend and waist together before making calorie adjustments.';
    }
  }

  Color getContainerColorTheme(BuildContext context) {
    Color theme;
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        theme =
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1);
        break;
      case UserNutritionalStatus.normalWeight:
        theme = Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.6);
        break;
      case UserNutritionalStatus.preObesity:
        theme =
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2);
        break;
      case UserNutritionalStatus.obesityClassI:
        theme =
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4);
        break;
      case UserNutritionalStatus.obesityClassII:
        theme =
            Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.7);
        break;
      case UserNutritionalStatus.obesityClassIII:
        theme = Theme.of(context).colorScheme.errorContainer;
        break;
    }
    return theme;
  }

  Color getAccentColorTheme(BuildContext context) {
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        return Theme.of(context).colorScheme.error;
      case UserNutritionalStatus.normalWeight:
        return Theme.of(context).colorScheme.primary;
      case UserNutritionalStatus.preObesity:
      case UserNutritionalStatus.obesityClassI:
      case UserNutritionalStatus.obesityClassII:
      case UserNutritionalStatus.obesityClassIII:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  TextStyle? getContainerTextStyle(BuildContext context, TextStyle? style) {
    TextStyle? textStyle;
    switch (nutritionalStatus) {
      case UserNutritionalStatus.underWeight:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer);
        break;
      case UserNutritionalStatus.normalWeight:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer);
        break;
      case UserNutritionalStatus.preObesity:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer);
        break;
      case UserNutritionalStatus.obesityClassI:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer);
        break;
      case UserNutritionalStatus.obesityClassII:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer);
        break;
      case UserNutritionalStatus.obesityClassIII:
        textStyle = style?.copyWith(
            color: Theme.of(context).colorScheme.onErrorContainer);
        break;
    }
    return textStyle;
  }
}
