import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
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
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isEs(context) ? 'Guardar' : 'Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          _buildIngredientsSection(),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _pinned,
            onChanged: (value) {
              setState(() {
                _pinned = value;
              });
            },
            title: Text(_isEs(context) ? 'Fijar arriba' : 'Pin to top'),
            subtitle: Text(
              _isEs(context)
                  ? 'Las recetas fijadas salen primero en la librería y accesos rápidos.'
                  : 'Pinned recipes appear first in the library and quick access lists.',
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEs(context) ? 'Uso' : 'Usage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.bookmark_outline,
                        label: _pinned
                            ? (_isEs(context) ? 'Fijada' : 'Pinned')
                            : (_isEs(context) ? 'No fijada' : 'Not pinned'),
                      ),
                      _StatChip(
                        icon: Icons.repeat_outlined,
                        label: _isEs(context)
                            ? '${_recipe.timesUsed} usos'
                            : '${_recipe.timesUsed} uses',
                      ),
                      if (_recipe.lastUsedAt != null)
                        _StatChip(
                          icon: Icons.schedule_outlined,
                          label: _isEs(context)
                              ? 'Último uso: ${_formatDate(_recipe.lastUsedAt!)}'
                              : 'Last used: ${_formatDate(_recipe.lastUsedAt!)}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildIngredientEditor(_EditableRecipeIngredient ingredient) {
    final isEs = _isEs(context);
    final colorScheme = Theme.of(context).colorScheme;
    final units = _allowedUnits(ingredient.meal, ingredient.unit);

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
                children: [
                  Expanded(
                    child: Text(
                      ingredient.meal.name ?? (isEs ? 'Alimento' : 'Food'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: isEs ? 'Cambiar alimento' : 'Change food',
                    onPressed: () => _replaceIngredient(ingredient),
                    icon: const Icon(Icons.swap_horiz_outlined),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value: units.contains(ingredient.unit)
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
            ],
          ),
        ),
      ),
    );
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
        amount: meal.servingQuantity ?? 100,
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
        meal.servingQuantity ?? 100,
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
    return showDialog<MealEntity>(
      context: context,
      builder: (context) => const _MealPickerDialog(),
    );
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
        _recipe.notes,
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

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }
}

class RecipeEditorScreenArguments {
  final RecipeEntity recipe;

  const RecipeEditorScreenArguments(this.recipe);
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

class _MealPickerDialog extends StatefulWidget {
  const _MealPickerDialog();

  @override
  State<_MealPickerDialog> createState() => _MealPickerDialogState();
}

class _MealPickerDialogState extends State<_MealPickerDialog> {
  final _controller = TextEditingController();
  List<MealEntity> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return AlertDialog(
      title: Text(isEs ? 'Buscar alimento' : 'Search food'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: isEs ? 'Alimento' : 'Food',
                suffixIcon: IconButton(
                  onPressed: _isLoading ? null : _search,
                  icon: const Icon(Icons.search_outlined),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: _buildResults(isEs),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isEs ? 'Cancelar' : 'Cancel'),
        ),
      ],
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
        child: Text(isEs ? 'Sin resultados.' : 'No results.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final meal = _results[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(meal.name ?? (isEs ? 'Alimento' : 'Food')),
          subtitle: meal.brands?.isNotEmpty == true ? Text(meal.brands!) : null,
          onTap: () => Navigator.of(context).pop(meal),
        );
      },
    );
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
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
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _results = const [];
          _isLoading = false;
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
