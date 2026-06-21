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
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (_proposals == null || _proposals!.isEmpty) {
      return Panel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.restaurant_outlined, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                S.of(context).professionalRecipesEmptyTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context).professionalRecipesEmptyBody,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _proposals!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final proposal = _proposals![index];
        final recipe = proposal.recipe;
        final isPending = proposal.status == 'pending';

        return Panel(
          accent: isPending ? colorScheme.primaryContainer : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _mealTypeIcon(recipe?.mealType),
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe?.title ?? S.of(context).professionalRecipesRecipeFallback,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (recipe?.description != null && recipe!.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              recipe.description!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _statusChip(proposal.status, colorScheme),
                ],
              ),
              if (recipe != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (recipe.kcal != null) _macroChip(colorScheme, '${recipe.kcal!.toInt()} kcal', Icons.local_fire_department),
                    if (recipe.protein != null) _macroChip(colorScheme, '${recipe.protein!.toInt()}g ${S.of(context).proteinLabel}', Icons.fitness_center),
                    if (recipe.carbs != null) _macroChip(colorScheme, '${recipe.carbs!.toInt()}g ${S.of(context).carbsLabel}', Icons.grain),
                    if (recipe.fat != null) _macroChip(colorScheme, '${recipe.fat!.toInt()}g ${S.of(context).fatLabel}', Icons.water_drop),
                    if (recipe.mealType != null) _macroChip(colorScheme, recipe.mealType!, Icons.schedule),
                  ],
                ),
              ],
              if (proposal.note != null && proposal.note!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${proposal.note}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _updateStatus(proposal.id, 'saved', recipe),
                        icon: const Icon(Icons.bookmark_add, size: 18),
                        label: Text(S.of(context).professionalRecipesSaveToMine),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _updateStatus(proposal.id, 'declined', null),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(S.of(context).professionalRecipesDecline),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status, ColorScheme colorScheme) {
    final (icon, label, bg, fg) = switch (status) {
      'pending' => (Icons.hourglass_empty, S.of(context).professionalSummaryPending, colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      'saved' => (Icons.check_circle, S.of(context).addMealSaved, colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
      'declined' => (Icons.cancel, S.of(context).professionalRecipesDeclined, colorScheme.errorContainer, colorScheme.onErrorContainer),
      _ => (Icons.help_outline, status, colorScheme.surfaceContainerHigh, colorScheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }

  Widget _macroChip(ColorScheme colorScheme, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  IconData _mealTypeIcon(String? mealType) {
    return switch (mealType) {
      'breakfast' => Icons.free_breakfast,
      'lunch' => Icons.lunch_dining,
      'dinner' => Icons.dinner_dining,
      'snack' => Icons.cookie,
      _ => Icons.restaurant,
    };
  }
}
