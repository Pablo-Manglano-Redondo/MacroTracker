import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';

class SummaryTab extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ValueChanged<String> onUpdateDailyNote;

  const SummaryTab({
    super.key,
    required this.summary,
    required this.onUpdateDailyNote,
  });

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  late final TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController =
        TextEditingController(text: widget.summary.dailyNote ?? '');
    _noteController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // Re-build to show/hide undo button
  }

  @override
  void didUpdateWidget(SummaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.summary.dailyNote != oldWidget.summary.dailyNote && !_isSaving) {
      _noteController.text = widget.summary.dailyNote ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.removeListener(_onTextChanged);
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final syncStatus = widget.summary.syncStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: S.of(context).professionalSummaryOperationsEyebrow,
                title: S.of(context).professionalTabSummary,
                subtitle: S.of(context).professionalSummaryOperationsSubtitle,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusPill(
                    icon: Icons.assignment_outlined,
                    label: widget.summary.activePlan?.name ??
                        S.of(context).professionalSummaryNoPlan,
                  ),
                  StatusPill(
                    icon: Icons.local_fire_department_outlined,
                    label: widget.summary.todayTarget == null
                        ? S.of(context).professionalSummaryPending
                        : '${widget.summary.todayTarget!.kcalGoal.round()} kcal',
                  ),
                  StatusPill(
                    icon: Icons.sync_outlined,
                    label: S.of(context).professionalHubPendingCount(syncStatus.pendingSyncCount),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SyncRail(
                rows: [
                  (
                    S.of(context).professionalSummaryLastPlanUpdate,
                    formatDateTime(context, syncStatus.lastPlanSyncAt),
                  ),
                  (
                    S.of(context).professionalSummaryLastSnapshot,
                    formatDateTime(context, syncStatus.lastSnapshotSyncAt),
                  ),
                  (
                    S.of(context).professionalSummaryConnectionStatus,
                    syncStatus.connectionStatus,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (widget.summary.activePlan == null)
          _EmptyPlanPlaceholder(summary: widget.summary)
        else
          Panel(
            accent: colorScheme.primary.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  eyebrow: S.of(context).todayLabel,
                  title: S.of(context).professionalSummaryTodayPlanVsReality,
                  subtitle: S.of(context).professionalSharingPendingSnapshots(
                        widget.summary.syncStatus.pendingSyncCount,
                      ),
                ),
                const SizedBox(height: 20),

                // Beautiful Calorie Circle and Adherence
                _CalorieOverviewRing(
                  actual: widget.summary.today.kcalActual,
                  target: widget.summary.today.kcalTarget,
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Row of beautiful concentric-like macro rings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MacroRingItem(
                      label: S.of(context).professionalMacroProtein,
                      actual: widget.summary.today.proteinActual,
                      target: widget.summary.today.proteinTarget,
                      color: const Color(0xFF10B981),
                      unit: 'g',
                    ),
                    _MacroRingItem(
                      label: S.of(context).professionalMacroCarbs,
                      actual: widget.summary.today.carbsActual,
                      target: widget.summary.today.carbsTarget,
                      color: const Color(0xFFE7A83B),
                      unit: 'g',
                    ),
                    _MacroRingItem(
                      label: S.of(context).professionalMacroFat,
                      actual: widget.summary.today.fatActual,
                      target: widget.summary.today.fatTarget,
                      color: const Color(0xFF3B82F6),
                      unit: 'g',
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Daily Context Note Section
                Text(
                  S.of(context).professionalSummaryDailyContextTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).professionalSummaryDailyContextSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: S.of(context).professionalSummaryDailyContextHint,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_noteController.text !=
                        (widget.summary.dailyNote ?? ''))
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _noteController.text =
                                widget.summary.dailyNote ?? '';
                          });
                        },
                        icon: const Icon(Icons.undo_rounded, size: 18),
                        label: Text(S.of(context).professionalSummaryUndo),
                      ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              try {
                                widget.onUpdateDailyNote(_noteController.text);
                              } catch (_) {}
                              setState(() => _isSaving = false);
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(
                        _isSaving
                            ? S.of(context).professionalSummarySavingNote : S.of(context).professionalSummarySaveNote,
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalorieOverviewRing extends StatelessWidget {
  final double actual;
  final double target;

  const _CalorieOverviewRing({
    required this.actual,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = target <= 0 ? 0.0 : (actual / target).clamp(0.0, 1.0);
    final remaining = (target - actual).round();
    final isOver = remaining < 0;

    return Row(
      children: [
        CircularPercentIndicator(
          radius: 54.0,
          lineWidth: 10.0,
          animation: true,
          percent: percent,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${actual.round()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                '/ ${target.round()}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: isOver ? colorScheme.error : colorScheme.primary,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOver
                    ? S.of(context).professionalSummaryTargetExceeded
                    : S.of(context).professionalSummaryRemainingKcal,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                isOver ? '+${remaining.abs()} kcal' : '$remaining kcal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isOver ? colorScheme.error : colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).professionalSummaryCalorieProgressBody,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRingItem extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final Color color;
  final String unit;

  const _MacroRingItem({
    required this.label,
    required this.actual,
    required this.target,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = target <= 0 ? 0.0 : (actual / target).clamp(0.0, 1.0);

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 36.0,
          lineWidth: 7.0,
          animation: true,
          percent: percent,
          center: Text(
            '${(percent * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '${actual.round()}$unit / ${target.round()}$unit',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

class _SyncRail extends StatelessWidget {
  final List<(String, String)> rows;

  const _SyncRail({required this.rows});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _SyncRow(label: rows[i].$1, value: rows[i].$2),
            if (i != rows.length - 1) ...[
              const SizedBox(height: 10),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final String label;
  final String value;

  const _SyncRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _EmptyPlanPlaceholder extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;

  const _EmptyPlanPlaceholder({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Panel(
      accent: Color.alphaBlend(
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
        Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: S.of(context).professionalSummaryNoPublishedPlan,
            title: S.of(context).professionalConnectedNoPlan,
            subtitle: S.of(context).professionalEmptyPlanBody,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusPill(
                icon: Icons.schedule_outlined,
                label: S.of(context).professionalEmptyPlanSync(
                      formatDateTime(
                          context, summary.syncStatus.lastPlanSyncAt),
                    ),
              ),
              StatusPill(
                icon: Icons.link_outlined,
                label: summary.connection.professionalName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
