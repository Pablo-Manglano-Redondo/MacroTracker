import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/core/utils/recipe_factory.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/widgets/meal_replacement_dialog.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';

class MealInterpretationReviewScreen extends StatefulWidget {
  const MealInterpretationReviewScreen({super.key});

  @override
  State<MealInterpretationReviewScreen> createState() =>
      _MealInterpretationReviewScreenState();
}

class _MealInterpretationReviewScreenState
    extends State<MealInterpretationReviewScreen> {
  late MealInterpretationReviewScreenArguments _args;
  final _servingsController = TextEditingController(text: '1');
  InterpretationDraftEntity? _draft;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPersistingEdits = false;
  bool _didLoadDraft = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDraft) {
      return;
    }

    _args = ModalRoute.of(context)?.settings.arguments
            as MealInterpretationReviewScreenArguments? ??
        MealInterpretationReviewScreenArguments(
            '', DateTime.now(), IntakeTypeEntity.breakfast);
    _didLoadDraft = true;
    _loadDraft();
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review draft'),
        actions: [
          IconButton(
            onPressed: _activeItems.isEmpty || _isLoading
                ? null
                : () => _showSaveRecipeDialog(),
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save as recipe',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_draft == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Draft not found or expired.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final activeItems = _activeItems;
    final servings = _parsedServings;
    final adjustedKcal = _draft!.totalKcal * servings;
    final adjustedCarbs = _draft!.totalCarbs * servings;
    final adjustedFat = _draft!.totalFat * servings;
    final adjustedProtein = _draft!.totalProtein * servings;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_draft!.title, style: Theme.of(context).textTheme.headlineSmall),
          if (_draft!.summary != null) ...[
            const SizedBox(height: 8.0),
            Text(_draft!.summary!),
          ],
          const SizedBox(height: 16.0),
          _MacroOverviewCard(
            kcal: adjustedKcal,
            carbs: adjustedCarbs,
            fat: adjustedFat,
            protein: adjustedProtein,
            servings: servings,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _servingsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Servings',
              helperText: 'Adjust the final logged quantity.',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Text(
                'Detected items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8.0),
              TextButton.icon(
                onPressed: _isPersistingEdits ? null : _showAddIngredientFlow,
                icon: const Icon(Icons.add_outlined),
                label: const Text('Add ingredient'),
              ),
              const Spacer(),
              Text(
                _isPersistingEdits
                    ? 'Saving edits...'
                    : '${activeItems.length} active',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: _isPersistingEdits ? FontStyle.italic : null),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.separated(
              itemCount: _draft!.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final item = _draft!.items[index];
                return _DraftItemCard(
                  item: item,
                  onEditPressed:
                      item.editable ? () => _showAmountEditor(item) : null,
                  onReplacePressed:
                      item.editable ? () => _showReplaceDialog(item) : null,
                  onToggleRemoved: () => _toggleRemoved(item),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: activeItems.isEmpty || _isSaving
                  ? null
                  : () => _commitDraft(_draft!),
              child: Text(_isSaving ? 'Saving...' : 'Save meal'),
            ),
          ),
        ],
      ),
    );
  }

  List<InterpretationDraftItemEntity> get _activeItems =>
      _draft?.items.where((item) => !item.removed).toList() ?? const [];

  double get _parsedServings {
    final parsed =
        double.tryParse(_servingsController.text.replaceAll(',', '.')) ?? 1;
    if (parsed <= 0) {
      return 1;
    }
    return parsed;
  }

  Future<void> _loadDraft() async {
    final draft = await locator<CommitInterpretationDraftUsecase>()
        .getDraftById(_args.draftId);
    if (!mounted) {
      return;
    }

    setState(() {
      _draft = draft;
      _isLoading = false;
    });
  }

  Future<void> _showAmountEditor(InterpretationDraftItemEntity item) async {
    final controller = TextEditingController(
      text: item.amount.toStringAsFixed(_decimals(item.amount)),
    );

    final updatedAmount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (${item.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsed =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                return;
              }
              Navigator.of(context).pop(parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (updatedAmount == null) {
      return;
    }

    _updateItemAmount(item, updatedAmount);
  }

  void _updateItemAmount(
      InterpretationDraftItemEntity item, double updatedAmount) {
    if (_draft == null) {
      return;
    }

    final scaleFactor = item.amount <= 0 ? 1.0 : updatedAmount / item.amount;
    final updatedItem = item.copyWith(
      amount: updatedAmount,
      kcal: item.kcal * scaleFactor,
      carbs: item.carbs * scaleFactor,
      fat: item.fat * scaleFactor,
      protein: item.protein * scaleFactor,
    );

    _replaceItem(updatedItem);
  }

  void _toggleRemoved(InterpretationDraftItemEntity item) {
    _replaceItem(item.copyWith(removed: !item.removed));
  }

  Future<void> _showReplaceDialog(InterpretationDraftItemEntity item) async {
    final replacement = await showDialog<MealEntity>(
      context: context,
      builder: (context) => MealReplacementDialog(initialQuery: item.label),
    );

    if (replacement == null) {
      return;
    }

    final nutrition =
        MealPortionCalculator.calculate(replacement, item.amount, item.unit);
    final updatedItem = item.copyWith(
      label: replacement.name ?? item.label,
      matchedMealSnapshot: replacement,
      kcal: nutrition.kcal,
      carbs: nutrition.carbs,
      fat: nutrition.fat,
      protein: nutrition.protein,
      removed: false,
    );
    await _replaceItem(updatedItem);
  }

  Future<void> _showAddIngredientFlow() async {
    final meal = await showDialog<MealEntity>(
      context: context,
      builder: (context) => const MealReplacementDialog(initialQuery: ''),
    );

    if (!mounted || meal == null) {
      return;
    }

    final portion = await showDialog<_IngredientPortionResult>(
      context: context,
      builder: (context) => _IngredientPortionDialog(meal: meal),
    );

    if (!mounted || portion == null) {
      return;
    }

    final nutrition =
        MealPortionCalculator.calculate(meal, portion.amount, portion.unit);
    final item = InterpretationDraftItemEntity(
      id: IdGenerator.getUniqueID(),
      label: meal.name ?? 'Added ingredient',
      matchedMealSnapshot: meal,
      amount: portion.amount,
      unit: portion.unit,
      kcal: nutrition.kcal,
      carbs: nutrition.carbs,
      fat: nutrition.fat,
      protein: nutrition.protein,
      confidenceBand: ConfidenceBandEntity.high,
      editable: true,
      removed: false,
    );

    await _appendItem(item);
  }

  Future<void> _replaceItem(InterpretationDraftItemEntity updatedItem) async {
    if (_draft == null) {
      return;
    }

    final updatedItems = _draft!.items
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();

    final activeItems = updatedItems.where((item) => !item.removed);
    final updatedDraft = _draft!.copyWith(
      items: updatedItems,
      totalKcal:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.kcal),
      totalCarbs:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.carbs),
      totalFat: activeItems.fold<double>(0.0, (sum, item) => sum + item.fat),
      totalProtein:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.protein),
    );

    await _persistUpdatedDraft(updatedDraft);
  }

  Future<void> _appendItem(InterpretationDraftItemEntity item) async {
    if (_draft == null) {
      return;
    }

    final updatedItems = [..._draft!.items, item];
    final updatedDraft = _draft!.copyWith(
      items: updatedItems,
      totalKcal: _draft!.totalKcal + item.kcal,
      totalCarbs: _draft!.totalCarbs + item.carbs,
      totalFat: _draft!.totalFat + item.fat,
      totalProtein: _draft!.totalProtein + item.protein,
    );

    await _persistUpdatedDraft(updatedDraft);
  }

  Future<void> _persistUpdatedDraft(InterpretationDraftEntity updatedDraft) async {
    setState(() {
      _draft = updatedDraft;
      _isPersistingEdits = true;
    });

    try {
      await locator<SaveInterpretationDraftUsecase>().saveDraft(updatedDraft);
      if (!mounted) {
        return;
      }
      setState(() {
        _isPersistingEdits = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPersistingEdits = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save draft changes')),
      );
    }
  }

  Future<void> _commitDraft(InterpretationDraftEntity draft) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await locator<CommitInterpretationDraftUsecase>().commitDraft(
        draft,
        _args.intakeTypeEntity,
        _args.day,
        servings: _parsedServings,
      );
      locator<HomeBloc>().add(const LoadItemsEvent());
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal saved')),
      );
      Navigator.of(context)
          .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this meal')),
      );
    }
  }

  int _decimals(double value) {
    return value % 1 == 0 ? 0 : 2;
  }

  Future<void> _showSaveRecipeDialog() async {
    final draft = _draft;
    if (draft == null || _activeItems.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: draft.title);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save as recipe'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Recipe name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final recipeName = controller.text.trim();
                if (recipeName.isEmpty) {
                  return;
                }

                final recipe = RecipeFactory.fromInterpretationDraft(
                  name: recipeName,
                  draft: draft,
                );
                await locator<SaveRecipeUsecase>().saveRecipe(recipe);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }
}

class _MacroOverviewCard extends StatelessWidget {
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final double servings;

  const _MacroOverviewCard({
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.servings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${kcal.toStringAsFixed(0)} kcal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4.0),
          Text(
            'C ${carbs.toStringAsFixed(1)} | F ${fat.toStringAsFixed(1)} | P ${protein.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 4.0),
          Text(
            '${servings.toStringAsFixed(servings % 1 == 0 ? 0 : 2)} servings to log',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DraftItemCard extends StatelessWidget {
  final InterpretationDraftItemEntity item;
  final VoidCallback? onEditPressed;
  final VoidCallback? onReplacePressed;
  final VoidCallback onToggleRemoved;

  const _DraftItemCard({
    required this.item,
    required this.onEditPressed,
    required this.onReplacePressed,
    required this.onToggleRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = item.removed
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).disabledColor,
            )
        : Theme.of(context).textTheme.titleSmall;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: item.removed
              ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
              : Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.label, style: textStyle),
              ),
              if (onEditPressed != null)
                IconButton(
                  onPressed: item.removed ? null : onEditPressed,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit amount',
                ),
              if (onReplacePressed != null)
                IconButton(
                  onPressed: item.removed ? null : onReplacePressed,
                  icon: const Icon(Icons.swap_horiz_outlined),
                  tooltip: 'Replace ingredient',
                ),
              IconButton(
                onPressed: onToggleRemoved,
                icon:
                    Icon(item.removed ? Icons.undo : Icons.remove_circle_outline),
                tooltip: item.removed ? 'Restore item' : 'Remove item',
              ),
            ],
          ),
          Text(
            '${item.amount.toStringAsFixed(item.amount % 1 == 0 ? 0 : 2)} ${item.unit} | ${item.kcal.toStringAsFixed(0)} kcal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: item.removed ? Theme.of(context).disabledColor : null,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'C ${item.carbs.toStringAsFixed(1)} | F ${item.fat.toStringAsFixed(1)} | P ${item.protein.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: item.removed ? Theme.of(context).disabledColor : null,
                ),
          ),
          if (item.removed) ...[
            const SizedBox(height: 6.0),
            Text(
              'Excluded from the final meal.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class MealInterpretationReviewScreenArguments {
  final String draftId;
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealInterpretationReviewScreenArguments(
      this.draftId, this.day, this.intakeTypeEntity);
}

class _IngredientPortionResult {
  final double amount;
  final String unit;

  const _IngredientPortionResult({
    required this.amount,
    required this.unit,
  });
}

class _IngredientPortionDialog extends StatefulWidget {
  final MealEntity meal;

  const _IngredientPortionDialog({required this.meal});

  @override
  State<_IngredientPortionDialog> createState() =>
      _IngredientPortionDialogState();
}

class _IngredientPortionDialogState extends State<_IngredientPortionDialog> {
  late final TextEditingController _amountController;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = _defaultUnit(widget.meal);
    _amountController = TextEditingController(
      text: _selectedUnit == 'serving' ? '1' : '100',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = _allowedUnits(widget.meal);

    return AlertDialog(
      title: Text(widget.meal.name ?? 'Add ingredient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedUnit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            items: units
                .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedUnit = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount =
                double.tryParse(_amountController.text.replaceAll(',', '.'));
            if (amount == null || amount <= 0) {
              return;
            }
            Navigator.of(context).pop(
              _IngredientPortionResult(amount: amount, unit: _selectedUnit),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  List<String> _allowedUnits(MealEntity meal) {
    if (meal.hasServingValues) {
      return const ['serving', 'g', 'ml', 'g/ml'];
    }
    if (meal.isLiquid) {
      return const ['ml', 'fl.oz', 'g/ml'];
    }
    if (meal.isSolid) {
      return const ['g', 'oz', 'g/ml'];
    }
    return const ['g/ml', 'g', 'ml'];
  }

  String _defaultUnit(MealEntity meal) {
    if (meal.hasServingValues) {
      return 'serving';
    }
    if (meal.isLiquid) {
      return 'ml';
    }
    if (meal.isSolid) {
      return 'g';
    }
    return 'g/ml';
  }
}
