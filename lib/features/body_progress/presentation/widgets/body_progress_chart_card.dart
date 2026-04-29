import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';

class BodyProgressChartCard extends StatefulWidget {
  final List<BodyMeasurementEntity> measurements;
  final bool usesImperialUnits;

  const BodyProgressChartCard({
    super.key,
    required this.measurements,
    required this.usesImperialUnits,
  });

  @override
  State<BodyProgressChartCard> createState() => _BodyProgressChartCardState();
}

class _BodyProgressChartCardState extends State<BodyProgressChartCard> {
  BodyProgressChartMetric _selectedMetric = BodyProgressChartMetric.weight;

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements =
        widget.measurements.reversed.toList(growable: false);
    final hasWeightData =
        sortedMeasurements.any((measurement) => measurement.weightKg != null);
    final hasWaistData =
        sortedMeasurements.any((measurement) => measurement.waistCm != null);

    if (!hasWeightData && !hasWaistData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).bodyProgressAddCheckinsUnlockChart,
          ),
        ),
      );
    }

    final selectedMetric = _resolveSelectedMetric(
      hasWeightData: hasWeightData,
      hasWaistData: hasWaistData,
    );
    final series = selectedMetric == BodyProgressChartMetric.weight
        ? _buildWeightSeries(sortedMeasurements)
        : _buildWaistSeries(sortedMeasurements);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        S.of(context).bodyProgressTrendChart,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedMetric == BodyProgressChartMetric.weight
                            ? S.of(context).bodyProgressTrendChartWeightSubtitle
                            : S.of(context).bodyProgressTrendChartWaistSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SegmentedButton<BodyProgressChartMetric>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: BodyProgressChartMetric.weight,
                      label: Text(S.of(context).weightLabel),
                      enabled: hasWeightData,
                    ),
                    ButtonSegment(
                      value: BodyProgressChartMetric.waist,
                      label: Text(S.of(context).bodyProgressWaist),
                      enabled: hasWaistData,
                    ),
                  ],
                  selected: {selectedMetric},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedMetric = selection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (series.primary.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(S.of(context).bodyProgressNotEnoughData),
              )
            else ...[
              AspectRatio(
                aspectRatio: 1.8,
                child: CustomPaint(
                  painter: _BodyProgressChartPainter(
                    primaryPoints: series.primary,
                    secondaryPoints: series.secondary,
                    lineColor: Theme.of(context).colorScheme.primary,
                    secondaryLineColor: Theme.of(context).colorScheme.tertiary,
                    gridColor: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.35),
                    axisColor: Theme.of(context).colorScheme.outline,
                    textStyle: Theme.of(context).textTheme.labelSmall!,
                    bottomLabelBuilder: _buildBottomLabel,
                    valueLabelBuilder: (value) => _formatMetricValue(
                      context,
                      value,
                      selectedMetric,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendItem(
                    color: Theme.of(context).colorScheme.primary,
                    label: selectedMetric == BodyProgressChartMetric.weight
                        ? S.of(context).weightLabel
                        : S.of(context).bodyProgressWaist,
                  ),
                  if (series.secondary.isNotEmpty)
                    _LegendItem(
                      color: Theme.of(context).colorScheme.tertiary,
                      label: '7d avg',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  BodyProgressChartMetric _resolveSelectedMetric({
    required bool hasWeightData,
    required bool hasWaistData,
  }) {
    if (_selectedMetric == BodyProgressChartMetric.weight && !hasWeightData) {
      return BodyProgressChartMetric.waist;
    }
    if (_selectedMetric == BodyProgressChartMetric.waist && !hasWaistData) {
      return BodyProgressChartMetric.weight;
    }
    return _selectedMetric;
  }

  String _buildBottomLabel(int index, int total, DateTime day) {
    if (total == 1 || index == 0 || index == total - 1 || index == total ~/ 2) {
      return DateFormat.Md().format(day);
    }
    return '';
  }

  String _formatMetricValue(
      BuildContext context, double value, BodyProgressChartMetric metric) {
    final displayValue = switch (metric) {
      BodyProgressChartMetric.weight =>
        widget.usesImperialUnits ? UnitCalc.kgToLbs(value) : value,
      BodyProgressChartMetric.waist =>
        widget.usesImperialUnits ? UnitCalc.cmToInches(value) : value,
    };
    final unit = switch (metric) {
      BodyProgressChartMetric.weight =>
        widget.usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel,
      BodyProgressChartMetric.waist =>
        widget.usesImperialUnits ? 'in' : S.of(context).cmLabel,
    };
    return '${displayValue.toStringAsFixed(displayValue % 1 == 0 ? 0 : 1)} $unit';
  }

  _ChartSeries _buildWeightSeries(List<BodyMeasurementEntity> measurements) {
    final points = <_ChartPoint>[];
    final rollingAveragePoints = <_ChartPoint>[];

    for (final measurement in measurements) {
      final weightKg = measurement.weightKg;
      if (weightKg == null) {
        continue;
      }

      points.add(_ChartPoint(day: measurement.day, value: weightKg));

      final windowStart = measurement.day.subtract(const Duration(days: 6));
      final windowValues = measurements
          .where(
            (entry) =>
                entry.weightKg != null &&
                !entry.day.isBefore(windowStart) &&
                !entry.day.isAfter(measurement.day),
          )
          .map((entry) => entry.weightKg!)
          .toList(growable: false);
      final average =
          windowValues.reduce((a, b) => a + b) / windowValues.length;
      rollingAveragePoints
          .add(_ChartPoint(day: measurement.day, value: average));
    }

    return _ChartSeries(primary: points, secondary: rollingAveragePoints);
  }

  _ChartSeries _buildWaistSeries(List<BodyMeasurementEntity> measurements) {
    final points = measurements
        .where((measurement) => measurement.waistCm != null)
        .map(
          (measurement) => _ChartPoint(
            day: measurement.day,
            value: measurement.waistCm!,
          ),
        )
        .toList(growable: false);
    return _ChartSeries(primary: points, secondary: const []);
  }
}

enum BodyProgressChartMetric {
  weight,
  waist,
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ChartPoint {
  final DateTime day;
  final double value;

  const _ChartPoint({
    required this.day,
    required this.value,
  });
}

class _ChartSeries {
  final List<_ChartPoint> primary;
  final List<_ChartPoint> secondary;

  const _ChartSeries({
    required this.primary,
    required this.secondary,
  });
}

class _BodyProgressChartPainter extends CustomPainter {
  final List<_ChartPoint> primaryPoints;
  final List<_ChartPoint> secondaryPoints;
  final Color lineColor;
  final Color secondaryLineColor;
  final Color gridColor;
  final Color axisColor;
  final TextStyle textStyle;
  final String Function(int index, int total, DateTime day) bottomLabelBuilder;
  final String Function(double value) valueLabelBuilder;

  const _BodyProgressChartPainter({
    required this.primaryPoints,
    required this.secondaryPoints,
    required this.lineColor,
    required this.secondaryLineColor,
    required this.gridColor,
    required this.axisColor,
    required this.textStyle,
    required this.bottomLabelBuilder,
    required this.valueLabelBuilder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (primaryPoints.isEmpty) {
      return;
    }

    const leftPadding = 8.0;
    const rightPadding = 8.0;
    const topPadding = 12.0;
    const bottomPadding = 28.0;
    final chartRect = Rect.fromLTWH(
      leftPadding,
      topPadding,
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );

    final allValues = [
      ...primaryPoints.map((point) => point.value),
      ...secondaryPoints.map((point) => point.value),
    ];
    final minValue = allValues.reduce(math.min);
    final maxValue = allValues.reduce(math.max);
    final range = math.max(maxValue - minValue, 0.1);
    final paddedMin = minValue - (range * 0.12);
    final paddedMax = maxValue + (range * 0.12);
    final paddedRange = paddedMax - paddedMin;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.2;

    for (var i = 0; i < 4; i++) {
      final dy = chartRect.top + (chartRect.height * i / 3);
      canvas.drawLine(
        Offset(chartRect.left, dy),
        Offset(chartRect.right, dy),
        gridPaint,
      );
      final labelValue = paddedMax - (paddedRange * i / 3);
      _paintText(
        canvas,
        valueLabelBuilder(labelValue),
        Offset(chartRect.left, dy - 10),
        textStyle,
      );
    }

    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );

    if (secondaryPoints.isNotEmpty) {
      _drawSeries(
        canvas,
        chartRect,
        secondaryPoints,
        paddedMin,
        paddedRange,
        secondaryLineColor,
        drawPoints: false,
      );
    }
    _drawSeries(
      canvas,
      chartRect,
      primaryPoints,
      paddedMin,
      paddedRange,
      lineColor,
      drawPoints: true,
    );

    for (var i = 0; i < primaryPoints.length; i++) {
      final point = primaryPoints[i];
      final dx = _mapX(i, primaryPoints.length, chartRect);
      final label = bottomLabelBuilder(i, primaryPoints.length, point.day);
      if (label.isNotEmpty) {
        _paintText(
          canvas,
          label,
          Offset(dx - 14, chartRect.bottom + 8),
          textStyle,
        );
      }
    }
  }

  void _drawSeries(
    Canvas canvas,
    Rect chartRect,
    List<_ChartPoint> points,
    double minValue,
    double range,
    Color color, {
    required bool drawPoints,
  }) {
    if (points.isEmpty) {
      return;
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final dx = _mapX(i, points.length, chartRect);
      final dy = _mapY(points[i].value, minValue, range, chartRect);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    if (!drawPoints) {
      return;
    }

    final pointPaint = Paint()..color = color;
    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < points.length; i++) {
      final dx = _mapX(i, points.length, chartRect);
      final dy = _mapY(points[i].value, minValue, range, chartRect);
      canvas.drawCircle(Offset(dx, dy), 3.6, pointPaint);
      canvas.drawCircle(Offset(dx, dy), 3.6, pointBorderPaint);
    }
  }

  double _mapX(int index, int total, Rect chartRect) {
    if (total <= 1) {
      return chartRect.center.dx;
    }
    return chartRect.left + (chartRect.width * index / (total - 1));
  }

  double _mapY(double value, double minValue, double range, Rect chartRect) {
    final normalized = (value - minValue) / range;
    return chartRect.bottom - (normalized * chartRect.height);
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BodyProgressChartPainter oldDelegate) {
    return primaryPoints != oldDelegate.primaryPoints ||
        secondaryPoints != oldDelegate.secondaryPoints ||
        lineColor != oldDelegate.lineColor ||
        secondaryLineColor != oldDelegate.secondaryLineColor ||
        gridColor != oldDelegate.gridColor ||
        axisColor != oldDelegate.axisColor ||
        textStyle != oldDelegate.textStyle;
  }
}
