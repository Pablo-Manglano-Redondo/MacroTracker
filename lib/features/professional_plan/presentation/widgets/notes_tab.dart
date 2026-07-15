import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_client_notes_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';

class NotesTab extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;

  const NotesTab({super.key, required this.summary});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  List<Map<String, dynamic>>? _notes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final connection =
        await locator<ProfessionalPlanRepository>().getActiveConnection();
    if (connection == null || !mounted) {
      setState(() => _loading = false);
      return;
    }
    try {
      final notes = await locator<GetClientNotesUsecase>().execute(connection);
      if (mounted) {
        setState(() {
          _notes = notes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final copy = S.of(context);

    Widget content;

    if (_loading) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_error != null) {
      content = Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 40, color: colorScheme.error),
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: colorScheme.error)),
        ],
      );
    } else if (_notes == null || _notes!.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              copy.professionalNotesEmptyTitle,
              style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              copy.professionalNotesEmptyBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    } else {
      content = Column(
        children: List.generate(_notes!.length, (index) {
          final note = _notes![index];
          final pinned = note['pinned'] == true;
          final category = note['category'] as String? ?? 'general';
          final title = note['title'] as String? ?? copy.professionalNotesFallbackTitle;
          final body = note['body'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pinned
                  ? colorScheme.primary.withValues(alpha: 0.05)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pinned
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : colorScheme.outlineVariant.withValues(alpha: 0.15),
                width: pinned ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (pinned) ...[
                      Icon(Icons.push_pin_rounded, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _categoryColor(category, colorScheme).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _categoryColor(category, colorScheme).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _categoryLabel(copy, category),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _categoryColor(category, colorScheme),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (note['created_at'] != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(note['created_at'] as String),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: copy.professionalTabNotes,
            title: copy.professionalNotesHeaderTitle,
            subtitle: copy.professionalNotesHeaderSubtitle,
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Color _categoryColor(String category, ColorScheme cs) {
    return switch (category) {
      'assessment' => cs.tertiary,
      'medical' => cs.error,
      'progress' => cs.secondary,
      'billing' => Colors.amber.shade700,
      'other' => cs.onSurfaceVariant,
      _ => cs.primary,
    };
  }

  String _categoryLabel(S copy, String category) {
    return switch (category) {
      'assessment' => copy.professionalNotesCategoryAssessment,
      'medical' => copy.professionalNotesCategoryMedical,
      'progress' => copy.professionalNotesCategoryProgress,
      'billing' => copy.professionalNotesCategoryBilling,
      'other' => copy.professionalNotesCategoryOther,
      _ => copy.professionalNotesCategoryGeneral,
    };
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }
}
