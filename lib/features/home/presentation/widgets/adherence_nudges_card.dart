import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';

class AdherenceNudgesCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final double totalKcalDaily;
  final double totalKcalSupplied;
  final double totalProteinsGoal;
  final double totalProteinsIntake;

  const AdherenceNudgesCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.dailyFocus,
    required this.totalKcalDaily,
    required this.totalKcalSupplied,
    required this.totalProteinsGoal,
    required this.totalProteinsIntake,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<DailyHabitLogEntity>(
            future: locator<GetDailyHabitLogUsecase>().getToday(),
            builder: (context, snapshot) {
              final now = DateTime.now();
              final reminders = <String>[];
              final proteinLeft =
                  (totalProteinsGoal - totalProteinsIntake).clamp(0, 9999);
              final kcalProgress = totalKcalDaily <= 0
                  ? 0.0
                  : (totalKcalSupplied / totalKcalDaily).clamp(0, 1);

              final habit = snapshot.data;
              final hydrationGoal = switch (dailyFocus) {
                DailyFocusEntity.lowerBody => 3.8,
                DailyFocusEntity.upperBody => 3.5,
                DailyFocusEntity.cardio => 3.75,
                DailyFocusEntity.rest => 2.75,
              };
              final hydrationProgress =
                  habit == null ? 0.0 : habit.hydrationProgress(hydrationGoal);

              if (now.hour >= 18 && proteinLeft >= 25) {
                reminders.add(
                  'Te quedan ${proteinLeft.toStringAsFixed(0)} g de proteína. Prioriza una comida alta en proteína.',
                );
              }
              if (now.hour >= 17 && hydrationProgress < 0.7) {
                reminders.add(
                  'Hidratación baja hoy. Sube agua para cerrar al menos al 100%.',
                );
              }
              if (now.hour >= 21 && kcalProgress < 0.85) {
                reminders.add(
                  'Cierra el día: te falta energía para objetivo. Añade una comida limpia de cierre.',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: colorScheme.tertiary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: colorScheme.tertiary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recordatorios inteligentes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reminders.isEmpty
                                  ? 'Sin acciones pendientes por ahora.'
                                  : 'Solo avisos útiles para mantener adherencia.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (reminders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.primary.withValues(alpha: 0.08),
                      ),
                      child: Text(
                        'Sin recordatorios pendientes. Vas bien hoy.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...reminders.map(
                      (message) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.tertiary
                                    .withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 16,
                                color: colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(message)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
