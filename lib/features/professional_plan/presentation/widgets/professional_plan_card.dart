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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final planName = summary.planName.trim().isNotEmpty
        ? summary.planName
        : S.of(context).professionalSummaryNoPublishedPlan;

    return Padding(
      padding: padding,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.04),
          colorScheme.surface,
        ),
        child: InkWell(
          onTap: onOpenPlan,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.assignment_turned_in_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        planName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.professionalName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            S.of(context).professionalPlanViewPlan,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
