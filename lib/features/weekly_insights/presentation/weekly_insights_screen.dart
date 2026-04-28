import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';

class WeeklyInsightsScreen extends StatelessWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as WeeklyInsightsScreenArguments?;
    final focusedWeek = args?.focusedWeek ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen semanal')),
      body: FutureBuilder<WeeklyInsightsEntity>(
        future: locator<BuildWeeklyInsightsUsecase>().build(focusedWeek),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No se pudo cargar el resumen semanal.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final insights = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '${DateFormat.MMMd().format(insights.weekStart)} - ${DateFormat.MMMd().format(insights.weekEnd)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12.0),
              _InfoCard(
                title: 'Resumen',
                child: Text(insights.summaryLabel),
              ),
              _InfoCard(
                title: 'Chequeo semanal inteligente',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendencia de peso: ${insights.weeklyWeightDeltaKg >= 0 ? '+' : ''}${insights.weeklyWeightDeltaKg.toStringAsFixed(2)} kg/semana',
                    ),
                    const SizedBox(height: 6),
                    Text(insights.kcalAdjustmentRecommendation),
                    const SizedBox(height: 10),
                    if (insights.recommendedKcalAdjustmentDelta != 0)
                      FilledButton.icon(
                        onPressed: () =>
                            _applyRecommendedAdjustment(context, insights),
                        icon: const Icon(Icons.auto_fix_high_outlined),
                        label: Text(
                          'Aplicar ${insights.recommendedKcalAdjustmentDelta > 0 ? '+' : ''}${insights.recommendedKcalAdjustmentDelta} kcal/dia',
                        ),
                      ),
                  ],
                ),
              ),
              _InfoCard(
                title: 'Promedios semanales',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${insights.averageCalories.toStringAsFixed(0)} kcal / dia'),
                    Text(
                        'Carbohidratos ${insights.averageCarbs.toStringAsFixed(1)} g'),
                    Text('Grasa ${insights.averageFat.toStringAsFixed(1)} g'),
                    Text(
                        'Proteina ${insights.averageProtein.toStringAsFixed(1)} g'),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Adherencia',
                      child: Text(
                          '${(insights.goalAdherenceRate * 100).round()}% de dias registrados'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _InfoCard(
                      title: 'Consistencia de proteina',
                      child: Text(
                          '${(insights.proteinConsistencyRate * 100).round()}% de dias registrados'),
                    ),
                  ),
                ],
              ),
              _InfoCard(
                title: 'Comidas mas frecuentes',
                child: insights.topMeals.isEmpty
                    ? const Text(
                        'No se detectaron comidas repetidas esta semana.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: insights.topMeals
                            .map((meal) =>
                                Text('${meal.label} (${meal.count}x)'))
                            .toList(),
                      ),
              ),
              _InfoCard(
                title: 'Patron de sobreingesta',
                child: Text(insights.overeatingTimeSlotLabel),
              ),
              _InfoCard(
                title: 'Cobertura',
                child: Text(
                    '${insights.trackedDays} dias registrados esta semana'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _applyRecommendedAdjustment(
    BuildContext context,
    WeeklyInsightsEntity insights,
  ) async {
    final getConfigUsecase = locator<GetConfigUsecase>();
    final addConfigUsecase = locator<AddConfigUsecase>();
    final current =
        (await getConfigUsecase.getConfig()).userKcalAdjustment ?? 0;
    final next = current + insights.recommendedKcalAdjustmentDelta;
    await addConfigUsecase.setConfigKcalAdjustment(next);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ajuste diario actualizado a ${next.toStringAsFixed(0)} kcal.',
          ),
        ),
      );
    }
  }
}

class WeeklyInsightsScreenArguments {
  final DateTime focusedWeek;

  WeeklyInsightsScreenArguments(this.focusedWeek);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8.0),
            child,
          ],
        ),
      ),
    );
  }
}
