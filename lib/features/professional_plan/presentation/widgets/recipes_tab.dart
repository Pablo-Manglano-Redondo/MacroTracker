import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_proposed_recipes_usecase.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/generated/l10n.dart';

class RecipesTab extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;

  const RecipesTab({super.key, required this.summary});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  List<ProposedRecipeData>? _proposals;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }

  Future<void> _fetchProposals() async {
    final connection = await locator<ProfessionalPlanRepository>().getActiveConnection();
    if (connection == null || !mounted) {
      setState(() => _loading = false);
      return;
    }
    try {
      final proposals = await locator<GetProposedRecipesUsecase>().execute(connection);
      if (mounted) setState(() { _proposals = proposals; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateStatus(String proposalId, String status, ProfessionalRecipeData? recipe) async {
    try {
      await locator<UpdateProposalStatusUsecase>().execute(
        proposalId: proposalId,
        status: status,
        recipe: recipe,
      );
      _fetchProposals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).professionalRecipesUpdateError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
    } else if (_proposals == null || _proposals!.isEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).professionalRecipesEmptyTitle,
              style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              S.of(context).professionalRecipesEmptyBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      content = Column(
        children: List.generate(_proposals!.length, (index) {
          final proposal = _proposals![index];
          final recipe = proposal.recipe;
          final isPending = proposal.status == 'pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPending
                  ? colorScheme.primary.withValues(alpha: 0.05)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPending
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : colorScheme.outlineVariant.withValues(alpha: 0.15),
                width: isPending ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _mealTypeIcon(recipe?.mealType),
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe?.title ?? S.of(context).professionalRecipesRecipeFallback,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (recipe?.description != null && recipe!.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                recipe.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusChip(proposal.status, colorScheme),
                  ],
                ),
                if (recipe != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (recipe.kcal != null) _macroChip(colorScheme, '${recipe.kcal!.toInt()} kcal', Icons.local_fire_department_rounded),
                      if (recipe.protein != null) _macroChip(colorScheme, '${recipe.protein!.toInt()}g ${S.of(context).proteinLabel}', Icons.fitness_center_rounded),
                      if (recipe.carbs != null) _macroChip(colorScheme, '${recipe.carbs!.toInt()}g ${S.of(context).carbsLabel}', Icons.grain_rounded),
                      if (recipe.fat != null) _macroChip(colorScheme, '${recipe.fat!.toInt()}g ${S.of(context).fatLabel}', Icons.water_drop_rounded),
                      if (recipe.mealType != null) _macroChip(colorScheme, recipe.mealType!, Icons.schedule_rounded),
                    ],
                  ),
                ],
                if (proposal.note != null && proposal.note!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                          width: 3.5,
                        ),
                      ),
                    ),
                    child: Text(
                      '"${proposal.note}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: () => _updateStatus(proposal.id, 'saved', recipe),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                            label: Text(
                              S.of(context).professionalRecipesSaveToMine,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () => _updateStatus(proposal.id, 'declined', null),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text(
                            S.of(context).professionalRecipesDecline,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
            eyebrow: S.of(context).professionalTabRecipes,
            title: S.of(context).professionalRecipesHeaderTitle,
            subtitle: S.of(context).professionalRecipesHeaderSubtitle,
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _statusChip(String status, ColorScheme colorScheme) {
    final (icon, label, bg, fg, border) = switch (status) {
      'pending' => (
          Icons.hourglass_empty_rounded,
          S.of(context).professionalSummaryPending,
          colorScheme.tertiary.withValues(alpha: 0.1),
          colorScheme.tertiary,
          colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      'saved' => (
          Icons.check_circle_rounded,
          S.of(context).addMealSaved,
          colorScheme.primary.withValues(alpha: 0.1),
          colorScheme.primary,
          colorScheme.primary.withValues(alpha: 0.2),
        ),
      'declined' => (
          Icons.cancel_rounded,
          S.of(context).professionalRecipesDeclined,
          colorScheme.error.withValues(alpha: 0.08),
          colorScheme.error,
          colorScheme.error.withValues(alpha: 0.2),
        ),
      _ => (
          Icons.help_outline_rounded,
          status,
          colorScheme.surfaceContainerHigh,
          colorScheme.onSurfaceVariant,
          colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(ColorScheme colorScheme, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _mealTypeIcon(String? mealType) {
    return switch (mealType) {
      'breakfast' => Icons.free_breakfast_rounded,
      'lunch' => Icons.lunch_dining_rounded,
      'dinner' => Icons.dinner_dining_rounded,
      'snack' => Icons.cookie_rounded,
      _ => Icons.restaurant_rounded,
    };
  }
}
