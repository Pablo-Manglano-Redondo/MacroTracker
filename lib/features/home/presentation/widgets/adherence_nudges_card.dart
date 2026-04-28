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
    return Padding(
      padding: padding,
      child: Card(
        elevation: 0.5,
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
                DailyFocusEntity.training => 3.5,
                DailyFocusEntity.cardio => 3.75,
                DailyFocusEntity.rest => 2.75,
              };
              final hydrationProgress =
                  habit == null ? 0.0 : habit.hydrationProgress(hydrationGoal);

              if (now.hour >= 18 && proteinLeft >= 25) {
                reminders.add(
                    'Te quedan ${proteinLeft.toStringAsFixed(0)} g de proteína. Prioriza una comida alta en proteína.');
              }
              if (now.hour >= 17 && hydrationProgress < 0.7) {
                reminders.add(
                    'Hidratación baja hoy. Sube agua para cerrar al menos al 100%.');
              }
              if (now.hour >= 21 && kcalProgress < 0.85) {
                reminders.add(
                    'Cierra el día: te falta energía para objetivo. Añade una comida limpia de cierre.');
              }

              if (reminders.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart reminders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sin nudges pendientes. Vas bien hoy.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart reminders',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  ...reminders.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notifications_none_outlined,
                              size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(message)),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
