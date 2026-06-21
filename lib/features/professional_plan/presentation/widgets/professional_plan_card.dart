import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class ProfessionalPlanCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final ProfessionalPlanSummaryEntity summary;
  final VoidCallback onOpenPlan;

  const ProfessionalPlanCard({
    super.key,
    required this.padding,
    required this.summary,
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final adherencePct = (summary.adherenceRatio * 100).round();
    final kcalDelta = summary.kcalDelta.round();
    final isOverPlan = kcalDelta > 0;
    final remainingLabel = kcalDelta == 0
        ? S.of(context).professionalPlanOnTarget
        : isOverPlan
            ? S.of(context).professionalPlanOverPlan
            : S.of(context).professionalPlanRemaining;
    final remainingValue = kcalDelta == 0
        ? '0'
        : isOverPlan
            ? '+$kcalDelta'
            : kcalDelta.abs().toString();

    return Padding(
      padding: padding,
      child: Card(
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.08),
          colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: colorScheme.primary.withValues(alpha: 0.12),
                          ),
                          child: Text(
                            S.of(context).professionalSummaryActivePlan,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          S.of(context).professionalPlanVsActual,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${summary.planName} - ${summary.professionalName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: remainingLabel,
                      value: remainingValue,
                      suffix: 'kcal',
                      color:
                          isOverPlan ? colorScheme.error : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroMetric(
                      label: S.of(context).professionalPlanAdherence,
                      value: adherencePct.toString(),
                      suffix: '%',
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: summary.adherenceRatio,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverPlan ? colorScheme.error : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricPill(
                    label: 'Kcal',
                    value:
                        '${summary.kcalActual.round()} / ${summary.kcalTarget.round()}',
                  ),
                  _MetricPill(
                    label: S.of(context).professionalMacroProtein,
                    value:
                        '${summary.proteinActual.round()} / ${summary.proteinTarget.round()}g',
                  ),
                  _MetricPill(
                    label: S.of(context).professionalMacroCarbs,
                    value:
                        '${summary.carbsActual.round()} / ${summary.carbsTarget.round()}g',
                  ),
                  _MetricPill(
                    label: S.of(context).professionalMacroFat,
                    value:
                        '${summary.fatActual.round()} / ${summary.fatTarget.round()}g',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final status = Text(
                    _statusText(context, kcalDelta),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                  );
                  final button = FilledButton.tonalIcon(
                    onPressed: onOpenPlan,
                    icon: const Icon(Icons.open_in_new_outlined, size: 18),
                    label: Text(S.of(context).professionalPlanViewPlan),
                  );
                  if (constraints.maxWidth < 340) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        status,
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: button,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 10),
                      button,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(BuildContext context, int kcalDelta) {
    if (kcalDelta == 0) {
      return S.of(context).professionalPlanStatusExact;
    }
    if (kcalDelta > 0) {
      return S.of(context).professionalPlanStatusOver(kcalDelta);
    }
    return S.of(context).professionalPlanStatusLeft(kcalDelta.abs());
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final Color color;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHigh,
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
