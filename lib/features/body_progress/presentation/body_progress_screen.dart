import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/save_body_measurement_usecase.dart';
import 'package:macrotracker/features/body_progress/presentation/widgets/body_progress_chart_card.dart';
import 'package:macrotracker/features/body_progress/presentation/widgets/body_measurement_dialog.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';

class BodyProgressScreen extends StatefulWidget {
  const BodyProgressScreen({super.key});

  @override
  State<BodyProgressScreen> createState() => _BodyProgressScreenState();
}

class _BodyProgressScreenState extends State<BodyProgressScreen> {
  int _refreshSeed = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).bodyProgressTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLogDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_BodyProgressViewModel>(
        future: _loadViewModel(_refreshSeed),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
                child: Text(S.of(context).bodyProgressLoadError));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                summary: data.summary,
                usesImperialUnits: data.usesImperialUnits,
              ),
              const SizedBox(height: 16),
              BodyProgressChartCard(
                measurements: data.measurements,
                usesImperialUnits: data.usesImperialUnits,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).bodyProgressRecentCheckins,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (data.measurements.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      S.of(context).bodyProgressNoCheckins,
                    ),
                  ),
                )
              else
                ...data.measurements.map(
                  (measurement) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: Text(DateFormat.yMMMd().format(measurement.day)),
                      subtitle: Text(_entrySummary(
                        measurement,
                        data.usesImperialUnits,
                      )),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _showLogDialog(existing: measurement),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<_BodyProgressViewModel> _loadViewModel(int refreshSeed) async {
    final config = await locator<GetConfigUsecase>().getConfig();
    final summary = await locator<GetBodyProgressUsecase>().getSummary();
    final measurements =
        await locator<GetBodyProgressUsecase>().getRecentMeasurements();
    return _BodyProgressViewModel(
      summary: summary,
      measurements: measurements,
      usesImperialUnits: config.usesImperialUnits,
    );
  }

  Future<void> _showLogDialog({BodyMeasurementEntity? existing}) async {
    final config = await locator<GetConfigUsecase>().getConfig();
    if (!mounted) {
      return;
    }

    final result = await showDialog<BodyMeasurementDialogResult>(
      context: context,
      builder: (_) => BodyMeasurementDialog(
        initialMeasurement: existing,
        usesImperialUnits: config.usesImperialUnits,
      ),
    );
    if (result == null) {
      return;
    }

    await locator<SaveBodyMeasurementUsecase>().saveMeasurement(
      day: result.day,
      weightKg: result.weightKg,
      waistCm: result.waistCm,
    );
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<ProfileBloc>().add(LoadProfileEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  String _entrySummary(
      BodyMeasurementEntity measurement, bool usesImperialUnits) {
    final parts = <String>[];
    if (measurement.weightKg != null) {
      final weight = usesImperialUnits
          ? UnitCalc.kgToLbs(measurement.weightKg!)
          : measurement.weightKg!;
      parts.add(
          '${S.of(context).weightLabel} ${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}');
    }
    if (measurement.waistCm != null) {
      final waist = usesImperialUnits
          ? UnitCalc.cmToInches(measurement.waistCm!)
          : measurement.waistCm!;
      parts.add(
          '${S.of(context).bodyProgressWaist} ${waist.toStringAsFixed(waist % 1 == 0 ? 0 : 1)} ${usesImperialUnits ? 'in' : S.of(context).cmLabel}');
    }
    return parts.join(' | ');
  }
}

class _SummaryCard extends StatelessWidget {
  final BodyProgressSummaryEntity summary;
  final bool usesImperialUnits;

  const _SummaryCard({
    required this.summary,
    required this.usesImperialUnits,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _trendTone(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).bodyProgressTrend,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _TrendStatusPill(
                  label: tone.label,
                  icon: tone.icon,
                  foreground: tone.foreground,
                  background: tone.background,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(
                  label: S.of(context).bodyProgressLatestWeight,
                  value: _weight(context, summary.latestWeightKg),
                  accentColor: tone.foreground,
                ),
                _MetricTile(
                  label: S.of(context).bodyProgress7dAverage,
                  value: _weight(context, summary.rollingWeightAverageKg),
                  accentColor: Theme.of(context).colorScheme.primary,
                ),
                _MetricTile(
                  label: S.of(context).bodyProgressWeeklyDelta,
                  value: _weight(context, summary.weeklyWeightDeltaKg, signed: true),
                  accentColor: tone.foreground,
                ),
                _MetricTile(
                  label: S.of(context).bodyProgressLatestWaist,
                  value: _waist(context, summary.latestWaistCm),
                  accentColor: tone.foreground,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (summary.hasWeightTrend || summary.hasWaistTrend)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: tone.background,
                  border: Border.all(
                    color: tone.foreground.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).bodyProgressAutoRead,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    if (summary.hasWeightTrend)
                      Text(
                      _weightTrendText(context),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (summary.hasWeightTrend && summary.hasWaistTrend)
                      const SizedBox(height: 6),
                    if (summary.hasWaistTrend)
                      Text(
                        _waistTrendText(context),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _weight(BuildContext context, double? kg, {bool signed = false}) {
    if (kg == null) {
      return '--';
    }
    final value = usesImperialUnits ? UnitCalc.kgToLbs(kg) : kg;
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}';
  }

  String _waist(BuildContext context, double? cm) {
    if (cm == null) {
      return '--';
    }
    final value = usesImperialUnits ? UnitCalc.cmToInches(cm) : cm;
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${usesImperialUnits ? 'in' : S.of(context).cmLabel}';
  }

  String _weightTrendText(BuildContext context) {
    final delta = summary.weeklyWeightDeltaKg;
    if (delta == null) {
      return S.of(context).bodyProgressTrendWeightNeedData;
    }
    if (summary.isWeightStable) {
      return S.of(context).bodyProgressTrendWeightSteady;
    }
    if (delta < 0) {
      return S.of(context).bodyProgressTrendWeightDown;
    }
    return S.of(context).bodyProgressTrendWeightUp;
  }

  String _waistTrendText(BuildContext context) {
    final delta = summary.latestWaistDeltaCm;
    if (delta == null) {
      return S.of(context).bodyProgressTrendWaistNeedData;
    }
    if (summary.isWaistStable) {
      return S.of(context).bodyProgressTrendWaistSteady;
    }
    if (delta < 0) {
      return S.of(context).bodyProgressTrendWaistDown;
    }
    return S.of(context).bodyProgressTrendWaistUp;
  }

  _TrendTone _trendTone(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final waistGood = summary.hasWaistTrend &&
        (summary.isWaistStable || (summary.latestWaistDeltaCm ?? 0) < 0);
    final weightGood = summary.hasWeightTrend &&
        (summary.isWeightStable || (summary.weeklyWeightDeltaKg ?? 0) < 0);
    final waistBad = summary.hasWaistTrend &&
        !summary.isWaistStable &&
        (summary.latestWaistDeltaCm ?? 0) > 0;
    final weightBad = summary.hasWeightTrend &&
        !summary.isWeightStable &&
        (summary.weeklyWeightDeltaKg ?? 0) > 0;

    if (!summary.hasData) {
      return _TrendTone(
        label: S.of(context).bodyProgressTrendNoTrend,
        icon: Icons.radio_button_unchecked,
        foreground: scheme.onSurfaceVariant,
        background: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      );
    }
    if (waistGood || weightGood) {
      return _TrendTone(
        label: S.of(context).bodyProgressTrendOnTrack,
        icon: Icons.north_east,
        foreground: scheme.primary,
        background: scheme.primary.withValues(alpha: 0.10),
      );
    }
    if (waistBad || weightBad) {
      return _TrendTone(
        label: S.of(context).bodyProgressTrendOffTrack,
        icon: Icons.south_east,
        foreground: scheme.error,
        background: scheme.error.withValues(alpha: 0.10),
      );
    }
    return _TrendTone(
      label: S.of(context).bodyProgressTrendMixed,
      icon: Icons.horizontal_rule,
      foreground: scheme.tertiary,
      background: scheme.tertiary.withValues(alpha: 0.10),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withValues(alpha: 0.10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accentColor,
                ),
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TrendStatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _TrendStatusPill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}

class _TrendTone {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _TrendTone({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });
}

class _BodyProgressViewModel {
  final BodyProgressSummaryEntity summary;
  final List<BodyMeasurementEntity> measurements;
  final bool usesImperialUnits;

  const _BodyProgressViewModel({
    required this.summary,
    required this.measurements,
    required this.usesImperialUnits,
  });
}
