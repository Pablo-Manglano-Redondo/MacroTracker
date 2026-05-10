import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
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
  bool _didInit = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) {
      return;
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as RecipeEditorScreenArguments?;
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
    _didInit = true;
  }

  @override
  void dispose() {
    if (_didInit) {
      _nameController.dispose();
      _servingsController.dispose();
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final servings =
        double.tryParse(_servingsController.text.trim().replaceAll(',', '.'));
    if (name.isEmpty || servings == null || servings <= 0) {
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
      updatedAt: DateTime.now(),
    );
    await locator<SaveRecipeUsecase>().saveRecipe(updated);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
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
    return servings % 1 == 0 ? servings.toStringAsFixed(0) : servings.toString();
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
