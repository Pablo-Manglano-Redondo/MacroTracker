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

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Panel(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: colorScheme.error),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: colorScheme.error)),
          ],
        ),
      );
    }

    if (_notes == null || _notes!.isEmpty) {
      return Panel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(copy.professionalNotesEmptyTitle,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(copy.professionalNotesEmptyBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notes!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = _notes![index];
        final pinned = note['pinned'] == true;
        final category = note['category'] as String? ?? 'general';
        final title = note['title'] as String? ?? copy.professionalNotesFallbackTitle;
        final body = note['body'] as String? ?? '';

        return Panel(
          accent: pinned ? colorScheme.primaryContainer : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (pinned) ...[
                    Icon(Icons.push_pin, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _categoryColor(category, colorScheme)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _categoryLabel(copy, category),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _categoryColor(category, colorScheme),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (note['created_at'] != null)
                    Text(
                      _formatDate(note['created_at'] as String),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
            ],
          ),
        );
      },
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
