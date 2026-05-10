import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_ingredient_dbo.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

part 'recipe_dbo.g.dart';

@HiveType(typeId: 18)
@JsonSerializable()
class RecipeDBO extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? notes;
  @HiveField(3)
  final double defaultServings;
  @HiveField(4)
  final double? yieldQuantity;
  @HiveField(5)
  final String? yieldUnit;
  @HiveField(6)
  @JsonKey(name: 'favorite')
  bool saved;
  @HiveField(11)
  @JsonKey(defaultValue: false)
  bool pinned;
  @HiveField(12)
  @JsonKey(defaultValue: 0)
  int timesUsed;
  @HiveField(13)
  DateTime? lastUsedAt;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  DateTime updatedAt;
  @HiveField(9)
  final List<RecipeIngredientDBO> ingredients;
  @HiveField(10)
  final String? quickCategory;

  RecipeDBO({
    required this.id,
    required this.name,
    required this.notes,
    required this.defaultServings,
    required this.yieldQuantity,
    required this.yieldUnit,
    required this.saved,
    required this.pinned,
    required this.timesUsed,
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.ingredients,
    required this.quickCategory,
  });

  factory RecipeDBO.fromEntity(RecipeEntity entity) {
    return RecipeDBO(
      id: entity.id,
      name: entity.name,
      notes: entity.notes,
      defaultServings: entity.defaultServings,
      yieldQuantity: entity.yieldQuantity,
      yieldUnit: entity.yieldUnit,
      saved: entity.saved,
      pinned: entity.pinned,
      timesUsed: entity.timesUsed,
      lastUsedAt: entity.lastUsedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      ingredients:
          entity.ingredients.map(RecipeIngredientDBO.fromEntity).toList(),
      quickCategory: entity.quickCategory?.name,
    );
  }

  QuickRecipeCategoryEntity? get quickCategoryEntity {
    final value = quickCategory;
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final category in QuickRecipeCategoryEntity.values) {
      if (category.name == value) {
        return category;
      }
    }
    return null;
  }

  factory RecipeDBO.fromJson(Map<String, dynamic> json) =>
      _$RecipeDBOFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeDBOToJson(this);
}
