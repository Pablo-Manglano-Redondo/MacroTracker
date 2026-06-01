import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';

class NutritionKpiCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const NutritionKpiCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  State<NutritionKpiCard> createState() => _NutritionKpiCardState();
}

class _NutritionKpiCardState extends State<NutritionKpiCard> {
  late Future<_KpiData> _kpiFuture;

  @override
  void initState() {
    super.initState();
    _kpiFuture = _loadKpiData();
  }

  Future<_KpiData> _loadKpiData() async {
    final weekly =
        await locator<BuildWeeklyInsightsUsecase>().build(DateTime.now());
    final streak = await _computeStreak();
    final aiTrial = await locator<MonetizationService>().getAiTrialState();
    return _KpiData(weekly: weekly, streak: streak, aiTrial: aiTrial);
  }

  Future<int> _computeStreak() async {
    const lookback = 60;
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: lookback));
    final days = await locator<GetTrackedDayUsecase>()
        .getTrackedDaysByRange(start, today);

    final tracked = <String>{};
    for (final day in days) {
      tracked.add(_dateKey(day.day));
    }

    int streak = 0;
    for (int index = 0; index <= lookback; index++) {
      final day = today.subtract(Duration(days: index));
      if (!tracked.contains(_dateKey(day))) {
        break;
      }
      streak++;
    }
    return streak;
  }

  String _dateKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Padding(
      padding: widget.padding,
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
          child: FutureBuilder<_KpiData>(
            future: _kpiFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Text(
                  isEs
                      ? 'KPI nutricionales no disponibles ahora mismo.'
                      : 'Nutritional KPIs not available right now.',
                );
              }

              final data = snapshot.data!;
              final kpi = data.weekly;
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
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.query_stats_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEs
                                  ? 'Rendimiento nutricional'
                                  : 'Nutritional performance',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEs
                                  ? 'Chequeo semanal en 10 segundos'
                                  : 'Weekly check in 10 seconds',
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
                  _KpiStatTile(
                    label: isEs ? 'Adherencia kcal' : 'Kcal adherence',
                    value: '${(kpi.goalAdherenceRate * 100).round()}%',
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: isEs ? 'Proteina media' : 'Avg. protein',
                    value:
                        '${kpi.averageProtein.toStringAsFixed(0)} ${isEs ? 'g/dia' : 'g/day'}',
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label:
                        isEs ? 'Consistencia proteica' : 'Protein consistency',
                    value: '${(kpi.proteinConsistencyRate * 100).round()}%',
                    color: const Color(0xFFE7A83B),
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: isEs ? 'Dias registrados' : 'Tracked days',
                    value: '${kpi.trackedDays}/7',
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: isEs ? 'Racha actual' : 'Current streak',
                    value: isEs ? '${data.streak} dias' : '${data.streak} days',
                    color: const Color(0xFFEF4444),
                    highlight: data.streak >= 3,
                  ),
                  if (!data.aiTrial.isPremium && kpi.trackedDays >= 3) ...[
                    const SizedBox(height: 14),
                    _WeeklyPremiumCta(aiTrial: data.aiTrial),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KpiData {
  final WeeklyInsightsEntity weekly;
  final int streak;
  final AiTrialState aiTrial;

  const _KpiData({
    required this.weekly,
    required this.streak,
    required this.aiTrial,
  });
}

class _WeeklyPremiumCta extends StatelessWidget {
  final AiTrialState aiTrial;

  const _WeeklyPremiumCta({required this.aiTrial});

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEs
                  ? 'Premium convierte tus registros en ajustes semanales con IA.'
                  : 'Premium turns your logs into weekly AI adjustments.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (context) => PaywallSheet(
                placement: PaywallPlacement.weeklyInsights,
                trialState: aiTrial,
              ),
            ),
            child: Text(isEs ? 'Ver' : 'View'),
          ),
        ],
      ),
    );
  }
}

class _KpiStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlight;

  const _KpiStatTile({
    required this.label,
    required this.value,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: highlight ? 0.12 : 0.08),
        border: Border.all(
          color: color.withValues(alpha: highlight ? 0.22 : 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: highlight ? color : null,
                ),
          ),
        ],
      ),
    );
  }
}
