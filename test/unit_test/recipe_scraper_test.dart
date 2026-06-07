import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/recipes/data/data_source/recipe_scraper_data_source.dart';
import 'package:macrotracker/features/recipes/presentation/widgets/recipe_scraper_dialog.dart';

void main() {
  group('RecipeScraper Models & Mapping Tests', () {
    final scrapedJson = {
      'title': 'Pollo al Curry Rápido',
      'servings': 4.0,
      'prepTimeMinutes': 10,
      'cookTimeMinutes': 20,
      'ingredients': [
        {
          'name': 'Pechuga de pollo',
          'amount': 500.0,
          'unit': 'g',
          'kcal100': 165.0,
          'carbs100': 0.0,
          'fat100': 3.6,
          'protein100': 31.0,
        },
        {
          'name': 'Leche de coco',
          'amount': 200.0,
          'unit': 'ml',
          'kcal100': 230.0,
          'carbs100': 6.0,
          'fat100': 24.0,
          'protein100': 2.0,
        },
        {
          'name': 'Huevo',
          'amount': 2.0,
          'unit': 'serving',
          'kcal100': 7800.0,
          'carbs100': 60.0,
          'fat100': 500.0,
          'protein100': 600.0,
        }
      ],
      'instructions': [
        'Paso 1: Trocea el pollo.',
        'Paso 2: Cocina con leche de curry.'
      ],
      'estimatedMacros': {
        'kcal': 1285.0,
        'carbs': 13.2,
        'fat': 66.0,
        'protein': 159.0,
      }
    };

    test('ScrapedRecipeEntity parses successfully from JSON', () {
      final scraped = ScrapedRecipeEntity.fromJson(scrapedJson);

      expect(scraped.title, 'Pollo al Curry Rápido');
      expect(scraped.servings, 4.0);
      expect(scraped.prepTimeMinutes, 10);
      expect(scraped.cookTimeMinutes, 20);

      expect(scraped.ingredients, hasLength(3));
      expect(scraped.ingredients[0].name, 'Pechuga de pollo');
      expect(scraped.ingredients[0].amount, 500.0);
      expect(scraped.ingredients[0].unit, 'g');
      expect(scraped.ingredients[0].kcal100, 165.0);

      expect(scraped.ingredients[1].unit, 'ml');
      expect(scraped.ingredients[1].kcal100, 230.0);

      expect(scraped.ingredients[2].unit, 'serving');
      expect(scraped.ingredients[2].kcal100, 7800.0);

      expect(scraped.instructions, hasLength(2));
      expect(scraped.instructions[0], 'Paso 1: Trocea el pollo.');

      expect(scraped.kcal, 1285.0);
      expect(scraped.carbs, 13.2);
      expect(scraped.fat, 66.0);
      expect(scraped.protein, 159.0);
    });

    test('RecipeScraperDialog maps ScrapedRecipeEntity to RecipeEntity correctly', () {
      final scraped = ScrapedRecipeEntity.fromJson(scrapedJson);
      final recipe = RecipeScraperDialog.mapScrapedToRecipeEntity(scraped);

      expect(recipe.id, isNotEmpty);
      expect(recipe.name, 'Pollo al Curry Rápido');
      expect(recipe.notes, 'Paso 1: Trocea el pollo.\nPaso 2: Cocina con leche de curry.');
      expect(recipe.defaultServings, 4.0);
      expect(recipe.yieldQuantity, 4.0);
      expect(recipe.yieldUnit, 'serving');
      expect(recipe.saved, isFalse);
      expect(recipe.pinned, isFalse);

      expect(recipe.ingredients, hasLength(3));

      // Ingredient 1: Pechuga de pollo (solid g unit)
      final ing1 = recipe.ingredients[0];
      expect(ing1.amount, 500.0);
      expect(ing1.unit, 'g');
      expect(ing1.mealSnapshot.name, 'Pechuga de pollo');
      expect(ing1.mealSnapshot.mealUnit, 'g');
      expect(ing1.mealSnapshot.hasServingValues, isFalse);
      expect(ing1.mealSnapshot.nutriments.energyKcal100, 165.0);
      expect(ing1.mealSnapshot.nutriments.proteins100, 31.0);

      // Ingredient 2: Leche de coco (liquid ml unit)
      final ing2 = recipe.ingredients[1];
      expect(ing2.amount, 200.0);
      expect(ing2.unit, 'ml');
      expect(ing2.mealSnapshot.mealUnit, 'ml');
      expect(ing2.mealSnapshot.hasServingValues, isFalse);
      expect(ing2.mealSnapshot.nutriments.energyKcal100, 230.0);

      // Ingredient 3: Huevo (serving unit)
      final ing3 = recipe.ingredients[2];
      expect(ing3.amount, 2.0);
      expect(ing3.unit, 'serving');
      expect(ing3.mealSnapshot.mealUnit, 'g'); // falls back to g for unit but serving values is true
      expect(ing3.mealSnapshot.hasServingValues, isTrue);
      expect(ing3.mealSnapshot.servingQuantity, 1.0);
      expect(ing3.mealSnapshot.servingUnit, 'serving');
      expect(ing3.mealSnapshot.nutriments.energyKcal100, 7800.0);
    });
  });
}
