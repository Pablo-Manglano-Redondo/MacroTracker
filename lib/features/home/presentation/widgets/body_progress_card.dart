import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/save_body_measurement_usecase.dart';
import 'package:macrotracker/features/body_progress/presentation/widgets/body_measurement_dialog.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';

class BodyProgressCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final bool usesImperialUnits;

  const BodyProgressCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.usesImperialUnits,
  });

  @override
  State<BodyProgressCard> createState() => _BodyProgressCardState();
}

class _BodyProgressCardState extends State<BodyProgressCard> {
  int _refreshSeed = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<BodyProgressSummaryEntity>(
            future: _loadSummary(_refreshSeed),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 110,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final summary = snapshot.data ??
                  const BodyProgressSummaryEntity(
                    latestMeasurementDay: null,
                    latestWeightKg: null,
                    latestWaistCm: null,
                    rollingWeightAverageKg: null,
                    previousRollingWeightAverageKg: null,
                    weeklyWeightDeltaKg: null,
                    latestWaistDeltaCm: null,
                  );
              final tone = _bodyProgressTone(summary);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Body progress',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary.latestMeasurementDay == null
                                  ? 'No check-ins yet.'
                                  : 'Latest check-in ${DateFormat.MMMd().format(summary.latestMeasurementDay!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: tone.label,
                        icon: tone.icon,
                        foreground: tone.foreground(context),
                        background: tone.background(context),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(NavigationOptions.bodyProgressRoute),
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Open history',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _BodyMetricPill(
                        label: 'Weight',
                        value: _formatWeight(summary.latestWeightKg),
                        accentColor: tone.foreground(context),
                      ),
                      _BodyMetricPill(
                        label: '7d avg',
                        value: _formatWeight(summary.rollingWeightAverageKg),
                        accentColor: Theme.of(context).colorScheme.primary,
                      ),
                      _BodyMetricPill(
                        label: 'Delta',
                        value: _formatWeight(summary.weeklyWeightDeltaKg,
                            signed: true),
                        accentColor: tone.foreground(context),
                      ),
                      _BodyMetricPill(
                        label: 'Waist',
                        value: _formatWaist(summary.latestWaistCm),
                        accentColor: tone.foreground(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _showTodayDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Log today'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(NavigationOptions.bodyProgressRoute),
                        icon: const Icon(Icons.show_chart),
                        label: const Text('History'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showTodayDialog() async {
    final existing = await locator<GetBodyProgressUsecase>()
        .getMeasurementForDay(DateTime.now());
    if (!mounted) {
      return;
    }
    final result = await showDialog<BodyMeasurementDialogResult>(
      context: context,
      builder: (_) => BodyMeasurementDialog(
        initialMeasurement: existing,
        usesImperialUnits: widget.usesImperialUnits,
        allowDayEditing: false,
      ),
    );
    if (result == null) {
      return;
    }

    await locator<SaveBodyMeasurementUsecase>().saveMeasurement(
      day: DateTime.now(),
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

  Future<BodyProgressSummaryEntity> _loadSummary(int refreshSeed) {
    return locator<GetBodyProgressUsecase>().getSummary();
  }

  String _formatWeight(double? kg, {bool signed = false}) {
    if (kg == null) {
      return '--';
    }
    final value = widget.usesImperialUnits ? UnitCalc.kgToLbs(kg) : kg;
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${widget.usesImperialUnits ? 'lb' : 'kg'}';
  }

  String _formatWaist(double? cm) {
    if (cm == null) {
      return '--';
    }
    final value = widget.usesImperialUnits ? UnitCalc.cmToInches(cm) : cm;
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${widget.usesImperialUnits ? 'in' : 'cm'}';
  }

  _StatusTone _bodyProgressTone(BodyProgressSummaryEntity summary) {
    if (!summary.hasData) {
      return const _StatusTone.neutral();
    }

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

    if (waistGood || weightGood) {
      return const _StatusTone.good();
    }
    if (waistBad || weightBad) {
      return const _StatusTone.bad();
    }
    return const _StatusTone.caution();
  }
}

class _BodyMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _BodyMetricPill({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withValues(alpha: 0.10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
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
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _StatusPill({
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

class _StatusTone {
  final String label;
  final IconData icon;
  final _StatusToneKind kind;

  const _StatusTone._(this.label, this.icon, this.kind);

  const _StatusTone.good()
      : this._('On track', Icons.north_east, _StatusToneKind.good);
  const _StatusTone.caution()
      : this._('Mixed', Icons.horizontal_rule, _StatusToneKind.caution);
  const _StatusTone.bad()
      : this._('Off track', Icons.south_east, _StatusToneKind.bad);
  const _StatusTone.neutral()
      : this._(
            'No trend', Icons.radio_button_unchecked, _StatusToneKind.neutral);

  Color foreground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (kind) {
      case _StatusToneKind.good:
        return scheme.primary;
      case _StatusToneKind.caution:
        return scheme.tertiary;
      case _StatusToneKind.bad:
        return scheme.error;
      case _StatusToneKind.neutral:
        return scheme.onSurfaceVariant;
    }
  }

  Color background(BuildContext context) {
    final color = foreground(context);
    return color.withValues(alpha: 0.12);
  }
}

enum _StatusToneKind { good, caution, bad, neutral }
