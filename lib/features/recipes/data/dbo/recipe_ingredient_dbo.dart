import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

part 'recipe_ingredient_dbo.g.dart';

@HiveType(typeId: 19)
@JsonSerializable()
class RecipeIngredientDBO extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final MealDBO mealSnapshot;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String unit;
  @HiveField(4)
  final int position;

  RecipeIngredientDBO({
    required this.id,
    required this.mealSnapshot,
    required this.amount,
    required this.unit,
    required this.position,
  });

  factory RecipeIngredientDBO.fromEntity(RecipeIngredientEntity entity) {
    return RecipeIngredientDBO(
      id: entity.id,
      mealSnapshot: MealDBO.fromMealEntity(entity.mealSnapshot),
      amount: entity.amount,
      unit: entity.unit,
      position: entity.position,
    );
  }

  factory RecipeIngredientDBO.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientDBOFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientDBOToJson(this);
}
