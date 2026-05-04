import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/generated/l10n.dart';
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
              if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
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
              final tone = _bodyProgressTone(context, summary);

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
                              S.of(context).bodyProgressTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary.latestMeasurementDay == null
                                  ? S.of(context).bodyProgressNoCheckinsYet
                                  : S.of(context).bodyProgressLatestCheckin(DateFormat.MMMd().format(summary.latestMeasurementDay!)),
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
                        tooltip: S.of(context).bodyProgressOpenHistoryTooltip,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BodyMetricPill(
                          label: S.of(context).weightLabel,
                          value: _formatWeight(context, summary.latestWeightKg),
                          accentColor: tone.foreground(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BodyMetricPill(
                          label: S.of(context).bodyProgress7dAverage,
                          value: _formatWeight(context, summary.rollingWeightAverageKg),
                          accentColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _BodyMetricPill(
                          label: S.of(context).bodyProgressDelta,
                          value: _formatWeight(context, summary.weeklyWeightDeltaKg,
                              signed: true),
                          accentColor: tone.foreground(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _BodyMetricPill(
                          label: S.of(context).bodyProgressWaist,
                          value: _formatWaist(context, summary.latestWaistCm),
                          accentColor: tone.foreground(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _showTodayDialog,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(S.of(context).logTodayLabel),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(NavigationOptions.bodyProgressRoute),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.show_chart),
                          label: Text(S.of(context).historyLabel),
                        ),
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

  String _formatWeight(BuildContext context, double? kg, {bool signed = false}) {
    if (kg == null) {
      return '--';
    }
    final value = widget.usesImperialUnits ? UnitCalc.kgToLbs(kg) : kg;
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${widget.usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}';
  }

  String _formatWaist(BuildContext context, double? cm) {
    if (cm == null) {
      return '--';
    }
    final value = widget.usesImperialUnits ? UnitCalc.cmToInches(cm) : cm;
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${widget.usesImperialUnits ? 'in' : S.of(context).cmLabel}';
  }

  _StatusTone _bodyProgressTone(BuildContext context, BodyProgressSummaryEntity summary) {
    if (!summary.hasData) {
      return _StatusTone.neutral(context);
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
      return _StatusTone.good(context);
    }
    if (waistBad || weightBad) {
      return _StatusTone.bad(context);
    }
    return _StatusTone.caution(context);
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

  factory _StatusTone.good(BuildContext context) =>
      _StatusTone._(S.of(context).bodyProgressTrendOnTrack, Icons.north_east, _StatusToneKind.good);
  factory _StatusTone.caution(BuildContext context) =>
      _StatusTone._(S.of(context).bodyProgressTrendMixed, Icons.horizontal_rule, _StatusToneKind.caution);
  factory _StatusTone.bad(BuildContext context) =>
      _StatusTone._(S.of(context).bodyProgressTrendOffTrack, Icons.south_east, _StatusToneKind.bad);
  factory _StatusTone.neutral(BuildContext context) =>
      _StatusTone._(
            S.of(context).bodyProgressTrendNoTrend, Icons.radio_button_unchecked, _StatusToneKind.neutral);

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
