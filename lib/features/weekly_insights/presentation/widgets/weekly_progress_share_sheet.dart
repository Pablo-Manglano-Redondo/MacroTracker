import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/generated/l10n.dart';


class WeeklyProgressShareSheet extends StatefulWidget {
  final WeeklyInsightsEntity insights;

  const WeeklyProgressShareSheet({super.key, required this.insights});

  static Future<void> show(BuildContext context, WeeklyInsightsEntity insights) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklyProgressShareSheet(insights: insights),
    );
  }

  static String formatWeeklyDateRange(DateTime start, DateTime end, String locale) {
    final startStr = DateFormat.MMMd(locale).format(start);
    final endStr = DateFormat.MMMd(locale).format(end);
    return '$startStr - $endStr';
  }

  static String buildWeeklyProgressTextReport({
    required WeeklyInsightsEntity insights,
    required String dateRangeText,
    required String title,
    required String rangeLabel,
    required String averageCaloriesLabel,
    required String averageProteinLabel,
    required String averageCarbsLabel,
    required String averageFatLabel,
    required String goalAdherenceLabel,
    required String proteinConsistencyLabel,
    required String daysTrackedLabel,
    required String weightDeltaLabel,
    required String daysUnit,
    required String footer,
  }) {
    final adherence = (insights.goalAdherenceRate * 100).round();
    final proteinConsistency = (insights.proteinConsistencyRate * 100).round();
    final weightDelta =
        '${insights.weeklyWeightDeltaKg > 0 ? "+" : ""}${insights.weeklyWeightDeltaKg.toStringAsFixed(2)} kg';

    return '$title\n'
        '$rangeLabel: $dateRangeText\n'
        '$averageCaloriesLabel: ${insights.averageCalories.toStringAsFixed(0)} kcal/$daysUnit\n'
        '$averageProteinLabel: ${insights.averageProtein.toStringAsFixed(1)} g/$daysUnit\n'
        '$averageCarbsLabel: ${insights.averageCarbs.toStringAsFixed(1)} g/$daysUnit\n'
        '$averageFatLabel: ${insights.averageFat.toStringAsFixed(1)} g/$daysUnit\n'
        '$goalAdherenceLabel: $adherence%\n'
        '$proteinConsistencyLabel: $proteinConsistency%\n'
        '$daysTrackedLabel: ${insights.trackedDays} / 7 $daysUnit\n'
        '$weightDeltaLabel: $weightDelta\n$footer';
  }

  @override
  State<WeeklyProgressShareSheet> createState() => _WeeklyProgressShareSheetState();
}

class _WeeklyProgressShareSheetState extends State<WeeklyProgressShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  String _formatDateRange(BuildContext context, DateTime start, DateTime end) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return WeeklyProgressShareSheet.formatWeeklyDateRange(start, end, locale);
  }

  String _buildTextReport(BuildContext context) {
    final strings = S.of(context);
    final insights = widget.insights;
    final dates = _formatDateRange(context, insights.weekStart, insights.weekEnd);
    return WeeklyProgressShareSheet.buildWeeklyProgressTextReport(
      insights: insights,
      dateRangeText: dates,
      title: strings.weeklyShareTextReportTitle,
      rangeLabel: strings.weeklyShareTextReportRange,
      averageCaloriesLabel: strings.weeklyShareTextReportAverageCalories,
      averageProteinLabel: strings.weeklyShareTextReportAverageProtein,
      averageCarbsLabel: strings.weeklyShareTextReportAverageCarbs,
      averageFatLabel: strings.weeklyShareTextReportAverageFat,
      goalAdherenceLabel: strings.weeklyShareTextReportGoalAdherence,
      proteinConsistencyLabel:
          strings.weeklyShareTextReportProteinConsistency,
      daysTrackedLabel: strings.weeklyShareTextReportDaysTracked,
      weightDeltaLabel: strings.weeklyShareTextReportWeightDelta,
      daysUnit: strings.weeklyShareTextReportDayUnit,
      footer: strings.weeklyShareTextReportFooter,
    );
  }

  Future<void> _copyToClipboard() async {
    final text = _buildTextReport(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).weeklyShareCopiedSnackbar),
      ),
    );
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Find repaint boundary
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary not found');
      }

      // Capture image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/macrotracker_weekly_progress.png');
      await file.writeAsBytes(pngBytes);

      // Share via share_plus
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: S.of(context).weeklyShareImageText,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing weekly progress card: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).weeklyShareImageError),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).weeklyShareTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),

          // Scrollable Card Preview
          Flexible(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _cardKey,
                child: _WeeklyProgressCardWidget(
                  insights: widget.insights,
                  dateRangeText: _formatDateRange(context, widget.insights.weekStart, widget.insights.weekEnd),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(S.of(context).weeklyShareCopyText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSharing ? null : _shareImage,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.ios_share_outlined, size: 18),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(S.of(context).weeklyShareShareCard),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgressCardWidget extends StatelessWidget {
  final WeeklyInsightsEntity insights;
  final String dateRangeText;

  const _WeeklyProgressCardWidget({
    required this.insights,
    required this.dateRangeText,
  });

  @override
  Widget build(BuildContext context) {
    final adherence = (insights.goalAdherenceRate * 100).round();
    final proteinConsistency = (insights.proteinConsistencyRate * 100).round();
    final weightDelta = insights.weeklyWeightDeltaKg;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF022C22), // Deep Emerald/Teal 950
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo & Brand Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.insights,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MacroTracker',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  dateRangeText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Calorie Metric
          Text(
            S.of(context).weeklyShareCardDailyAverageUpper,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                ).createShader(bounds),
                child: Text(
                  insights.averageCalories.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).weeklyShareCardKcalPerDay,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Macro distribution row
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  label: S.of(context).weeklyShareCardProteinUpper,
                  value: '${insights.averageProtein.toStringAsFixed(0)}g',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroItem(
                  label: S.of(context).weeklyShareCardCarbsUpper,
                  value: '${insights.averageCarbs.toStringAsFixed(0)}g',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroItem(
                  label: S.of(context).weeklyShareCardFatUpper,
                  value: '${insights.averageFat.toStringAsFixed(0)}g',
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 18),

          // Adherence Rate Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).weeklyShareCardGoalAdherenceUpper,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$adherence%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S
                          .of(context)
                          .weeklyShareCardDaysLogged(insights.trackedDays),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.02),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: insights.goalAdherenceRate,
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                    Text(
                      '$adherence%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Protein consistency & weight
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  label: S.of(context).weeklyShareCardProteinConsistencyUpper,
                  value: '$proteinConsistency%',
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  label: S.of(context).weeklyShareCardWeightChangeUpper,
                  value: '${weightDelta > 0 ? "+" : ""}${weightDelta.toStringAsFixed(2)} kg',
                  icon: Icons.scale_outlined,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),

          // Footer
          Center(
            child: Text(
              S.of(context).weeklyShareCardFooter,
              style: TextStyle(
                color: const Color(0xFF10B981).withValues(alpha: 0.6),
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
