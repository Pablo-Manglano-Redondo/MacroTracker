import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class RecipeEditorScreen extends StatefulWidget {
  const RecipeEditorScreen({super.key});

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  late RecipeEntity _recipe;
  late TextEditingController _nameController;
  late TextEditingController _servingsController;
  late TextEditingController _notesController;
  late RecipeSaveCategoryEntity _selectedCategory;
  late bool _pinned;
  late List<_EditableRecipeIngredient> _ingredients;
  bool _didInit = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments
        as RecipeEditorScreenArguments?;
    if (args == null) {
      Navigator.of(context).pop();
      return;
    }
    _recipe = args.recipe;
    _nameController = TextEditingController(text: _recipe.name);
    _servingsController = TextEditingController(
      text: _formatServings(_recipe.defaultServings),
    );
    _notesController = TextEditingController(
      text: _cleanIntakeTypeTags(_recipe.notes) ?? '',
    );
    _selectedCategory = RecipeSaveCategoryEntityX.fromRecipe(_recipe);
    _pinned = _recipe.pinned;
    _ingredients = _recipe.ingredients
        .map((ingredient) => _EditableRecipeIngredient.fromEntity(ingredient))
        .toList();
    _didInit = true;
  }

  @override
  void dispose() {
    if (_didInit) {
      _nameController.dispose();
      _servingsController.dispose();
      _notesController.dispose();
      for (final ingredient in _ingredients) {
        ingredient.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_didInit) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEs(context) ? 'Editar receta' : 'Edit recipe'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: S.of(context).aiRecipeNameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _servingsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: S.of(context).servingsLabel,
              helperText: _isEs(context)
                  ? 'Ración por defecto al registrar esta receta.'
                  : 'Default serving amount when logging this recipe.',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RecipeSaveCategoryEntity>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: S.of(context).recipeQuickCategoryLabel,
              border: const OutlineInputBorder(),
            ),
            items: RecipeSaveCategoryEntity.values
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(_categoryLabel(category)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: _isEs(context) ? 'Notas de la receta' : 'Recipe notes',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildIngredientsSection(),
          const SizedBox(height: 16),
          _buildMacroSummary(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isEs(context) ? 'Guardar receta' : 'Save recipe'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final isEs = _isEs(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEs ? 'Ingredientes' : 'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add_outlined),
                  label: Text(isEs ? 'Añadir' : 'Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_ingredients.isEmpty)
              Text(
                isEs
                    ? 'Añade alimentos para poder ajustar la receta.'
                    : 'Add foods to adjust this recipe.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ..._ingredients.map(_buildIngredientEditor),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummary() {
    final isEs = _isEs(context);
    final totals = _currentTotals();
    final servings = _parsedServings();
    final perServing = servings > 0
        ? _MacroTotals(
            kcal: totals.kcal / servings,
            carbs: totals.carbs / servings,
            fat: totals.fat / servings,
            protein: totals.protein / servings,
          )
        : totals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEs ? 'Resumen nutricional' : 'Nutrition summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(
                  icon: Icons.local_fire_department_outlined,
                  label: '${perServing.kcal.toStringAsFixed(0)} kcal',
                ),
                _StatChip(
                  icon: Icons.cookie_outlined,
                  label: 'C ${perServing.carbs.toStringAsFixed(1)} g',
                ),
                _StatChip(
                  icon: Icons.opacity_outlined,
                  label: 'F ${perServing.fat.toStringAsFixed(1)} g',
                ),
                _StatChip(
                  icon: Icons.egg_alt_outlined,
                  label: 'P ${perServing.protein.toStringAsFixed(1)} g',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isEs
                  ? 'Por racion. Total receta: ${totals.kcal.toStringAsFixed(0)} kcal.'
                  : 'Per serving. Full recipe: ${totals.kcal.toStringAsFixed(0)} kcal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientEditor(_EditableRecipeIngredient ingredient) {
    final isEs = _isEs(context);
    final colorScheme = Theme.of(context).colorScheme;
    final units = _allowedUnits(ingredient.meal, ingredient.unit);
    final nutrition = _ingredientNutrition(ingredient);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.meal.name ?? (isEs ? 'Alimento' : 'Food'),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (ingredient.meal.brands?.trim().isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              ingredient.meal.brands!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isEs ? 'Cambiar alimento' : 'Change food',
                    onPressed: () => _replaceIngredient(ingredient),
                    icon: const Icon(Icons.swap_horiz_outlined),
                  ),
                  IconButton(
                    tooltip: isEs ? 'Duplicar' : 'Duplicate',
                    onPressed: () => _duplicateIngredient(ingredient),
                    icon: const Icon(Icons.content_copy_outlined),
                  ),
                  IconButton(
                    tooltip: isEs ? 'Eliminar' : 'Remove',
                    onPressed: () => _removeIngredient(ingredient),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ingredient.amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isEs ? 'Cantidad' : 'Amount',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      initialValue: units.contains(ingredient.unit)
                          ? ingredient.unit
                          : units.first,
                      decoration: InputDecoration(
                        labelText: isEs ? 'Unidad' : 'Unit',
                        border: const OutlineInputBorder(),
                      ),
                      items: units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(_unitLabel(unit)),
                            ),
                          )
                          .toList(),
                      onChanged: (unit) {
                        if (unit == null) {
                          return;
                        }
                        setState(() => ingredient.unit = unit);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${nutrition.kcal.toStringAsFixed(0)} kcal',
                  ),
                  _StatChip(
                    icon: Icons.cookie_outlined,
                    label: 'C ${nutrition.carbs.toStringAsFixed(1)}',
                  ),
                  _StatChip(
                    icon: Icons.opacity_outlined,
                    label: 'F ${nutrition.fat.toStringAsFixed(1)}',
                  ),
                  _StatChip(
                    icon: Icons.egg_alt_outlined,
                    label: 'P ${nutrition.protein.toStringAsFixed(1)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  MealPortionNutrition _ingredientNutrition(
    _EditableRecipeIngredient ingredient,
  ) {
    final amount = double.tryParse(
          ingredient.amountController.text.trim().replaceAll(',', '.'),
        ) ??
        0;
    return MealPortionCalculator.calculate(
      ingredient.meal,
      amount,
      ingredient.unit,
    );
  }

  _MacroTotals _currentTotals() {
    var kcal = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    var protein = 0.0;

    for (final ingredient in _ingredients) {
      final nutrition = _ingredientNutrition(ingredient);
      kcal += nutrition.kcal;
      carbs += nutrition.carbs;
      fat += nutrition.fat;
      protein += nutrition.protein;
    }

    return _MacroTotals(
      kcal: kcal,
      carbs: carbs,
      fat: fat,
      protein: protein,
    );
  }

  double _parsedServings() {
    return double.tryParse(
          _servingsController.text.trim().replaceAll(',', '.'),
        ) ??
        1;
  }

  Future<void> _addIngredient() async {
    final meal = await _pickMeal();
    if (meal == null || !mounted) {
      return;
    }
    setState(() {
      _ingredients.add(_EditableRecipeIngredient(
        id: IdGenerator.getUniqueID(),
        meal: meal,
        amount: _defaultAmount(meal),
        unit: _defaultUnit(meal),
      ));
    });
  }

  Future<void> _replaceIngredient(_EditableRecipeIngredient ingredient) async {
    final meal = await _pickMeal();
    if (meal == null || !mounted) {
      return;
    }
    setState(() {
      ingredient.meal = meal;
      ingredient.unit = _defaultUnit(meal);
      ingredient.amountController.text = _formatServings(
        _defaultAmount(meal),
      );
    });
  }

  void _removeIngredient(_EditableRecipeIngredient ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
      ingredient.dispose();
    });
  }

  Future<MealEntity?> _pickMeal() {
    return showModalBottomSheet<MealEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _MealPickerSheet(),
    );
  }

  void _duplicateIngredient(_EditableRecipeIngredient ingredient) {
    final amount = double.tryParse(
          ingredient.amountController.text.trim().replaceAll(',', '.'),
        ) ??
        100;
    setState(() {
      _ingredients.add(_EditableRecipeIngredient(
        id: IdGenerator.getUniqueID(),
        meal: ingredient.meal,
        amount: amount,
        unit: ingredient.unit,
      ));
    });
  }

  List<String> _allowedUnits(MealEntity meal, String selectedUnit) {
    final units = <String>{};
    if (meal.hasServingValues) {
      units.add('serving');
    }
    if (meal.mealUnit != null && meal.mealUnit!.trim().isNotEmpty) {
      units.add(meal.mealUnit!.trim());
    }
    if (meal.servingUnit != null && meal.servingUnit!.trim().isNotEmpty) {
      units.add(meal.servingUnit!.trim());
    }
    units.add(meal.isLiquid ? 'ml' : 'g');
    units.add(meal.isLiquid ? 'fl oz' : 'oz');
    units.add(selectedUnit);
    return units.toList();
  }

  String _defaultUnit(MealEntity meal) {
    if (meal.hasServingValues) {
      return 'serving';
    }
    if (meal.mealUnit != null && meal.mealUnit!.trim().isNotEmpty) {
      return meal.mealUnit!.trim();
    }
    return meal.isLiquid ? 'ml' : 'g';
  }

  double _defaultAmount(MealEntity meal) {
    return meal.hasServingValues ? 1 : 100;
  }

  String _unitLabel(String unit) {
    if (unit == 'serving') {
      return _isEs(context) ? 'racion' : 'serving';
    }
    return unit;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final servings =
        double.tryParse(_servingsController.text.trim().replaceAll(',', '.'));
    if (name.isEmpty || servings == null || servings <= 0) {
      _showInvalidRecipeMessage();
      return;
    }

    final ingredients = <RecipeIngredientEntity>[];
    for (var i = 0; i < _ingredients.length; i++) {
      final editable = _ingredients[i];
      final amount = double.tryParse(
        editable.amountController.text.trim().replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) {
        _showInvalidRecipeMessage();
        return;
      }
      ingredients.add(RecipeIngredientEntity(
        id: editable.id,
        mealSnapshot: editable.meal,
        amount: amount,
        unit: editable.unit,
        position: i,
      ));
    }

    if (ingredients.isEmpty) {
      _showInvalidRecipeMessage();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updated = _recipe.copyWith(
      name: name,
      defaultServings: servings,
      saved: true,
      pinned: _pinned,
      quickCategory: _selectedCategory.quickCategory,
      notes: QuickRecipeCategoryEntityX.applyExplicitIntakeTypeTag(
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        _selectedCategory.explicitIntakeType,
      ),
      ingredients: ingredients,
      updatedAt: DateTime.now(),
    );
    await locator<SaveRecipeUsecase>().saveRecipe(updated);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _showInvalidRecipeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEs(context)
            ? 'Revisa nombre, raciones e ingredientes.'
            : 'Check name, servings, and ingredients.'),
      ),
    );
  }

  String _categoryLabel(RecipeSaveCategoryEntity category) {
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
        return S.of(context).quickCategoryPreWorkout;
      case RecipeSaveCategoryEntity.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case RecipeSaveCategoryEntity.shake:
        return S.of(context).quickCategoryShake;
    }
  }

  String _formatServings(double servings) {
    return servings % 1 == 0
        ? servings.toStringAsFixed(0)
        : servings.toString();
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  String? _cleanIntakeTypeTags(String? notes) {
    if (notes == null) {
      return null;
    }
    final cleaned = notes
        .replaceAll(RegExp(r'#breakfast\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#desayuno\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#lunch\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#comida\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#dinner\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#cena\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#snack\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempie\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempie\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }
}

class RecipeEditorScreenArguments {
  final RecipeEntity recipe;

  const RecipeEditorScreenArguments(this.recipe);
}

class _MacroTotals {
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;

  const _MacroTotals({
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
  });
}

class _EditableRecipeIngredient {
  final String id;
  final TextEditingController amountController;
  MealEntity meal;
  String unit;

  _EditableRecipeIngredient({
    required this.id,
    required this.meal,
    required double amount,
    required this.unit,
  }) : amountController = TextEditingController(
          text: amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toString(),
        );

  factory _EditableRecipeIngredient.fromEntity(
    RecipeIngredientEntity ingredient,
  ) {
    return _EditableRecipeIngredient(
      id: ingredient.id,
      meal: ingredient.mealSnapshot,
      amount: ingredient.amount,
      unit: ingredient.unit,
    );
  }

  void dispose() {
    amountController.dispose();
  }
}

class _MealPickerSheet extends StatefulWidget {
  const _MealPickerSheet();

  @override
  State<_MealPickerSheet> createState() => _MealPickerSheetState();
}

class _MealPickerSheetState extends State<_MealPickerSheet> {
  final _controller = TextEditingController();
  List<MealEntity> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _usedOfflineCache = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEs ? 'Buscar alimento' : 'Search food',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: isEs ? 'Alimento' : 'Food',
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: IconButton(
                    onPressed: _isLoading ? null : _search,
                    icon: const Icon(Icons.arrow_forward_outlined),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildResults(isEs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(bool isEs) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasSearched) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          isEs
              ? 'Busca un alimento para añadirlo a la receta.'
              : 'Search for a food to add it to the recipe.',
        ),
      );
    }
    if (_results.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _errorMessage ?? (isEs ? 'Sin resultados.' : 'No results.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length + (_usedOfflineCache ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (_usedOfflineCache && index == 0) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.offline_pin_outlined),
            title: Text(
              isEs ? 'Resultados de cache local' : 'Local cache results',
            ),
          );
        }
        final meal = _results[_usedOfflineCache ? index - 1 : index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(meal.name ?? (isEs ? 'Alimento' : 'Food')),
          subtitle: Text(_mealSubtitle(meal)),
          trailing: Text(
            '${((meal.nutriments.energyPerUnit ?? 0) * _initialAmount(meal)).toStringAsFixed(0)} kcal',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () => Navigator.of(context).pop(meal),
        );
      },
    );
  }

  String _mealSubtitle(MealEntity meal) {
    final parts = <String>[];
    if (meal.brands?.trim().isNotEmpty == true) {
      parts.add(meal.brands!.trim());
    }
    parts.add(meal.source.name.toUpperCase());
    final unit = _initialUnit(meal);
    final amount = _initialAmount(meal);
    parts.add(
        '${amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(1)} $unit');
    if (meal.servingSize?.trim().isNotEmpty == true) {
      parts.add(meal.servingSize!.trim());
    }
    return parts.join(' | ');
  }

  double _initialAmount(MealEntity meal) {
    return meal.hasServingValues ? 1 : 100;
  }

  String _initialUnit(MealEntity meal) {
    if (meal.hasServingValues) {
      return 'serving';
    }
    return meal.isLiquid ? 'ml' : 'g';
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _usedOfflineCache = false;
      _errorMessage = null;
    });

    try {
      final usecase = locator<SearchProductsUseCase>();
      var results = await usecase.searchOFFProductsByString(query);
      if (results.isEmpty) {
        results = await usecase.searchFDCFoodByString(query);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _results = results;
        _isLoading = false;
        _usedOfflineCache = false;
      });
    } catch (_) {
      try {
        final results =
            await locator<SearchProductsUseCase>().searchOfflineCache(query);
        if (!mounted) {
          return;
        }
        setState(() {
          _results = results;
          _isLoading = false;
          _usedOfflineCache = results.isNotEmpty;
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _results = const [];
          _isLoading = false;
          _usedOfflineCache = false;
          _errorMessage = Localizations.localeOf(context).languageCode == 'es'
              ? 'No se pudo buscar ahora. Revisa la conexion e intentalo de nuevo.'
              : 'Search is unavailable right now. Check the connection and try again.';
        });
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
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
            .withValues(alpha: 0.55),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
