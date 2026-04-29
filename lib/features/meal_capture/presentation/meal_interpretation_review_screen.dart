import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:macrotracker/features/meal_capture/domain/entity/ai_food_memory_entry.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
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
  Map<String, AiFoodMemoryEntry> _savedCorrections = const {};
  List<MealInterpretationSuggestion> _mealSuggestions = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDraft) {
      return;
    }

    _args = ModalRoute.of(context)?.settings.arguments
            as MealInterpretationReviewScreenArguments? ??
        MealInterpretationReviewScreenArguments(
          '',
          DateTime.now(),
          IntakeTypeEntity.breakfast,
        );
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
        title: const Text('Revisar borrador IA'),
        actions: [
          IconButton(
            onPressed: _activeItems.isEmpty || _isLoading
                ? null
                : () => _showSaveRecipeDialog(),
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Guardar como receta',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: _buildBody(context),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    if (_isLoading || _draft == null) {
      return null;
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: FilledButton.icon(
        onPressed: _activeItems.isEmpty || _isSaving
            ? null
            : () => _commitDraft(_draft!),
        icon: Icon(_isSaving ? Icons.hourglass_top_outlined : Icons.check),
        label: Text(_isSaving ? 'Guardando comida...' : 'Guardar comida'),
      ),
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
            'Borrador no encontrado o caducado.',
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
    final gymLabel = _inferGymLabel(_draft!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DraftHeroCard(
          draft: _draft!,
          intakeType: _args.intakeTypeEntity,
          gymLabel: gymLabel,
          activeItemCount: activeItems.length,
          servingsController: _servingsController,
          onServingsChanged: () => setState(() {}),
          onQuickServingSelected: _setQuickServing,
          quickServingValue: _parsedServings,
        ),
        if (_draft!.localImagePath != null &&
            _draft!.localImagePath!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _DraftImagePreviewCard(imagePath: _draft!.localImagePath!),
        ],
        const SizedBox(height: 16),
        _MacroHeroCard(
          kcal: adjustedKcal,
          carbs: adjustedCarbs,
          fat: adjustedFat,
          protein: adjustedProtein,
          servings: servings,
        ),
        if (_mealSuggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _MealSuggestionsCard(
            suggestions: _mealSuggestions,
            onApply: _applyMealSuggestion,
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ingredientes detectados',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Text(
                      _isPersistingEdits
                          ? 'Guardando cambios...'
                          : '${activeItems.length} activos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle:
                                _isPersistingEdits ? FontStyle.italic : null,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          _isPersistingEdits ? null : _showAddIngredientFlow,
                      icon: const Icon(Icons.add_outlined),
                      label: const Text('Añadir ingrediente'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _activeItems.isEmpty || _isPersistingEdits
                          ? null
                          : () => _showSaveRecipeDialog(),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Guardar receta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._draft!.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Builder(
              builder: (_) {
                final saved = _savedCorrections[_correctionKey(item.label)];
                final savedLabel = saved == null
                    ? null
                    : '${saved.amount.toStringAsFixed(saved.amount % 1 == 0 ? 0 : 1)} ${saved.unit}';
                return _DraftItemCard(
                  item: item,
                  unitPresets: _quickUnitsForItem(item),
                  savedCorrectionLabel: savedLabel,
                  onEditPressed:
                      item.editable ? () => _showAmountEditor(item) : null,
                  onReplacePressed:
                      item.editable ? () => _showReplaceDialog(item) : null,
                  onUnitSelected: item.editable
                      ? (unit) => _applyUnitPreset(item, unit)
                      : null,
                  onPresetSelected: item.editable
                      ? (factor) => _applyPortionPreset(item, factor)
                      : null,
                  onApplySavedCorrection: item.editable && saved != null
                      ? () => _applySavedCorrection(item)
                      : null,
                  onToggleRemoved: () => _toggleRemoved(item),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 90),
      ],
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
    final corrections = await _loadSavedCorrections();
    final suggestions = draft == null
        ? const <MealInterpretationSuggestion>[]
        : await locator<MealInterpretationPersonalizationUsecase>()
            .suggestMealsForDraft(
            draft: draft,
            intakeType: _args.intakeTypeEntity,
          );
    if (!mounted) {
      return;
    }

    setState(() {
      _draft = draft;
      _isLoading = false;
      _savedCorrections = corrections;
      _mealSuggestions = suggestions;
    });
  }

  void _setQuickServing(double value) {
    _servingsController.text = value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
    setState(() {});
  }

  Future<void> _showAmountEditor(InterpretationDraftItemEntity item) async {
    final controller = TextEditingController(
      text: item.amount.toStringAsFixed(_decimals(item.amount)),
    );

    final updatedAmount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${item.label}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Cantidad (${item.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
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
            child: const Text('Guardar'),
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

    _saveCorrection(updatedItem);
    _replaceItem(updatedItem);
  }

  void _applyPortionPreset(InterpretationDraftItemEntity item, double factor) {
    if (factor <= 0) {
      return;
    }
    _updateItemAmount(item, item.amount * factor);
  }

  Future<void> _applyUnitPreset(
      InterpretationDraftItemEntity item, String updatedUnit) async {
    if (_draft == null || item.unit == updatedUnit) {
      return;
    }

    InterpretationDraftItemEntity updatedItem;
    final meal = item.matchedMealSnapshot;
    if (meal != null) {
      final nutrition =
          MealPortionCalculator.calculate(meal, item.amount, updatedUnit);
      updatedItem = item.copyWith(
        unit: updatedUnit,
        kcal: nutrition.kcal,
        carbs: nutrition.carbs,
        fat: nutrition.fat,
        protein: nutrition.protein,
      );
    } else {
      updatedItem = item.copyWith(unit: updatedUnit);
    }

    await _saveCorrection(updatedItem);
    await _replaceItem(updatedItem);
  }

  Future<void> _applySavedCorrection(InterpretationDraftItemEntity item) async {
    final correction = _savedCorrections[_correctionKey(item.label)];
    if (correction == null) {
      return;
    }

    InterpretationDraftItemEntity updatedItem;
    final meal = correction.mealSnapshot ?? item.matchedMealSnapshot;
    if (meal != null) {
      final nutrition = MealPortionCalculator.calculate(
        meal,
        correction.amount,
        correction.unit,
      );
      updatedItem = item.copyWith(
        label: correction.displayLabel,
        matchedMealSnapshot: meal,
        amount: correction.amount,
        unit: correction.unit,
        kcal: nutrition.kcal,
        carbs: nutrition.carbs,
        fat: nutrition.fat,
        protein: nutrition.protein,
      );
    } else {
      updatedItem = item.copyWith(
        amount: correction.amount,
        unit: correction.unit,
      );
    }

    await _saveCorrection(updatedItem);
    await _replaceItem(updatedItem);
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
    await _saveCorrection(updatedItem);
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
      totalKcal: activeItems.fold<double>(0.0, (sum, item) => sum + item.kcal),
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

  Future<void> _persistUpdatedDraft(
      InterpretationDraftEntity updatedDraft) async {
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
        const SnackBar(content: Text('No se pudieron guardar los cambios del borrador')),
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
      await locator<MealInterpretationPersonalizationUsecase>()
          .saveMealMemoryFromDraft(
        draft: draft,
        intakeType: _args.intakeTypeEntity,
      );
      locator<HomeBloc>().add(const LoadItemsEvent());
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comida guardada')),
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
        const SnackBar(content: Text('No se pudo guardar esta comida')),
      );
    }
  }

  int _decimals(double value) {
    return value % 1 == 0 ? 0 : 2;
  }

  String _inferGymLabel(InterpretationDraftEntity draft) {
    final protein = draft.totalProtein;
    final carbs = draft.totalCarbs;
    final fat = draft.totalFat;
    final kcal = draft.totalKcal;

    if (protein >= 35 && carbs >= 45) {
      return 'Post entreno';
    }
    if (carbs >= 50 && fat <= 20) {
      return 'Pre entreno';
    }
    if (protein >= 35 && fat <= 20) {
      return 'Alta en proteína';
    }
    if (kcal <= 550 && fat <= 18) {
      return 'Ligera para definición';
    }
    return 'Balanceada';
  }

  List<String> _quickUnitsForItem(InterpretationDraftItemEntity item) {
    final meal = item.matchedMealSnapshot;
    if (meal == null) {
      final defaults = <String>{item.unit, 'serving', 'g', 'ml'};
      return defaults.where((value) => value.trim().isNotEmpty).toList();
    }
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

  String _correctionKey(String label) =>
      label.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<Map<String, AiFoodMemoryEntry>> _loadSavedCorrections() async {
    final box = await Hive.openBox(
      MealInterpretationPersonalizationUsecase.aiMemoryBoxName,
    );
    final loaded = <String, AiFoodMemoryEntry>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final entry = AiFoodMemoryEntry.fromMap(key.toString(), raw);
        if (entry.amount > 0 && entry.unit.trim().isNotEmpty) {
          loaded[key.toString()] = entry;
        }
      }
    }
    return loaded;
  }

  Future<void> _saveCorrection(InterpretationDraftItemEntity item) async {
    final key = _correctionKey(item.label);
    if (key.isEmpty || item.amount <= 0 || item.unit.trim().isEmpty) {
      return;
    }

    final previous = _savedCorrections[key];
    final correction = AiFoodMemoryEntry(
      key: key,
      displayLabel: item.label,
      amount: item.amount,
      unit: item.unit,
      kcal: item.kcal,
      carbs: item.carbs,
      fat: item.fat,
      protein: item.protein,
      mealSnapshot: item.matchedMealSnapshot ?? previous?.mealSnapshot,
      uses: (previous?.uses ?? 0) + 1,
      updatedAt: DateTime.now(),
    );
    final updated = Map<String, AiFoodMemoryEntry>.from(_savedCorrections);
    updated[key] = correction;
    if (mounted) {
      setState(() {
        _savedCorrections = updated;
      });
    } else {
      _savedCorrections = updated;
    }

    final box = await Hive.openBox(
      MealInterpretationPersonalizationUsecase.aiMemoryBoxName,
    );
    await box.put(key, correction.toMap());
  }

  Future<void> _applyMealSuggestion(
      MealInterpretationSuggestion suggestion) async {
    if (_draft == null) {
      return;
    }

    final nutrition = MealPortionCalculator.calculate(
      suggestion.meal,
      suggestion.defaultAmount,
      suggestion.defaultUnit,
    );
    final item = InterpretationDraftItemEntity(
      id: IdGenerator.getUniqueID(),
      label: suggestion.title,
      matchedMealSnapshot: suggestion.meal,
      amount: suggestion.defaultAmount,
      unit: suggestion.defaultUnit,
      kcal: nutrition.kcal,
      carbs: nutrition.carbs,
      fat: nutrition.fat,
      protein: nutrition.protein,
      confidenceBand: ConfidenceBandEntity.high,
      editable: true,
      removed: false,
    );
    final updatedDraft = _draft!.copyWith(
      title: suggestion.title,
      summary:
          'Sustituido por ${suggestion.sourceLabel.toLowerCase()} para mejorar la precisión.',
      totalKcal: nutrition.kcal,
      totalCarbs: nutrition.carbs,
      totalFat: nutrition.fat,
      totalProtein: nutrition.protein,
      confidenceBand: ConfidenceBandEntity.high,
      items: [item],
    );

    await _saveCorrection(item);
    await _persistUpdatedDraft(updatedDraft);
    if (!mounted) {
      return;
    }
    setState(() {
      _mealSuggestions = const [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aplicada sugerencia: ${suggestion.title}')),
    );
  }

  Future<void> _showSaveRecipeDialog() async {
    final draft = _draft;
    if (draft == null || _activeItems.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: draft.title);
    bool favorite = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Guardar como receta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la receta',
                      helperText:
                          'Usa nombres como avena pre, pollo arroz post o batido.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: favorite,
                    onChanged: (value) {
                      setDialogState(() {
                        favorite = value ?? true;
                      });
                    },
                    title: const Text('Favorita para acceso rápido'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
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
                    ).copyWith(favorite: favorite);
                    await locator<SaveRecipeUsecase>().saveRecipe(recipe);

                    if (!dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receta guardada')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }
}

class _DraftImagePreviewCard extends StatefulWidget {
  final String imagePath;

  const _DraftImagePreviewCard({required this.imagePath});

  @override
  State<_DraftImagePreviewCard> createState() => _DraftImagePreviewCardState();
}

class _DraftImagePreviewCardState extends State<_DraftImagePreviewCard> {
  bool _cropPreview = true;

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);
    if (!file.existsSync()) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto capturada',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca para ampliar. Alterna recorte/ajuste para inspección rápida.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openZoomDialog(file),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    file,
                    fit: _cropPreview ? BoxFit.cover : BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        alignment: Alignment.center,
                        child: Text(
                          'No se pudo cargar la vista previa',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _cropPreview = !_cropPreview;
                  });
                },
                icon: Icon(
                  _cropPreview
                      ? Icons.crop_outlined
                      : Icons.fit_screen_outlined,
                ),
                label: Text(_cropPreview ? 'Recorte' : 'Ajuste'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openZoomDialog(File imageFile) async {
    bool cropDialog = _cropPreview;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Zoom de la foto',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              cropDialog = !cropDialog;
                            });
                          },
                          icon: Icon(cropDialog
                              ? Icons.crop_outlined
                              : Icons.fit_screen_outlined),
                          label: Text(cropDialog ? 'Recorte' : 'Ajuste'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 6,
                          child: Image.file(
                            imageFile,
                            fit: cropDialog ? BoxFit.cover : BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DraftHeroCard extends StatelessWidget {
  final InterpretationDraftEntity draft;
  final IntakeTypeEntity intakeType;
  final String gymLabel;
  final int activeItemCount;
  final TextEditingController servingsController;
  final VoidCallback onServingsChanged;
  final ValueChanged<double> onQuickServingSelected;
  final double quickServingValue;

  const _DraftHeroCard({
    required this.draft,
    required this.intakeType,
    required this.gymLabel,
    required this.activeItemCount,
    required this.servingsController,
    required this.onServingsChanged,
    required this.onQuickServingSelected,
    required this.quickServingValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.08),
          colorScheme.surfaceContainerLow,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DraftChip(
                icon: draft.sourceType == DraftSourceEntity.photo
                    ? Icons.camera_alt_outlined
                    : Icons.notes_outlined,
                label: draft.sourceType == DraftSourceEntity.photo
                    ? 'Foto IA'
                    : 'Texto IA',
              ),
              _DraftChip(
                icon: Icons.restaurant_outlined,
                label: intakeType.name,
              ),
              _DraftChip(
                icon: Icons.layers_outlined,
                label: '$activeItemCount ingredientes',
              ),
              _DraftChip(
                icon: Icons.fitness_center_outlined,
                label: gymLabel,
              ),
              _DraftChip(
                icon: _confidenceIcon(draft.confidenceBand),
                label: _confidenceLabel(draft.confidenceBand),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            draft.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (draft.summary != null && draft.summary!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              draft.summary!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Raciones a guardar',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [0.5, 1.0, 1.5, 2.0]
                .map(
                  (value) => ChoiceChip(
                    label: Text(
                      value % 1 == 0 ? value.toInt().toString() : '$value',
                    ),
                    selected: quickServingValue == value,
                    onSelected: (_) => onQuickServingSelected(value),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: servingsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Raciones personalizadas',
              helperText: 'Ajusta la ración final antes de guardar.',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => onServingsChanged(),
          ),
        ],
      ),
    );
  }

  static String _confidenceLabel(ConfidenceBandEntity band) {
    switch (band) {
      case ConfidenceBandEntity.high:
        return 'Confianza alta';
      case ConfidenceBandEntity.medium:
        return 'Confianza media';
      case ConfidenceBandEntity.low:
        return 'Confianza baja';
    }
  }

  static IconData _confidenceIcon(ConfidenceBandEntity band) {
    switch (band) {
      case ConfidenceBandEntity.high:
        return Icons.verified_outlined;
      case ConfidenceBandEntity.medium:
        return Icons.rule_folder_outlined;
      case ConfidenceBandEntity.low:
        return Icons.error_outline;
    }
  }
}

class _MealSuggestionsCard extends StatelessWidget {
  final List<MealInterpretationSuggestion> suggestions;
  final ValueChanged<MealInterpretationSuggestion> onApply;

  const _MealSuggestionsCard({
    required this.suggestions,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coincidencias tuyas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Usa una comida frecuente, receta o corrección previa si se parece más a lo que has comido.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            ...suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onApply(suggestion),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceContainerHighest,
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: colorScheme.primary.withValues(alpha: 0.14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.auto_fix_high_outlined,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${suggestion.sourceLabel} • ${suggestion.defaultAmount.toStringAsFixed(suggestion.defaultAmount % 1 == 0 ? 0 : 1)} ${suggestion.defaultUnit}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => onApply(suggestion),
                          child: const Text('Usar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroHeroCard extends StatelessWidget {
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final double servings;

  const _MacroHeroCard({
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.servings,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                        '${kcal.toStringAsFixed(0)} kcal',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${servings.toStringAsFixed(servings % 1 == 0 ? 0 : 2)} servings ready to log',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    'Editable',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MacroTile(
                  label: 'Proteína',
                  value: '${protein.toStringAsFixed(1)} g',
                  accentColor: colorScheme.primary,
                ),
                _MacroTile(
                  label: 'Carbohidratos',
                  value: '${carbs.toStringAsFixed(1)} g',
                  accentColor: colorScheme.tertiary,
                ),
                _MacroTile(
                  label: 'Grasas',
                  value: '${fat.toStringAsFixed(1)} g',
                  accentColor: const Color(0xFFE7A83B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accentColor.withValues(alpha: 0.12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _DraftItemCard extends StatelessWidget {
  final InterpretationDraftItemEntity item;
  final List<String> unitPresets;
  final String? savedCorrectionLabel;
  final VoidCallback? onEditPressed;
  final VoidCallback? onReplacePressed;
  final ValueChanged<String>? onUnitSelected;
  final ValueChanged<double>? onPresetSelected;
  final VoidCallback? onApplySavedCorrection;
  final VoidCallback onToggleRemoved;

  const _DraftItemCard({
    required this.item,
    required this.unitPresets,
    required this.savedCorrectionLabel,
    required this.onEditPressed,
    required this.onReplacePressed,
    required this.onUnitSelected,
    required this.onPresetSelected,
    required this.onApplySavedCorrection,
    required this.onToggleRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = item.removed
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).disabledColor,
            )
        : Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: textStyle),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DraftChip(
                            icon: Icons.scale_outlined,
                            label:
                                '${item.amount.toStringAsFixed(item.amount % 1 == 0 ? 0 : 2)} ${item.unit}',
                          ),
                          _DraftChip(
                            icon: Icons.local_fire_department_outlined,
                            label: '${item.kcal.toStringAsFixed(0)} kcal',
                          ),
                          _ConfidenceChip(band: item.confidenceBand),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: unitPresets
                            .map(
                              (unit) => ChoiceChip(
                                label: Text(unit),
                                selected: item.unit == unit,
                                onSelected:
                                    item.removed || onUnitSelected == null
                                        ? null
                                        : (_) => onUnitSelected!(unit),
                              ),
                            )
                            .toList(),
                      ),
                      if (savedCorrectionLabel != null) ...[
                        const SizedBox(height: 8),
                        _PresetChip(
                          label: 'Usar habitual: $savedCorrectionLabel',
                          onTap: item.removed ? null : onApplySavedCorrection,
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: !item.removed,
                  onChanged: (_) => onToggleRemoved(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'C ${item.carbs.toStringAsFixed(1)}  |  F ${item.fat.toStringAsFixed(1)}  |  P ${item.protein.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: item.removed
                        ? Theme.of(context).disabledColor
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(
                  label: 'Pequeña',
                  onTap: item.removed || onPresetSelected == null
                      ? null
                      : () => onPresetSelected!(0.75),
                ),
                _PresetChip(
                  label: 'Media',
                  onTap: item.removed || onPresetSelected == null
                      ? null
                      : () => onPresetSelected!(1.0),
                ),
                _PresetChip(
                  label: 'Grande',
                  onTap: item.removed || onPresetSelected == null
                      ? null
                      : () => onPresetSelected!(1.25),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: item.removed ? null : onEditPressed,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Cantidad'),
                ),
                OutlinedButton.icon(
                  onPressed: item.removed ? null : onReplacePressed,
                  icon: const Icon(Icons.swap_horiz_outlined),
                  label: const Text('Sustituir'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleRemoved,
                  icon: Icon(
                    item.removed
                        ? Icons.undo_outlined
                        : Icons.remove_circle_outline,
                  ),
                  label: Text(item.removed ? 'Restaurar' : 'Quitar'),
                ),
              ],
            ),
            if (item.removed) ...[
              const SizedBox(height: 10),
              Text(
                'Excluido de la comida final.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.straighten, size: 16),
      onPressed: onTap,
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  final ConfidenceBandEntity band;

  const _ConfidenceChip({required this.band});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (band) {
      case ConfidenceBandEntity.high:
        color = Colors.green;
        label = 'Confianza alta';
        break;
      case ConfidenceBandEntity.medium:
        color = Colors.orange;
        label = 'Confianza media';
        break;
      case ConfidenceBandEntity.low:
        color = Colors.red;
        label = 'Confianza baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.traffic_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DraftChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DraftChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedUnit,
            decoration: const InputDecoration(
              labelText: 'Unidad',
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
          child: const Text('Cancelar'),
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
          child: const Text('Añadir'),
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
