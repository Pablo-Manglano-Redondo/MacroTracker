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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

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
              Icon(Icons.check_circle, size: 56, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                S.of(context).checkinTabSubmitted,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).checkinTabReviewShortly,
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
          Text(
            _template != null ? _template!.title : S.of(context).checkinTabWeeklyTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).checkinTabShareSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Energy Level
          Text(S.of(context).checkinTabEnergyLevel, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(10, (i) {
              final val = i + 1;
              final selected = _energyLevel == val;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _energyLevel = val),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$val',
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.of(context).checkinTabLow, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text(S.of(context).checkinTabHigh, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),

          // Sleep Hours
          Text(S.of(context).checkinTabSleepHours, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _sleepHours ?? 7,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  label: '${(_sleepHours ?? 7).toStringAsFixed(1)}h',
                  onChanged: (v) => setState(() => _sleepHours = v),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${(_sleepHours ?? 7).toStringAsFixed(1)}h',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dynamic questions
          if (_template != null && _template!.questions.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              isEs ? 'Preguntas del Nutricionista' : 'Nutritionist Questions',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final q in _template!.questions) ...[
              Text(
                q.label,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (q.type == 'text') ...[
                TextField(
                  controller: _textControllers[q.id],
                  decoration: InputDecoration(
                    hintText: isEs ? 'Escribe tu respuesta...' : 'Type your answer...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
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
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$val',
                              style: TextStyle(
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).checkinTabLow, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    Text(S.of(context).checkinTabHigh, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ] else if (q.type == 'boolean') ...[
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(isEs ? 'Sí' : 'Yes'),
                      selected: _answers[q.id] == true,
                      onSelected: (selected) {
                        if (selected) setState(() => _answers[q.id] = true);
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(isEs ? 'No' : 'No'),
                      selected: _answers[q.id] == false,
                      onSelected: (selected) {
                        if (selected) setState(() => _answers[q.id] = false);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
            const Divider(height: 32),
          ],

          // Mood (only if no template is present, to avoid overloading since nutritionist's templates can ask similar questions)
          if (_template == null) ...[
            Text(S.of(context).checkinTabHowFeeling, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _moodController,
              decoration: InputDecoration(
                hintText: S.of(context).checkinTabMoodHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
          ],

          // Notes
          Text(S.of(context).checkinTabAdditionalNotes, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: S.of(context).checkinTabNotesHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13)),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              label: Text(_submitting ? S.of(context).checkinTabSubmitting : S.of(context).checkinTabSubmitButton),
            ),
          ),
        ],
      ),
    );
  }
}
