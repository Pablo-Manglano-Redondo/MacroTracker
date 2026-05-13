import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/ai_food_memory_entry.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/ai_meal_memory_entry.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';

class MealInterpretationPersonalizationUsecase {
  static const aiMemoryBoxName = 'AiCorrectionsBox';
  static const aiMealMemoryBoxName = 'AiMealMemoriesBox';

  final GetRecipeLibraryUsecase _getRecipeLibraryUsecase;
  final GetFrequentIntakePresetsUsecase _getFrequentIntakePresetsUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final GetUserUsecase _getUserUsecase;

  MealInterpretationPersonalizationUsecase(
    this._getRecipeLibraryUsecase,
    this._getFrequentIntakePresetsUsecase,
    this._getConfigUsecase,
    this._getUserUsecase,
  );

  Future<MealInterpretationPersonalizationContext> buildContext({
    required IntakeTypeEntity intakeType,
    String? freeText,
  }) async {
    final config = await _getConfigUsecase.getConfig();
    final user = await _getUserUsecase.getUserData();
    final recipes = await _getRecipeLibraryUsecase.getAllRecipes();
    final frequentMeals =
        await _getFrequentIntakePresetsUsecase.getTopPresets(limit: 10);
    final foodMemories = await loadFoodMemories();
    final mealMemories = await loadMealMemories();
    final candidates = _buildCandidates(
      frequentMeals: frequentMeals,
      recipes: recipes,
      memories: foodMemories,
      mealMemories: mealMemories,
    );

    final mealQuery = freeText?.trim();
    final sortedCandidates = [...candidates]
      ..sort(
        (a, b) => _scoreCandidate(
          mealQuery,
          b,
          intakeType: intakeType,
        ).compareTo(_scoreCandidate(mealQuery, a, intakeType: intakeType)),
      );

    final topCandidates = sortedCandidates.take(10).toList(growable: false);
    final promptContext = _buildPromptContext(
      user: user,
      dailyFocus: config.dailyFocus,
      intakeType: intakeType,
      candidates: topCandidates,
      memories: foodMemories.take(8).toList(growable: false),
      mealMemories: mealMemories.take(6).toList(growable: false),
    );

    return MealInterpretationPersonalizationContext(
      promptContext: promptContext,
      remoteExamples: topCandidates
          .take(6)
          .map((candidate) => candidate.toRemoteMap())
          .toList(growable: false),
      candidates: candidates,
    );
  }

  Future<InterpretationDraftEntity> personalizeDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
    MealInterpretationPersonalizationContext? context,
  }) async {
    final foodMemories = await loadFoodMemories();
    if (foodMemories.isEmpty) {
      return _validateMacroCoherence(draft);
    }

    final correctionMap = <String, AiFoodMemoryEntry>{};
    for (final memory in foodMemories) {
      correctionMap.putIfAbsent(
        _normalize(memory.displayLabel),
        () => memory,
      );
    }

    var hasChanges = false;
    final updatedItems = <InterpretationDraftItemEntity>[];
    for (final item in draft.items) {
      final bestCorrection = _findReliableCorrection(item, correctionMap);
      if (bestCorrection != null && bestCorrection.uses >= 2) {
        final meal = item.matchedMealSnapshot ?? bestCorrection.mealSnapshot;
        if (meal != null) {
          final nutrition = MealPortionCalculator.calculate(
            meal,
            bestCorrection.amount,
            bestCorrection.unit,
          );
          updatedItems.add(item.copyWith(
            amount: bestCorrection.amount,
            unit: bestCorrection.unit,
            kcal: nutrition.kcal,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            protein: nutrition.protein,
            fiber: nutrition.fiber,
            sugar: nutrition.sugar,
            matchedMealSnapshot: meal,
            confidenceBand: ConfidenceBandEntity.medium,
          ));
          hasChanges = true;
        } else {
          updatedItems.add(item.copyWith(
            amount: bestCorrection.amount,
            unit: bestCorrection.unit,
            kcal: bestCorrection.kcal,
            carbs: bestCorrection.carbs,
            fat: bestCorrection.fat,
            protein: bestCorrection.protein,
            fiber: null,
            sugar: null,
            confidenceBand: ConfidenceBandEntity.medium,
          ));
          hasChanges = true;
        }
      } else {
        updatedItems.add(item);
      }
    }

    if (!hasChanges) {
      return _validateMacroCoherence(draft);
    }

    final activeItems = updatedItems.where((item) => !item.removed);
    final updatedDraft = draft.copyWith(
      items: updatedItems,
      totalKcal:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.kcal),
      totalCarbs:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.carbs),
      totalFat:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.fat),
      totalProtein:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.protein),
      totalFiber: activeItems.any((i) => i.fiber != null)
          ? activeItems.fold<double>(0.0, (sum, item) => sum + (item.fiber ?? 0))
          : null,
      totalSugar: activeItems.any((i) => i.sugar != null)
          ? activeItems.fold<double>(0.0, (sum, item) => sum + (item.sugar ?? 0))
          : null,
    );
    return _validateMacroCoherence(updatedDraft);
  }

  InterpretationDraftEntity _validateMacroCoherence(
      InterpretationDraftEntity draft) {
    final updatedItems = draft.items.map((item) {
      if (item.removed) return item;
      final derivedKcal =
          (item.carbs * 4) + (item.protein * 4) + (item.fat * 9);
      if (derivedKcal <= 0) return item;
      final ratio = item.kcal / derivedKcal;
      if (ratio < 0.85 || ratio > 1.15) {
        return item.copyWith(
          kcal: derivedKcal,
          confidenceBand: item.confidenceBand == ConfidenceBandEntity.high
              ? ConfidenceBandEntity.medium
              : item.confidenceBand,
        );
      }
      return item;
    }).toList();

    final activeItems = updatedItems.where((item) => !item.removed);
    return draft.copyWith(
      items: updatedItems,
      totalKcal:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.kcal),
      totalCarbs:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.carbs),
      totalFat:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.fat),
      totalProtein:
          activeItems.fold<double>(0.0, (sum, item) => sum + item.protein),
      totalFiber: activeItems.any((i) => i.fiber != null)
          ? activeItems.fold<double>(0.0, (sum, item) => sum + (item.fiber ?? 0))
          : null,
      totalSugar: activeItems.any((i) => i.sugar != null)
          ? activeItems.fold<double>(0.0, (sum, item) => sum + (item.sugar ?? 0))
          : null,
    );
  }

  Future<List<MealInterpretationSuggestion>> suggestMealsForDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
  }) async {
    final context = await buildContext(
      intakeType: intakeType,
      freeText: _draftSearchText(draft),
    );
    final query = _draftSearchText(draft);
    final scored = context.candidates
        .map((candidate) => _CandidateMatch(
              candidate: candidate,
              score: _scoreCandidate(
                query,
                candidate,
                intakeType: intakeType,
              ),
            ))
        .where((match) => match.score >= 0.42)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final seen = <String>{};
    final suggestions = <MealInterpretationSuggestion>[];
    for (final match in scored) {
      final dedupeKey = _normalize(match.candidate.title);
      if (seen.contains(dedupeKey)) {
        continue;
      }
      seen.add(dedupeKey);
      suggestions.add(
        MealInterpretationSuggestion(
          id: match.candidate.id,
          title: match.candidate.title,
          sourceLabel: match.candidate.sourceLabel,
          defaultAmount: match.candidate.defaultAmount,
          defaultUnit: match.candidate.defaultUnit,
          meal: match.candidate.meal,
          score: match.score,
        ),
      );
      if (suggestions.length >= 4) {
        break;
      }
    }
    return suggestions;
  }

  Future<InterpretationDraftEntity> buildFallbackDraft({
    required DraftSourceEntity sourceType,
    required String title,
    required IntakeTypeEntity intakeType,
    String? inputText,
    String? localImagePath,
  }) async {
    final context = await buildContext(
      intakeType: intakeType,
      freeText: inputText ?? title,
    );
    final query = (inputText?.trim().isNotEmpty == true ? inputText : title) ??
        title;
    final bestMatch = _findBestCandidate(query, context.candidates,
        intakeType: intakeType);
    if (bestMatch != null && bestMatch.score >= 0.52) {
      final nutrition = MealPortionCalculator.calculate(
        bestMatch.candidate.meal,
        bestMatch.candidate.defaultAmount,
        bestMatch.candidate.defaultUnit,
      );
      final item = InterpretationDraftItemEntity(
        id: IdGenerator.getUniqueID(),
        label: bestMatch.candidate.title,
        matchedMealSnapshot: bestMatch.candidate.meal,
        amount: bestMatch.candidate.defaultAmount,
        unit: bestMatch.candidate.defaultUnit,
        kcal: nutrition.kcal,
        carbs: nutrition.carbs,
        fat: nutrition.fat,
        protein: nutrition.protein,
        fiber: nutrition.fiber,
        sugar: nutrition.sugar,
        confidenceBand: ConfidenceBandEntity.medium,
        editable: true,
        removed: false,
      );
      return InterpretationDraftEntity(
        id: IdGenerator.getUniqueID(),
        sourceType: sourceType,
        inputText: inputText,
        localImagePath: localImagePath,
        title: bestMatch.candidate.title,
        summary:
            'Interpretaci\u00f3n remota no disponible. Se propuso una comida tuya parecida para acelerar la correcci\u00f3n.',
        totalKcal: nutrition.kcal,
        totalCarbs: nutrition.carbs,
        totalFat: nutrition.fat,
        totalProtein: nutrition.protein,
        totalFiber: nutrition.fiber,
        totalSugar: nutrition.sugar,
        confidenceBand: ConfidenceBandEntity.medium,
        status: DraftStatusEntity.ready,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        items: [item],
      );
    }

    return InterpretationDraftEntity(
      id: IdGenerator.getUniqueID(),
      sourceType: sourceType,
      inputText: inputText,
      localImagePath: localImagePath,
      title: title,
      summary:
          'Interpretaci\u00f3n remota no disponible. Revisa el borrador y usa tus sugerencias guardadas para ajustarlo r\u00e1pido.',
      totalKcal: 0,
      totalCarbs: 0,
      totalFat: 0,
      totalProtein: 0,
      confidenceBand: ConfidenceBandEntity.low,
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      items: [
        InterpretationDraftItemEntity(
          id: IdGenerator.getUniqueID(),
          label: title,
          matchedMealSnapshot: null,
          amount: 1,
          unit: 'serving',
          kcal: 0,
          carbs: 0,
          fat: 0,
          protein: 0,
          confidenceBand: ConfidenceBandEntity.low,
          editable: true,
          removed: false,
        ),
      ],
    );
  }

  Future<List<AiFoodMemoryEntry>> loadFoodMemories() async {
    final box = await Hive.openBox(aiMemoryBoxName);
    final entries = <AiFoodMemoryEntry>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final entry = AiFoodMemoryEntry.fromMap(key.toString(), raw);
        if (entry.amount > 0 && entry.unit.trim().isNotEmpty) {
          entries.add(entry);
        }
      }
    }
    entries.sort((a, b) {
      final usageCompare = b.uses.compareTo(a.uses);
      if (usageCompare != 0) {
        return usageCompare;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return entries;
  }

  Future<List<AiMealMemoryEntry>> loadMealMemories() async {
    final box = await Hive.openBox(aiMealMemoryBoxName);
    final entries = <AiMealMemoryEntry>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        entries.add(AiMealMemoryEntry.fromMap(key.toString(), raw));
      }
    }
    entries.sort((a, b) {
      final usageCompare = b.uses.compareTo(a.uses);
      if (usageCompare != 0) {
        return usageCompare;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return entries;
  }

  Future<void> saveMealMemoryFromDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
  }) async {
    final activeItems = draft.items.where((item) => !item.removed).toList();
    if (activeItems.isEmpty) {
      return;
    }

    final title = draft.title.trim().isNotEmpty
        ? draft.title.trim()
        : activeItems.map((item) => item.label).join(' + ');
    final labels = activeItems.map((item) => item.label.trim()).join(' ');
    final searchText = '$title $labels'.trim();
    final key = _normalize(searchText.isNotEmpty ? searchText : title);
    if (key.isEmpty) {
      return;
    }

    final box = await Hive.openBox(aiMealMemoryBoxName);
    final rawPrevious = box.get(key);
    final previous =
        rawPrevious is Map ? AiMealMemoryEntry.fromMap(key, rawPrevious) : null;

    final memory = AiMealMemoryEntry(
      key: key,
      title: title,
      searchText: searchText,
      intakeType: intakeType,
      mealSnapshot: MealAggregateFactory.fromInterpretationDraft(draft),
      defaultAmount: 1,
      defaultUnit: 'serving',
      uses: (previous?.uses ?? 0) + 1,
      updatedAt: DateTime.now(),
    );
    await box.put(key, memory.toMap());
  }

  String _buildPromptContext({
    required UserEntity user,
    required DailyFocusEntity dailyFocus,
    required IntakeTypeEntity intakeType,
    required List<MealInterpretationCandidate> candidates,
    required List<AiFoodMemoryEntry> memories,
    required List<AiMealMemoryEntry> mealMemories,
  }) {
    final buffer = StringBuffer()
      ..writeln('User nutrition context:')
      ..writeln('- goal: ${_goalLabel(user.goal)}')
      ..writeln('- meal slot: ${intakeType.name}')
      ..writeln('- daily focus: ${_focusLabel(dailyFocus)}')
      ..writeln(
          '- instruction: prefer the user\'s repeated foods, products and saved recipes when plausible. estimate oils and sauces conservatively.');

    if (candidates.isNotEmpty) {
      buffer.writeln('Personal meal examples:');
      for (final candidate in candidates.take(6)) {
        final nutrition = MealPortionCalculator.calculate(
          candidate.meal,
          candidate.defaultAmount,
          candidate.defaultUnit,
        );
        buffer.writeln(
          '- ${candidate.title}: ${candidate.defaultAmount.toStringAsFixed(candidate.defaultAmount % 1 == 0 ? 0 : 1)} ${candidate.defaultUnit}, ${nutrition.kcal.toStringAsFixed(0)} kcal, ${nutrition.protein.toStringAsFixed(0)}p/${nutrition.carbs.toStringAsFixed(0)}c/${nutrition.fat.toStringAsFixed(0)}f (${candidate.sourceLabel})',
        );
      }
    }

    if (mealMemories.isNotEmpty) {
      buffer.writeln('Repeated full meals from this user:');
      for (final memory in mealMemories.take(5)) {
        final nutrition = MealPortionCalculator.calculate(
          memory.mealSnapshot,
          memory.defaultAmount,
          memory.defaultUnit,
        );
        buffer.writeln(
          '- ${memory.title}: ${nutrition.kcal.toStringAsFixed(0)} kcal, ${nutrition.protein.toStringAsFixed(0)}p/${nutrition.carbs.toStringAsFixed(0)}c/${nutrition.fat.toStringAsFixed(0)}f',
        );
      }
    }

    if (memories.isNotEmpty) {
      buffer.writeln('Frequent ingredient corrections:');
      for (final memory in memories.take(6)) {
        buffer.writeln(
          '- ${memory.displayLabel}: usually ${memory.amount.toStringAsFixed(memory.amount % 1 == 0 ? 0 : 1)} ${memory.unit} (${memory.kcal.toStringAsFixed(0)} kcal, corrected ${memory.uses}x)',
        );
      }
    }

    return buffer.toString().trim();
  }

  List<MealInterpretationCandidate> _buildCandidates({
    required List<FrequentIntakePresetEntity> frequentMeals,
    required List<RecipeEntity> recipes,
    required List<AiFoodMemoryEntry> memories,
    required List<AiMealMemoryEntry> mealMemories,
  }) {
    final candidates = <MealInterpretationCandidate>[];

    for (final memory in mealMemories) {
      candidates.add(
        MealInterpretationCandidate(
          id: 'meal-memory:${memory.key}',
          title: memory.title,
          sourceLabel:
              memory.uses > 1 ? 'Tu plato frecuente' : 'Tu plato guardado',
          meal: memory.mealSnapshot,
          defaultAmount: memory.defaultAmount,
          defaultUnit: memory.defaultUnit,
          searchTerms: [memory.title, memory.searchText],
          preferStoredPortion: true,
          sourcePriority: 1.12 + (memory.uses * 0.02),
        ),
      );
    }

    for (final memory in memories) {
      final meal = memory.mealSnapshot;
      if (meal == null) {
        continue;
      }
      candidates.add(
        MealInterpretationCandidate(
          id: 'memory:${memory.key}',
          title: memory.displayLabel,
          sourceLabel:
              memory.uses > 1 ? 'Tu correcci\u00f3n frecuente' : 'Tu correcci\u00f3n',
          meal: meal,
          defaultAmount: memory.amount,
          defaultUnit: memory.unit,
          searchTerms: [memory.displayLabel, meal.name ?? ''],
          preferStoredPortion: true,
          sourcePriority: 1.0 + (memory.uses * 0.02),
        ),
      );
    }

    for (final preset in frequentMeals) {
      candidates.add(
        MealInterpretationCandidate(
          id: 'preset:${preset.key}',
          title: preset.title,
          sourceLabel: 'Comida frecuente (${preset.uses}x)',
          meal: preset.meal,
          defaultAmount: preset.amount,
          defaultUnit: preset.unit,
          searchTerms: [preset.title, preset.meal.name ?? ''],
          preferStoredPortion: true,
          sourcePriority: 0.84 + (preset.uses * 0.015),
        ),
      );
    }

    for (final recipe in recipes) {
      candidates.add(
        MealInterpretationCandidate(
          id: 'recipe:${recipe.id}',
          title: recipe.name,
          sourceLabel: 'Receta guardada',
          meal: MealAggregateFactory.fromRecipe(recipe),
          defaultAmount: 1,
          defaultUnit: 'serving',
          searchTerms: [recipe.name, recipe.notes ?? ''],
          preferStoredPortion: true,
          sourcePriority: 0.9,
        ),
      );
    }

    final unique = <String, MealInterpretationCandidate>{};
    for (final candidate in candidates) {
      final key = '${_normalize(candidate.title)}|${candidate.defaultUnit}';
      final current = unique[key];
      if (current == null || current.sourcePriority < candidate.sourcePriority) {
        unique[key] = candidate;
      }
    }
    return unique.values.toList(growable: false);
  }

  _CandidateMatch? _findBestCandidate(
    String label,
    List<MealInterpretationCandidate> candidates, {
    required IntakeTypeEntity intakeType,
  }) {
    _CandidateMatch? bestMatch;
    for (final candidate in candidates) {
      final score = _scoreCandidate(label, candidate, intakeType: intakeType);
      if (bestMatch == null || score > bestMatch.score) {
        bestMatch = _CandidateMatch(candidate: candidate, score: score);
      }
    }
    return bestMatch;
  }

  AiFoodMemoryEntry? _findReliableCorrection(
    InterpretationDraftItemEntity item,
    Map<String, AiFoodMemoryEntry> correctionMap,
  ) {
    final normalizedLabel = _normalize(item.label);
    if (normalizedLabel.isEmpty) {
      return null;
    }

    final exact = correctionMap[normalizedLabel];
    if (exact != null) {
      return exact;
    }

    final itemTokens = _tokens(item.label);
    AiFoodMemoryEntry? bestCorrection;
    double bestScore = 0;
    for (final entry in correctionMap.entries) {
      final candidate = entry.value;
      if (candidate.uses < 3) {
        continue;
      }

      final candidateTokens = _tokens(candidate.displayLabel);
      final sharedTokens = itemTokens.intersection(candidateTokens).length;
      if (sharedTokens == 0) {
        continue;
      }

      final score = _textSimilarity(normalizedLabel, entry.key);
      final hasStrongTokenOverlap =
          sharedTokens >= 2 || itemTokens.difference(candidateTokens).isEmpty;
      if (score >= 0.9 &&
          hasStrongTokenOverlap &&
          _isCompatibleCorrection(item, candidate) &&
          score > bestScore) {
        bestScore = score;
        bestCorrection = candidate;
      }
    }

    return bestCorrection;
  }

  bool _isCompatibleCorrection(
    InterpretationDraftItemEntity item,
    AiFoodMemoryEntry candidate,
  ) {
    final itemUnit = item.unit.trim().toLowerCase();
    final candidateUnit = candidate.unit.trim().toLowerCase();
    if (itemUnit.isNotEmpty &&
        candidateUnit.isNotEmpty &&
        itemUnit == candidateUnit) {
      return true;
    }

    final itemMealName = _normalize(item.matchedMealSnapshot?.name ?? '');
    final candidateMealName = _normalize(candidate.mealSnapshot?.name ?? '');
    if (itemMealName.isNotEmpty &&
        candidateMealName.isNotEmpty &&
        itemMealName == candidateMealName) {
      return true;
    }

    return item.matchedMealSnapshot == null || candidate.mealSnapshot == null;
  }

  double _scoreCandidate(
    String? query,
    MealInterpretationCandidate candidate, {
    required IntakeTypeEntity intakeType,
  }) {
    if (query == null || query.trim().isEmpty) {
      return candidate.sourcePriority;
    }

    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return candidate.sourcePriority;
    }

    double best = 0;
    for (final term in candidate.searchTerms) {
      final normalizedTerm = _normalize(term);
      if (normalizedTerm.isEmpty) {
        continue;
      }
      best = best > _textSimilarity(normalizedQuery, normalizedTerm)
          ? best
          : _textSimilarity(normalizedQuery, normalizedTerm);
    }

    final intakeBoost =
        normalizedQuery.contains(_normalize(intakeType.name)) ? 0.04 : 0;
    return best + candidate.sourcePriority * 0.1 + intakeBoost;
  }

  double _textSimilarity(String a, String b) {
    if (a == b) {
      return 1;
    }
    if (a.contains(b) || b.contains(a)) {
      return 0.92;
    }

    final aTokens = _tokens(a);
    final bTokens = _tokens(b);
    if (aTokens.isEmpty || bTokens.isEmpty) {
      return 0;
    }

    final overlap = aTokens.intersection(bTokens).length;
    final union = aTokens.union(bTokens).length;
    final jaccard = union == 0 ? 0 : overlap / union;

    var charBonus = 0.0;
    for (final token in aTokens) {
      if (bTokens.any((other) => other.startsWith(token) || token.startsWith(other))) {
        charBonus += 0.08;
      }
    }

    return (jaccard + charBonus).clamp(0, 1).toDouble();
  }

  Set<String> _tokens(String input) {
    const stopwords = {
      'de',
      'la',
      'el',
      'los',
      'las',
      'con',
      'and',
      'the',
      'a',
      'an',
      'y',
      'para',
      'del',
      'al',
      'mi',
      'mis',
      'your',
      'meal',
      'comida',
    };

    return _normalize(input)
        .split(' ')
        .where((token) => token.length > 1 && !stopwords.contains(token))
        .toSet();
  }

  String _normalize(String input) {
    const replacements = {
      '\u00e1': 'a',
      '\u00e0': 'a',
      '\u00e4': 'a',
      '\u00e2': 'a',
      '\u00e3': 'a',
      '\u00e9': 'e',
      '\u00e8': 'e',
      '\u00eb': 'e',
      '\u00ea': 'e',
      '\u00ed': 'i',
      '\u00ec': 'i',
      '\u00ef': 'i',
      '\u00ee': 'i',
      '\u00f3': 'o',
      '\u00f2': 'o',
      '\u00f6': 'o',
      '\u00f4': 'o',
      '\u00f5': 'o',
      '\u00fa': 'u',
      '\u00f9': 'u',
      '\u00fc': 'u',
      '\u00fb': 'u',
      '\u00f1': 'n',
      'ÃƒÂ¡': 'a',
      'ÃƒÂ ': 'a',
      'ÃƒÂ¤': 'a',
      'ÃƒÂ¢': 'a',
      'ÃƒÂ£': 'a',
      'ÃƒÂ©': 'e',
      'ÃƒÂ¨': 'e',
      'ÃƒÂ«': 'e',
      'ÃƒÂª': 'e',
      'ÃƒÂ­': 'i',
      'ÃƒÂ¬': 'i',
      'ÃƒÂ¯': 'i',
      'ÃƒÂ®': 'i',
      'ÃƒÂ³': 'o',
      'ÃƒÂ²': 'o',
      'ÃƒÂ¶': 'o',
      'ÃƒÂ´': 'o',
      'ÃƒÂµ': 'o',
      'ÃƒÂº': 'u',
      'ÃƒÂ¹': 'u',
      'ÃƒÂ¼': 'u',
      'ÃƒÂ»': 'u',
      'ÃƒÂ±': 'n',
      'ÃƒÆ’Ã‚Â¡': 'a',
      'ÃƒÆ’Ã‚Â ': 'a',
      'ÃƒÆ’Ã‚Â¤': 'a',
      'ÃƒÆ’Ã‚Â¢': 'a',
      'ÃƒÆ’Ã‚Â£': 'a',
      'ÃƒÆ’Ã‚Â©': 'e',
      'ÃƒÆ’Ã‚Â¨': 'e',
      'ÃƒÆ’Ã‚Â«': 'e',
      'ÃƒÆ’Ã‚Âª': 'e',
      'ÃƒÆ’Ã‚Â­': 'i',
      'ÃƒÆ’Ã‚Â¬': 'i',
      'ÃƒÆ’Ã‚Â¯': 'i',
      'ÃƒÆ’Ã‚Â®': 'i',
      'ÃƒÆ’Ã‚Â³': 'o',
      'ÃƒÆ’Ã‚Â²': 'o',
      'ÃƒÆ’Ã‚Â¶': 'o',
      'ÃƒÆ’Ã‚Â´': 'o',
      'ÃƒÆ’Ã‚Âµ': 'o',
      'ÃƒÆ’Ã‚Âº': 'u',
      'ÃƒÆ’Ã‚Â¹': 'u',
      'ÃƒÆ’Ã‚Â¼': 'u',
      'ÃƒÆ’Ã‚Â»': 'u',
      'ÃƒÆ’Ã‚Â±': 'n',
    };

    var normalized = input.toLowerCase();
    replacements.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  String _draftSearchText(InterpretationDraftEntity draft) {
    final items = draft.items
        .where((item) => !item.removed)
        .map((item) => item.label)
        .join(' ');
    return '${draft.title} ${draft.summary ?? ''} $items'.trim();
  }

  String _goalLabel(UserWeightGoalEntity goal) {
    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        return 'cut';
      case UserWeightGoalEntity.maintainWeight:
        return 'recomposition';
      case UserWeightGoalEntity.gainWeight:
        return 'lean bulk';
    }
  }

  String _focusLabel(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 'lower body';
      case DailyFocusEntity.upperBody:
        return 'upper body';
      case DailyFocusEntity.cardio:
        return 'cardio';
      case DailyFocusEntity.rest:
        return 'rest day';
    }
  }
}

class MealInterpretationPersonalizationContext {
  final String promptContext;
  final List<Map<String, dynamic>> remoteExamples;
  final List<MealInterpretationCandidate> candidates;

  const MealInterpretationPersonalizationContext({
    required this.promptContext,
    required this.remoteExamples,
    required this.candidates,
  });
}

class MealInterpretationSuggestion {
  final String id;
  final String title;
  final String sourceLabel;
  final MealEntity meal;
  final double defaultAmount;
  final String defaultUnit;
  final double score;

  const MealInterpretationSuggestion({
    required this.id,
    required this.title,
    required this.sourceLabel,
    required this.meal,
    required this.defaultAmount,
    required this.defaultUnit,
    required this.score,
  });
}

class MealInterpretationCandidate {
  final String id;
  final String title;
  final String sourceLabel;
  final MealEntity meal;
  final double defaultAmount;
  final String defaultUnit;
  final List<String> searchTerms;
  final bool preferStoredPortion;
  final double sourcePriority;

  const MealInterpretationCandidate({
    required this.id,
    required this.title,
    required this.sourceLabel,
    required this.meal,
    required this.defaultAmount,
    required this.defaultUnit,
    required this.searchTerms,
    required this.preferStoredPortion,
    required this.sourcePriority,
  });

  Map<String, dynamic> toRemoteMap() {
    final nutrition = MealPortionCalculator.calculate(
      meal,
      defaultAmount,
      defaultUnit,
    );
    return {
      'title': title,
      'sourceLabel': sourceLabel,
      'defaultAmount': defaultAmount,
      'defaultUnit': defaultUnit,
      'kcal': nutrition.kcal,
      'carbs': nutrition.carbs,
      'fat': nutrition.fat,
      'protein': nutrition.protein,
    };
  }
}

class _CandidateMatch {
  final MealInterpretationCandidate candidate;
  final double score;

  const _CandidateMatch({
    required this.candidate,
    required this.score,
  });
}
