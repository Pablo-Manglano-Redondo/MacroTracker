import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/submit_checkin_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_checkin_template_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/generated/l10n.dart';

class CheckinTab extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;

  const CheckinTab({super.key, required this.summary});

  @override
  State<CheckinTab> createState() => _CheckinTabState();
}

class _CheckinTabState extends State<CheckinTab> {
  int? _energyLevel;
  double? _sleepHours;
  final _moodController = TextEditingController();
  final _notesController = TextEditingController();
  
  CheckinTemplateEntity? _template;
  bool _loadingTemplate = true;
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};

  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTemplate();
  }

  @override
  void dispose() {
    _moodController.dispose();
    _notesController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchTemplate() async {
    final connection = await locator<ProfessionalPlanRepository>().getActiveConnection();
    if (connection == null) {
      if (mounted) setState(() => _loadingTemplate = false);
      return;
    }
    try {
      final template = await locator<GetCheckinTemplateUsecase>().execute(
        professionalId: connection.professionalId,
      );
      if (mounted) {
        setState(() {
          _template = template;
          _loadingTemplate = false;
          if (template != null) {
            for (final q in template.questions) {
              if (q.type == 'boolean') {
                _answers[q.id] = false;
              } else if (q.type == 'rating') {
                _answers[q.id] = 5;
              } else {
                _answers[q.id] = '';
                _textControllers[q.id] = TextEditingController();
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingTemplate = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _submit() async {
    final connection = await locator<ProfessionalPlanRepository>().getActiveConnection();
    if (connection == null) return;

    setState(() { _submitting = true; _error = null; });

    // Collect answers from text controllers
    for (final qId in _textControllers.keys) {
      _answers[qId] = _textControllers[qId]?.text ?? '';
    }

    try {
      await locator<SubmitCheckinUsecase>().execute(
        connection: connection,
        requestId: widget.summary.pendingCheckinRequest?.id,
        templateId: _template?.id,
        answers: _answers,
        energyLevel: _energyLevel,
        sleepHours: _sleepHours,
        mood: _moodController.text.isNotEmpty ? _moodController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      if (mounted) setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _submitting = false; });
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String hintText) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_loadingTemplate) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_submitted) {
      return Panel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.check_circle_rounded, size: 56, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                widget.summary.pendingCheckinRequest != null
                    ? 'Enviado, pendiente de revisión'
                    : S.of(context).checkinTabSubmitted,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                widget.summary.pendingCheckinRequest != null
                    ? 'Tu nutricionista recibirá este check-in para revisarlo.'
                    : S.of(context).checkinTabReviewShortly,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _submitted = false;
                    _energyLevel = null;
                    _sleepHours = null;
                    _moodController.clear();
                    _notesController.clear();
                    for (final c in _textControllers.values) {
                      c.clear();
                    }
                    _answers.clear();
                    if (_template != null) {
                      for (final q in _template!.questions) {
                        if (q.type == 'boolean') {
                          _answers[q.id] = false;
                        } else if (q.type == 'rating') {
                          _answers[q.id] = 5;
                        } else {
                          _answers[q.id] = '';
                        }
                      }
                    }
                  });
                },
                child: Text(S.of(context).checkinTabSubmitAnother),
              ),
            ],
          ),
        ),
      );
    }

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.summary.pendingCheckinRequest != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notification_important_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu nutricionista ha pedido este check-in',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Completa el formulario para cerrar la solicitud pendiente.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionHeader(
            eyebrow: S.of(context).checkinTabWeeklyTitle,
            title: _template != null ? _template!.title : S.of(context).checkinTabWeeklyTitle,
            subtitle: S.of(context).checkinTabShareSubtitle,
          ),
          const SizedBox(height: 24),

          // Energy Level
          Text(
            S.of(context).checkinTabEnergyLevel,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(10, (i) {
              final val = i + 1;
              final selected = _energyLevel == val;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _energyLevel = val),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primary : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$val',
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).checkinTabLow, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
              Text(S.of(context).checkinTabHigh, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),

          // Sleep Hours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).checkinTabSleepHours,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text(
                '${(_sleepHours ?? 7).toStringAsFixed(1)}h',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.12),
              trackHeight: 5,
            ),
            child: Slider(
              value: _sleepHours ?? 7,
              min: 0,
              max: 12,
              divisions: 24,
              onChanged: (v) => setState(() => _sleepHours = v),
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic questions
          if (_template != null && _template!.questions.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              S.of(context).checkinTabNutritionistQuestions,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final q in _template!.questions) ...[
              Text(
                q.label,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 10),
              if (q.type == 'text') ...[
                TextField(
                  controller: _textControllers[q.id],
                  decoration: _inputDecoration(context, S.of(context).checkinTabAnswerHint),
                  maxLines: 3,
                ),
              ] else if (q.type == 'rating') ...[
                Row(
                  children: List.generate(10, (i) {
                    final val = i + 1;
                    final selected = _answers[q.id] == val;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _answers[q.id] = val),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected ? colorScheme.primary : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? Colors.transparent : colorScheme.outlineVariant.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$val',
                              style: TextStyle(
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).checkinTabLow, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    Text(S.of(context).checkinTabHigh, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  ],
                ),
              ] else if (q.type == 'boolean') ...[
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(S.of(context).dialogYesLabel),
                      selected: _answers[q.id] == true,
                      onSelected: (selected) {
                        if (selected) setState(() => _answers[q.id] = true);
                      },
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _answers[q.id] == true ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(S.of(context).dialogNoLabel),
                      selected: _answers[q.id] == false,
                      onSelected: (selected) {
                        if (selected) setState(() => _answers[q.id] = false);
                      },
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _answers[q.id] == false ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
            const Divider(height: 32),
          ],

          // Mood (only if no template is present, to avoid overloading)
          if (_template == null) ...[
            Text(
              S.of(context).checkinTabHowFeeling,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _moodController,
              decoration: _inputDecoration(context, S.of(context).checkinTabMoodHint),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
          ],

          // Notes
          Text(
            S.of(context).checkinTabAdditionalNotes,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            decoration: _inputDecoration(context, S.of(context).checkinTabNotesHint),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _submitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _submitting ? S.of(context).checkinTabSubmitting : S.of(context).checkinTabSubmitButton,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
