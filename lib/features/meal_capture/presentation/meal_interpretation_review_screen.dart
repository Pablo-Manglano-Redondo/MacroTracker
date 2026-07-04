import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/core/presentation/widgets/food_quality_score_card.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
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
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

// ──────────────────────────────────────────────────────────────────────
// Visual palette constants
// ──────────────────────────────────────────────────────────────────────
const _kBgColor = Color(0xFFF7F8F5);
const _kCardColor = Color(0xFFFFFFFF);
const _kPrimaryGreen = Color(0xFF0F8A4B);
const _kDarkText = Color(0xFF181D1A);
const _kMutedText = Color(0xFF68736C);
const _kSoftBorder = Color(0xFFE6ECE7);
const _kCardRadius = 24.0;
const _kInputRadius = 16.0;
const _kChipRadius = 999.0;
const _kCardShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

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
  bool _showCustomServings = false;
  Map<String, AiFoodMemoryEntry> _savedCorrections = const {};
  List<MealInterpretationSuggestion> _mealSuggestions = const [];
  late final CalculateFoodQualityScoreUsecase _foodQualityScorer;

  @override
  void initState() {
    super.initState();
    _foodQualityScorer = locator<CalculateFoodQualityScoreUsecase>();
  }

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

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: AppBar(
        backgroundColor: _kBgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          S.of(context).aiReviewDraftTitle,
          style: const TextStyle(
            color: _kDarkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _kDarkText),
            onSelected: (value) {
              if (value == 'recipe') {
                _showSaveRecipeDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recipe',
                enabled: _activeItems.isNotEmpty && !_isLoading,
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_add_outlined, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context).aiSaveAsRecipe,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomCta(context),
      body: _buildBody(context),
    );
  }

  Widget? _buildStickyBottomCta(BuildContext context) {
    if (_isLoading || _draft == null) {
      return null;
    }

    final servings = _parsedServings;
    final adjustedKcal = _draft!.totalKcal * servings;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _kBgColor,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _activeItems.isEmpty || _isSaving
                ? null
                : () => _commitDraft(_draft!),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _kPrimaryGreen.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              shadowColor: _kPrimaryGreen.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kChipRadius),
              ),
            ),
            child: Text(
              _isSaving
                  ? S.of(context).aiSavingMeal
                  : '${S.of(context).aiSaveMeal} · ${adjustedKcal.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kPrimaryGreen));
    }

    if (_draft == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            S.of(context).aiDraftNotFound,
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
    final foodQualityScore = _foodQualityScorer.scoreDraft(_draft!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // 1. Compact summary card
        _CompactSummaryCard(
          draft: _draft!,
          intakeType: _args.intakeTypeEntity,
          adjustedKcal: adjustedKcal,
          adjustedProtein: adjustedProtein,
          adjustedCarbs: adjustedCarbs,
          adjustedFat: adjustedFat,
        ),
        const SizedBox(height: 16),

        // 2. Portions section
        _PortionsSection(
          servingsController: _servingsController,
          currentValue: _parsedServings,
          showCustomInput: _showCustomServings,
          onQuickSelected: _setQuickServing,
          onServingsChanged: () => setState(() {}),
          onToggleCustom: () =>
              setState(() => _showCustomServings = !_showCustomServings),
          onIncrement: () {
            final current = _parsedServings;
            _setQuickServing(current + 0.5);
          },
          onDecrement: () {
            final current = _parsedServings;
            if (current > 0.5) {
              _setQuickServing(current - 0.5);
            }
          },
        ),
        const SizedBox(height: 16),



        // 4. Ingredients section
        _buildIngredientsSection(context, activeItems),
        const SizedBox(height: 16),

        // 5. Food quality card
        _CompactFoodQualityCard(score: foodQualityScore),

        // 6. Meal suggestions
        if (_mealSuggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _MealSuggestionsCard(suggestions: _mealSuggestions),
        ],
      ],
    );
  }

  Widget _buildIngredientsSection(
    BuildContext context,
    List<InterpretationDraftItemEntity> activeItems,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).aiDetectedIngredients,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kDarkText,
                  ),
                ),
                Text(
                  _isPersistingEdits
                      ? S.of(context).buttonSaveLabel
                      : S.of(context).aiActiveItemsCount(activeItems.length),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kPrimaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kSoftBorder),
          ..._draft!.items.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == _draft!.items.length - 1;
              return _IngredientRow(
                item: item,
                isLast: isLast,
                onToggleRemoved: () => _toggleRemoved(item),
                onTap: item.editable
                    ? () => _showIngredientBottomSheet(item)
                    : null,
              );
            },
          ),
          const Divider(height: 1, color: _kSoftBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: _OutlinedActionBtn(
                    icon: Icons.add,
                    label: S.of(context).aiAddIngredient,
                    onTap: _isPersistingEdits ? null : _showAddIngredientFlow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutlinedActionBtn(
                    icon: Icons.bookmark_border_rounded,
                    label: S.of(context).aiSaveAsRecipe,
                    onTap: activeItems.isEmpty || _isPersistingEdits
                        ? null
                        : _showSaveRecipeDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIngredientBottomSheet(InterpretationDraftItemEntity item) {
    final saved = _savedCorrections[_correctionKey(item.label)];
    final savedLabel = saved == null
        ? null
        : '${saved.amount.toStringAsFixed(saved.amount % 1 == 0 ? 0 : 1)} ${_localizeUnit(context, saved.unit, saved.amount)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _IngredientBottomSheet(
        item: item,
        unitPresets: _quickUnitsForItem(item),
        savedCorrectionLabel: savedLabel,
        onAmountChanged: (amount) {
          Navigator.of(sheetContext).pop();
          _updateItemAmount(item, amount);
        },
        onUnitSelected: (unit) {
          Navigator.of(sheetContext).pop();
          _applyUnitPreset(item, unit);
        },
        onPresetApplied: (factor) {
          Navigator.of(sheetContext).pop();
          _applyPortionPreset(item, factor);
        },
        onReplace: () {
          Navigator.of(sheetContext).pop();
          _showReplaceDialog(item);
        },
        onRemove: () {
          Navigator.of(sheetContext).pop();
          _toggleRemoved(item);
        },
        onEditMacros: () {
          Navigator.of(sheetContext).pop();
          _showMacroEditor(item);
        },
        onApplySavedCorrection: saved != null
            ? () {
                Navigator.of(sheetContext).pop();
                _applySavedCorrection(item);
              }
            : null,
      ),
    );
  }

  // ── Business logic (preserved) ─────────────────────────────────────

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
        fiber: nutrition.fiber,
        sugar: nutrition.sugar,
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
        fiber: nutrition.fiber,
        sugar: nutrition.sugar,
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
      fiber: nutrition.fiber,
      sugar: nutrition.sugar,
      removed: false,
    );
    await _saveCorrection(updatedItem);
    await _replaceItem(updatedItem);
  }

  Future<void> _showMacroEditor(InterpretationDraftItemEntity item) async {
    final carbsController = TextEditingController(
      text: item.carbs.toStringAsFixed(1),
    );
    final fatController = TextEditingController(
      text: item.fat.toStringAsFixed(1),
    );
    final proteinController = TextEditingController(
      text: item.protein.toStringAsFixed(1),
    );

    final updated = await showDialog<InterpretationDraftItemEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).aiEditMacrosTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carbsController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: S.of(context).carbohydrateLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fatController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: S.of(context).fatLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proteinController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: S.of(context).proteinLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: carbsController,
                builder: (context, _, __) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: fatController,
                    builder: (context, __, ___) {
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: proteinController,
                        builder: (context, ___, ____) {
                          final carbs = _parseMacroValue(carbsController.text);
                          final fat = _parseMacroValue(fatController.text);
                          final protein =
                              _parseMacroValue(proteinController.text);
                          final derivedKcal = _deriveKcal(
                            carbs: carbs,
                            fat: fat,
                            protein: protein,
                          );
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: S.of(context).kcalLabel,
                              border: OutlineInputBorder(),
                            ),
                            child: Text(derivedKcal.toStringAsFixed(0)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () {
              final carbs =
                  double.tryParse(carbsController.text.replaceAll(',', '.'));
              final fat =
                  double.tryParse(fatController.text.replaceAll(',', '.'));
              final protein =
                  double.tryParse(proteinController.text.replaceAll(',', '.'));
              if (carbs == null ||
                  fat == null ||
                  protein == null ||
                  carbs < 0 ||
                  fat < 0 ||
                  protein < 0) {
                return;
              }
              final kcal = _deriveKcal(
                carbs: carbs,
                fat: fat,
                protein: protein,
              );

              Navigator.of(context).pop(
                item.copyWith(
                  kcal: kcal,
                  carbs: carbs,
                  fat: fat,
                  protein: protein,
                ),
              );
            },
            child: Text(S.of(context).buttonSaveLabel),
          ),
        ],
      ),
    );

    carbsController.dispose();
    fatController.dispose();
    proteinController.dispose();

    if (updated == null) {
      return;
    }

    await _saveCorrection(updated);
    await _replaceItem(updated);
  }

  double _parseMacroValue(String input) {
    return double.tryParse(input.replaceAll(',', '.')) ?? 0;
  }

  double _deriveKcal({
    required double carbs,
    required double fat,
    required double protein,
  }) {
    return (carbs * 4) + (protein * 4) + (fat * 9);
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
      label: meal.name ?? S.current.aiAddIngredient,
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
        SnackBar(content: Text(S.current.aiSaveDraftChangesError)),
      );
    }
  }

  Future<void> _commitDraft(InterpretationDraftEntity draft) async {
    final access = await _ensureAiSaveAccess();
    if (!access.allowed) {
      return;
    }

    setState(() => _isSaving = true);

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
      await locator<MonetizationService>().recordAiMealSaved(
        consumeTrialUse: access.consumeTrialUse,
      );
      if (access.consumeTrialUse) {
        await locator<ConversionAnalyticsService>().logEvent('ai_trial_used');
      }
      await locator<ConversionAnalyticsService>().logEvent(
        'ai_meal_saved',
        parameters: {
          'intake_type': _args.intakeTypeEntity.name,
        },
      );
      locator<HomeBloc>().add(const LoadItemsEvent());
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      if (!mounted) {
        return;
      }

      _checkAndRequestReview();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.aiMealSavedSuccess)),
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
        SnackBar(content: Text(S.current.aiMealSaveError)),
      );
    }
  }

  Future<_AiSaveAccess> _ensureAiSaveAccess() async {
    final monetizationService = locator<MonetizationService>();
    var trialState = await monetizationService.getAiTrialState();
    if (trialState.isPremium) {
      return const _AiSaveAccess.allowed(consumeTrialUse: false);
    }
    if (trialState.remaining > 0) {
      return const _AiSaveAccess.allowed(consumeTrialUse: true);
    }
    await locator<ConversionAnalyticsService>().logEvent(
      'ai_limit_reached',
      parameters: {'placement': 'ai_save'},
    );
    if (!mounted) {
      return const _AiSaveAccess.denied();
    }

    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaywallSheet(
        placement: PaywallPlacement.aiLimit,
        trialState: trialState,
      ),
    );
    if (purchased == true) {
      return const _AiSaveAccess.allowed(consumeTrialUse: false);
    }

    trialState = await monetizationService.getAiTrialState();
    if (trialState.isPremium) {
      return const _AiSaveAccess.allowed(consumeTrialUse: false);
    }
    if (trialState.remaining > 0) {
      return const _AiSaveAccess.allowed(consumeTrialUse: true);
    }
    return const _AiSaveAccess.denied();
  }

  Future<void> _checkAndRequestReview() async {
    await locator<AppReviewService>().recordAiMealCommitted();
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

  Future<void> _showSaveRecipeDialog() async {
    final draft = _draft;
    if (draft == null || _activeItems.isEmpty) {
      return;
    }

    final controller = TextEditingController(text: draft.title);
    final baseRecipe = RecipeFactory.fromInterpretationDraft(
      name: draft.title,
      draft: draft,
      quickCategory: QuickRecipeCategoryEntity.leanMeal,
    );
    var saveCategory = RecipeSaveCategoryEntityX.inferDefault(
      recipe: baseRecipe,
      fallbackIntakeType: _args.intakeTypeEntity,
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.of(context).aiSaveAsRecipe),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: S.of(context).aiRecipeNameLabel,
                      helperText: S.of(context).aiRecipeNameHelper,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RecipeSaveCategoryEntity>(
                    isExpanded: true,
                    initialValue: saveCategory,
                    decoration: InputDecoration(
                      labelText: S.of(context).recipeQuickCategoryLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: RecipeSaveCategoryEntity.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(_saveCategoryLabel(context, category)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        saveCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(S.of(context).dialogCancelLabel),
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
                      quickCategory: saveCategory.quickCategory,
                    ).copyWith(
                      saved: true,
                      notes:
                          QuickRecipeCategoryEntityX.applyExplicitIntakeTypeTag(
                        draft.summary,
                        saveCategory.explicitIntakeType,
                      ),
                    );
                    await locator<SaveRecipeUsecase>().saveRecipe(recipe);

                    if (!dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(S.of(context).recipeSavedSnackbar)),
                      );
                    }
                  },
                  child: Text(S.of(context).buttonSaveLabel),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  String _quickCategoryLabel(
    BuildContext context,
    QuickRecipeCategoryEntity category,
  ) {
    switch (category) {
      case QuickRecipeCategoryEntity.preWorkout:
        return S.of(context).quickCategoryPreWorkout;
      case QuickRecipeCategoryEntity.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case QuickRecipeCategoryEntity.shake:
        return S.of(context).quickCategoryShake;
      case QuickRecipeCategoryEntity.leanMeal:
        return S.of(context).quickCategoryLeanMeal;
    }
  }

  String _saveCategoryLabel(
    BuildContext context,
    RecipeSaveCategoryEntity category,
  ) {
    switch (category) {
      case RecipeSaveCategoryEntity.breakfast:
        return S.of(context).breakfastLabel;
      case RecipeSaveCategoryEntity.lunch:
        return S.of(context).lunchLabel;
      case RecipeSaveCategoryEntity.dinner:
        return S.of(context).dinnerLabel;
      case RecipeSaveCategoryEntity.snack:
        return S.of(context).snackLabel;
      case RecipeSaveCategoryEntity.preWorkout:
        return _quickCategoryLabel(
          context,
          QuickRecipeCategoryEntity.preWorkout,
        );
      case RecipeSaveCategoryEntity.postWorkout:
        return _quickCategoryLabel(
          context,
          QuickRecipeCategoryEntity.postWorkout,
        );
      case RecipeSaveCategoryEntity.shake:
        return _quickCategoryLabel(context, QuickRecipeCategoryEntity.shake);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ════════════════════════════════════════════════════════════════════════

// ── Compact Summary Card ──────────────────────────────────────────────

class _CompactSummaryCard extends StatelessWidget {
  final InterpretationDraftEntity draft;
  final IntakeTypeEntity intakeType;
  final double adjustedKcal;
  final double adjustedProtein;
  final double adjustedCarbs;
  final double adjustedFat;

  const _CompactSummaryCard({
    required this.draft,
    required this.intakeType,
    required this.adjustedKcal,
    required this.adjustedProtein,
    required this.adjustedCarbs,
    required this.adjustedFat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo + title + chips row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoThumbnail(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kDarkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetadataChip(
                          label: draft.sourceType == DraftSourceEntity.photo
                              ? S.of(context).aiSourcePhoto
                              : S.of(context).aiSourceText,
                        ),
                        _MetadataChip(label: intakeType.name),
                        _MetadataChip(
                          label: _confidenceLabel(context, draft.confidenceBand),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Kcal headline
          Text(
            '${adjustedKcal.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _kDarkText,
            ),
          ),
          const SizedBox(height: 12),
          // Macros row
          Row(
            children: [
              _CompactMacro(
                label: S.of(context).proteinLabel,
                value: '${adjustedProtein.toStringAsFixed(1)}g',
                color: _kPrimaryGreen,
              ),
              const SizedBox(width: 12),
              _CompactMacro(
                label: S.of(context).carbohydrateLabel,
                value: '${adjustedCarbs.toStringAsFixed(1)}g',
                color: const Color(0xFF4A90D9),
              ),
              const SizedBox(width: 12),
              _CompactMacro(
                label: S.of(context).fatLabel,
                value: '${adjustedFat.toStringAsFixed(1)}g',
                color: const Color(0xFFE7A83B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail() {
    final imagePath = draft.localImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderThumbnail(),
        ),
      );
    }
    return _placeholderThumbnail();
  }

  Widget _placeholderThumbnail() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _kPrimaryGreen.withValues(alpha: 0.10),
      ),
      child: const Icon(
        Icons.restaurant_outlined,
        color: _kPrimaryGreen,
        size: 26,
      ),
    );
  }

  static String _confidenceLabel(
      BuildContext context, ConfidenceBandEntity band) {
    switch (band) {
      case ConfidenceBandEntity.high:
        return S.of(context).aiConfidenceHigh;
      case ConfidenceBandEntity.medium:
        return S.of(context).aiConfidenceMedium;
      case ConfidenceBandEntity.low:
        return S.of(context).aiConfidenceLow;
    }
  }
}

class _MetadataChip extends StatelessWidget {
  final String label;
  const _MetadataChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_kChipRadius),
        color: _kSoftBorder.withValues(alpha: 0.6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _kMutedText,
        ),
      ),
    );
  }
}

class _CompactMacro extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CompactMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kInputRadius),
          color: color.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: _kMutedText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Portions Section ──────────────────────────────────────────────────

class _PortionsSection extends StatelessWidget {
  final TextEditingController servingsController;
  final double currentValue;
  final bool showCustomInput;
  final ValueChanged<double> onQuickSelected;
  final VoidCallback onServingsChanged;
  final VoidCallback onToggleCustom;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PortionsSection({
    required this.servingsController,
    required this.currentValue,
    required this.showCustomInput,
    required this.onQuickSelected,
    required this.onServingsChanged,
    required this.onToggleCustom,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: icon + title
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: _kPrimaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).servingsLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kDarkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stepper + Presets Horizontal Row
          Row(
            children: [
              // Stepper Left
              _StepperButton(
                icon: Icons.remove,
                onTap: currentValue > 0.5 ? onDecrement : null,
              ),
              const SizedBox(width: 10),
              Text(
                currentValue % 1 == 0
                    ? currentValue.toInt().toString()
                    : currentValue.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kDarkText,
                ),
              ),
              const SizedBox(width: 10),
              _StepperButton(
                icon: Icons.add,
                onTap: onIncrement,
              ),
              const SizedBox(width: 12),
              // Presets Right (Scrollable to prevent overflow)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [0.5, 1.0, 1.5, 2.0].map(
                        (value) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _QuickPresetChip(
                            label: value % 1 == 0 ? value.toInt().toString() : '$value',
                            selected: currentValue == value,
                            onTap: () => onQuickSelected(value),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Custom toggle
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onToggleCustom,
              child: Text(
                S.of(context).aiCustomServingsLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kPrimaryGreen,
                ),
              ),
            ),
          ),
          if (showCustomInput) ...[
            const SizedBox(height: 12),
            TextField(
              controller: servingsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                helperText: S.of(context).aiCustomServingsHelper,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kInputRadius),
                  borderSide: const BorderSide(color: _kSoftBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kInputRadius),
                  borderSide: const BorderSide(color: _kSoftBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kInputRadius),
                  borderSide: const BorderSide(color: _kPrimaryGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => onServingsChanged(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled
              ? _kSoftBorder.withValues(alpha: 0.5)
              : const Color(0xFFE8F5EE), // Very light green
        ),
        child: Icon(
          icon,
          color: disabled ? _kMutedText.withValues(alpha: 0.4) : _kPrimaryGreen,
          size: 18,
        ),
      ),
    );
  }
}

class _QuickPresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _QuickPresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? const Color(0xFFF0F9F4) // Very light green background
              : Colors.transparent,
          border: Border.all(
            color: selected ? _kPrimaryGreen : const Color(0xFFE6ECE7),
            width: selected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? _kPrimaryGreen : _kMutedText,
          ),
        ),
      ),
    );
  }
}

// ── Ingredient Row ────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final InterpretationDraftItemEntity item;
  final VoidCallback onToggleRemoved;
  final VoidCallback? onTap;
  final bool isLast;

  const _IngredientRow({
    required this.item,
    required this.onToggleRemoved,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRemoved = item.removed;

    // Determine category icon and colors dynamically based on the label keywords
    IconData foodIcon = Icons.flatware_outlined;
    Color iconColor = _kPrimaryGreen;
    Color bgColor = const Color(0xFFE8F5EE);

    final labelLower = item.label.toLowerCase();
    if (labelLower.contains('pollo') ||
        labelLower.contains('chicken') ||
        labelLower.contains('pechuga') ||
        labelLower.contains('carne') ||
        labelLower.contains('meat') ||
        labelLower.contains('ternera') ||
        labelLower.contains('cerdo') ||
        labelLower.contains('pavo')) {
      foodIcon = Icons.kebab_dining_outlined;
      iconColor = _kPrimaryGreen;
      bgColor = const Color(0xFFE8F5EE);
    } else if (labelLower.contains('aceite') ||
        labelLower.contains('oil') ||
        labelLower.contains('gras') ||
        labelLower.contains('mantequ') ||
        labelLower.contains('olive')) {
      foodIcon = Icons.opacity_outlined;
      iconColor = const Color(0xFFE7A83B);
      bgColor = const Color(0xFFFFF4DF);
    } else if (labelLower.contains('verdura') ||
        labelLower.contains('vegetal') ||
        labelLower.contains('mix') ||
        labelLower.contains('salad') ||
        labelLower.contains('brocol') ||
        labelLower.contains('zanahor') ||
        labelLower.contains('lechug') ||
        labelLower.contains('tomate') ||
        labelLower.contains('cebolla') ||
        labelLower.contains('judías') ||
        labelLower.contains('espárrago')) {
      foodIcon = Icons.eco_outlined;
      iconColor = _kPrimaryGreen;
      bgColor = const Color(0xFFE8F5EE);
    }

    // Determine confidence tag parameters
    String bandLabel = '';
    Color bandTextColor = _kPrimaryGreen;
    Color bandBgColor = const Color(0xFFF0F9F4);

    switch (item.confidenceBand) {
      case ConfidenceBandEntity.high:
        bandLabel = S.of(context).aiConfidenceHigh;
        bandTextColor = _kPrimaryGreen;
        bandBgColor = const Color(0xFFF0F9F4);
        break;
      case ConfidenceBandEntity.medium:
        bandLabel = S.of(context).aiConfidenceMedium;
        bandTextColor = const Color(0xFFE7A83B);
        bandBgColor = const Color(0xFFFFF4DF);
        break;
      case ConfidenceBandEntity.low:
        bandLabel = S.of(context).aiConfidenceLow;
        bandTextColor = Colors.red;
        bandBgColor = const Color(0xFFFFECEC);
        break;
    }

    return InkWell(
      onTap: isRemoved ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: _kSoftBorder.withValues(alpha: 0.6)),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Custom Checkbox
            GestureDetector(
              onTap: onToggleRemoved,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isRemoved ? Colors.transparent : _kPrimaryGreen,
                    border: Border.all(
                      color: isRemoved ? _kSoftBorder : _kPrimaryGreen,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isRemoved
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Food Icon Card/Box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isRemoved ? _kSoftBorder.withValues(alpha: 0.3) : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                foodIcon,
                color: isRemoved ? _kMutedText.withValues(alpha: 0.4) : iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            // Name + Confidence Tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isRemoved ? _kMutedText.withValues(alpha: 0.5) : _kDarkText,
                      decoration: isRemoved ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isRemoved) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: bandBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        bandLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: bandTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Amount Column (Right-aligned, fixed width to keep alignment homogeneous)
            SizedBox(
              width: 58,
              child: Text(
                '${item.amount.toStringAsFixed(item.amount % 1 == 0 ? 0 : 1)} ${_localizeUnit(context, item.unit, item.amount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isRemoved ? _kMutedText.withValues(alpha: 0.4) : _kMutedText,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Separator Column (Centered divider line in a fixed-width box)
            SizedBox(
              width: 14,
              child: Center(
                child: Container(
                  width: 1,
                  height: 14,
                  color: _kSoftBorder,
                ),
              ),
            ),
            // Kcal Column (Left-aligned, fixed width)
            SizedBox(
              width: 90,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    item.kcal.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isRemoved ? _kMutedText.withValues(alpha: 0.4) : _kDarkText,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: isRemoved ? _kMutedText.withValues(alpha: 0.4) : _kMutedText,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron Column (Fixed width container so spacing is constant even if chevron is hidden)
            Container(
              width: 14,
              alignment: Alignment.centerRight,
              child: isRemoved
                  ? const SizedBox.shrink()
                  : Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: _kMutedText.withValues(alpha: 0.5),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ingredient Bottom Sheet ───────────────────────────────────────────

class _IngredientBottomSheet extends StatefulWidget {
  final InterpretationDraftItemEntity item;
  final List<String> unitPresets;
  final String? savedCorrectionLabel;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onUnitSelected;
  final ValueChanged<double> onPresetApplied;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final VoidCallback onEditMacros;
  final VoidCallback? onApplySavedCorrection;

  const _IngredientBottomSheet({
    required this.item,
    required this.unitPresets,
    required this.savedCorrectionLabel,
    required this.onAmountChanged,
    required this.onUnitSelected,
    required this.onPresetApplied,
    required this.onReplace,
    required this.onRemove,
    required this.onEditMacros,
    required this.onApplySavedCorrection,
  });

  @override
  State<_IngredientBottomSheet> createState() =>
      _IngredientBottomSheetState();
}

class _IngredientBottomSheetState extends State<_IngredientBottomSheet> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.item.amount
          .toStringAsFixed(widget.item.amount % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_kCardRadius)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _kSoftBorder,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.item.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kDarkText,
                ),
              ),
              const SizedBox(height: 16),

              // Quantity + unit row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: S.of(context).quantityLabel,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(_kInputRadius),
                          borderSide: const BorderSide(color: _kSoftBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(_kInputRadius),
                          borderSide: const BorderSide(color: _kSoftBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(_kInputRadius),
                          borderSide: const BorderSide(
                              color: _kPrimaryGreen, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: widget.unitPresets
                            .map(
                              (unit) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _QuickPresetChip(
                                  label: _localizeUnit(context, unit),
                                  selected: widget.item.unit == unit,
                                  onTap: () => widget.onUnitSelected(unit),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Macro summary
              Row(
                children: [
                  _SheetMacroItem(
                    label: S.of(context).proteinLabel,
                    value: '${widget.item.protein.toStringAsFixed(1)}g',
                  ),
                  const SizedBox(width: 12),
                  _SheetMacroItem(
                    label: S.of(context).carbohydrateLabel,
                    value: '${widget.item.carbs.toStringAsFixed(1)}g',
                  ),
                  const SizedBox(width: 12),
                  _SheetMacroItem(
                    label: S.of(context).fatLabel,
                    value: '${widget.item.fat.toStringAsFixed(1)}g',
                  ),
                  const SizedBox(width: 12),
                  _SheetMacroItem(
                    label: 'kcal',
                    value: widget.item.kcal.toStringAsFixed(0),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quick adjustments
              Text(
                S.of(context).aiQuickAdjustment,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kMutedText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _AdjustmentChip(
                    label: '-25%',
                    onTap: () => widget.onPresetApplied(0.75),
                  ),
                  const SizedBox(width: 8),
                  _AdjustmentChip(
                    label: '+25%',
                    onTap: () => widget.onPresetApplied(1.25),
                  ),
                  const SizedBox(width: 8),
                  _AdjustmentChip(
                    label: '+50%',
                    onTap: () => widget.onPresetApplied(1.5),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final parsed = double.tryParse(
                          _amountController.text.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return;
                      }
                      widget.onAmountChanged(parsed);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_kChipRadius),
                        color: _kPrimaryGreen,
                      ),
                      child: Text(
                        S.of(context).buttonSaveLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Saved correction
              if (widget.savedCorrectionLabel != null &&
                  widget.onApplySavedCorrection != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: widget.onApplySavedCorrection,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_kInputRadius),
                      color: _kPrimaryGreen.withValues(alpha: 0.06),
                      border: Border.all(
                        color: _kPrimaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_outlined,
                            size: 18, color: _kPrimaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.of(context).aiUseHabitual(
                                widget.savedCorrectionLabel!),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kPrimaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1, color: _kSoftBorder),
              const SizedBox(height: 12),

              // Actions row
              Row(
                children: [
                  _SheetAction(
                    icon: Icons.tune_outlined,
                    label: S.of(context).aiEditMacrosLabel,
                    onTap: widget.onEditMacros,
                  ),
                  const SizedBox(width: 12),
                  _SheetAction(
                    icon: Icons.swap_horiz_outlined,
                    label: S.of(context).aiSubstituteLabel,
                    onTap: widget.onReplace,
                  ),
                  const SizedBox(width: 12),
                  _SheetAction(
                    icon: Icons.remove_circle_outline,
                    label: S.of(context).aiRemoveLabel,
                    onTap: widget.onRemove,
                    destructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetMacroItem extends StatelessWidget {
  final String label;
  final String value;
  const _SheetMacroItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kDarkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _kMutedText),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AdjustmentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AdjustmentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_kChipRadius),
          color: _kSoftBorder.withValues(alpha: 0.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kDarkText,
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.red : _kMutedText;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kInputRadius),
            color: destructive
                ? Colors.red.withValues(alpha: 0.06)
                : _kSoftBorder.withValues(alpha: 0.4),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact Food Quality Card ─────────────────────────────────────────

class _CompactFoodQualityCard extends StatelessWidget {
  final dynamic score;
  const _CompactFoodQualityCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: FoodQualityScoreCard(score: score),
      ),
    );
  }
}



// ── Meal Suggestions Card ─────────────────────────────────────────────

class _MealSuggestionsCard extends StatelessWidget {
  final List<MealInterpretationSuggestion> suggestions;
  const _MealSuggestionsCard({
    required this.suggestions,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(_kCardRadius),
        boxShadow: _kCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _kPrimaryGreen.withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.history_toggle_off_outlined,
                    color: _kPrimaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).aiYourMatches,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kDarkText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).aiMatchesReferenceHint,
              style: const TextStyle(
                fontSize: 13,
                color: _kMutedText,
              ),
            ),
            const SizedBox(height: 14),
            ...suggestions.map(
              (suggestion) {
                final suggestionNutrition = MealPortionCalculator.calculate(
                  suggestion.meal,
                  suggestion.defaultAmount,
                  suggestion.defaultUnit,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_kInputRadius),
                      color: _kBgColor,
                      border: Border.all(color: _kSoftBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: _kPrimaryGreen.withValues(alpha: 0.12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_fix_high_outlined,
                            color: _kPrimaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _kDarkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${suggestion.sourceLabel} \u00b7 ${suggestion.defaultAmount.toStringAsFixed(suggestion.defaultAmount % 1 == 0 ? 0 : 1)} ${suggestion.defaultUnit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _kMutedText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${suggestionNutrition.kcal.toStringAsFixed(0)} kcal · ${_suggestionMatchLabel(suggestion.score)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kPrimaryGreen.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _suggestionMatchLabel(double score) {
    if (score >= 0.8) {
      return S.current.aiMatchHigh;
    }
    if (score >= 0.6) {
      return S.current.aiMatchGood;
    }
    return S.current.aiMatchPossible;
  }
}

// ── Shared data classes ───────────────────────────────────────────────

class _AiSaveAccess {
  final bool allowed;
  final bool consumeTrialUse;

  const _AiSaveAccess._({
    required this.allowed,
    required this.consumeTrialUse,
  });

  const _AiSaveAccess.allowed({required bool consumeTrialUse})
      : this._(allowed: true, consumeTrialUse: consumeTrialUse);

  const _AiSaveAccess.denied() : this._(allowed: false, consumeTrialUse: false);
}

class MealInterpretationReviewScreenArguments {
  final String draftId;
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;
  final int? photoOriginalBytes;
  final int? photoPreparedBytes;
  final int? photoPrepareMs;
  final int? photoRemoteMs;
  final int? photoRemoteEdgeMs;
  final int? photoRemoteGeminiMs;
  final int? photoModelAttempts;
  final bool? photoFallbackUsed;
  final int? photoPersonalizeMs;
  final int? photoTotalMs;

  MealInterpretationReviewScreenArguments(
    this.draftId,
    this.day,
    this.intakeTypeEntity, {
    this.photoOriginalBytes,
    this.photoPreparedBytes,
    this.photoPrepareMs,
    this.photoRemoteMs,
    this.photoRemoteEdgeMs,
    this.photoRemoteGeminiMs,
    this.photoModelAttempts,
    this.photoFallbackUsed,
    this.photoPersonalizeMs,
    this.photoTotalMs,
  });
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
      title: Text(widget.meal.name ?? S.of(context).aiAddIngredient),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: S.of(context).quantityLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12.0),
          DropdownButtonFormField<String>(
            initialValue: _selectedUnit,
            decoration: InputDecoration(
              labelText: S.of(context).unitLabel,
              border: const OutlineInputBorder(),
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
          child: Text(S.of(context).dialogCancelLabel),
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
          child: Text(S.of(context).addLabel),
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

String _localizeUnit(BuildContext context, String unit, [double? amount]) {
  final lower = unit.toLowerCase();
  if (lower == 'serving') {
    if (amount != null && amount != 1.0) {
      return S.of(context).recipeDetailServingUnitPlural;
    }
    return S.of(context).recipeDetailServingUnitSingular;
  }
  return unit;
}

class _OutlinedActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OutlinedActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final color = disabled ? _kMutedText.withValues(alpha: 0.4) : _kPrimaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
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
