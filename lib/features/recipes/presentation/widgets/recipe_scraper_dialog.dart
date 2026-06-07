import 'package:flutter/material.dart';
import 'package:macrotracker/core/presentation/widgets/ai_usage_gate.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/recipes/data/data_source/recipe_scraper_data_source.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class RecipeScraperDialog extends StatefulWidget {
  const RecipeScraperDialog({super.key});

  static Future<RecipeEntity?> show(BuildContext context) {
    return showDialog<RecipeEntity>(
      context: context,
      builder: (context) => const RecipeScraperDialog(),
    );
  }

  static RecipeEntity mapScrapedToRecipeEntity(ScrapedRecipeEntity scraped) {
    final recipeId = IdGenerator.getUniqueID();
    final now = DateTime.now();

    final ingredientsList = <RecipeIngredientEntity>[];
    for (var i = 0; i < scraped.ingredients.length; i++) {
      final ing = scraped.ingredients[i];

      final isLiquid = ing.unit == 'ml' || ing.unit == 'fl oz';
      final isServingUnit = ing.unit == 'serving' || ing.unit == 'piece';

      final mealSnapshot = MealEntity(
        code: IdGenerator.getUniqueID(),
        name: ing.name,
        brands: null,
        thumbnailImageUrl: null,
        mainImageUrl: null,
        url: null,
        mealQuantity: null,
        mealUnit: isLiquid ? 'ml' : 'g',
        servingQuantity: isServingUnit ? 1.0 : null,
        servingUnit: isServingUnit ? ing.unit : null,
        servingSize: isServingUnit ? ing.unit : '',
        source: MealSourceEntity.custom,
        nutriments: MealNutrimentsEntity(
          energyKcal100: ing.kcal100,
          carbohydrates100: ing.carbs100,
          fat100: ing.fat100,
          proteins100: ing.protein100,
          sugars100: null,
          saturatedFat100: null,
          fiber100: null,
        ),
      );

      ingredientsList.add(RecipeIngredientEntity(
        id: IdGenerator.getUniqueID(),
        mealSnapshot: mealSnapshot,
        amount: ing.amount,
        unit: ing.unit,
        position: i,
      ));
    }

    return RecipeEntity(
      id: recipeId,
      name: scraped.title,
      notes: scraped.instructions.join('\n'),
      defaultServings: scraped.servings,
      yieldQuantity: scraped.servings,
      yieldUnit: 'serving',
      saved: false,
      pinned: false,
      timesUsed: 0,
      lastUsedAt: null,
      quickCategory: null,
      createdAt: now,
      updatedAt: now,
      ingredients: ingredientsList,
    );
  }

  @override
  State<RecipeScraperDialog> createState() => _RecipeScraperDialogState();
}

class _RecipeScraperDialogState extends State<RecipeScraperDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es';

  Future<void> _scrape() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = _isEs(context)
            ? 'Por favor, introduce un enlace válido.'
            : 'Please enter a valid URL.';
      });
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _errorMessage = _isEs(context)
            ? 'El enlace debe comenzar con http:// o https://'
            : 'URL must start with http:// or https://';
      });
      return;
    }

    final locale = Localizations.localeOf(context).toLanguageTag();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Guard check with AI Usage Gate
      final access = await AiUsageGate.ensureAccess(
        context,
        placement: PaywallPlacement.aiText,
      );

      if (!access.allowed) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Perform scraping
      final scraperSource = locator<RecipeScraperDataSource>();
      final result = await scraperSource.scrapeRecipe(
        url: url,
        locale: locale,
      );

      // 3. Consume trial use if allowed
      await AiUsageGate.consumeTrialUse(access);

      // 4. Map ScrapedRecipeEntity to RecipeEntity
      final recipe = RecipeScraperDialog.mapScrapedToRecipeEntity(result.recipe);

      if (mounted) {
        Navigator.of(context).pop(recipe);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEs = _isEs(context);

    return AlertDialog(
      title: Text(
        isEs ? 'Importar receta con IA' : 'Import recipe with AI',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEs
                ? 'Pega el enlace de un blog de cocina o receta para que la IA la extraiga automáticamente.'
                : 'Paste a link to a cooking blog or recipe and the AI will extract it automatically.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Extrayendo receta con IA...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: isEs ? 'Enlace de la receta (URL)' : 'Recipe URL',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _scrape(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(isEs ? 'Cancelar' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _scrape,
          child: Text(isEs ? 'Importar' : 'Import'),
        ),
      ],
    );
  }
}
