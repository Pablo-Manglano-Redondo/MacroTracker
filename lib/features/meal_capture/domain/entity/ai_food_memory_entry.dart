import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class AiFoodMemoryEntry extends Equatable {
  final String key;
  final String displayLabel;
  final double amount;
  final String unit;
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final MealEntity? mealSnapshot;
  final int uses;
  final DateTime updatedAt;

  const AiFoodMemoryEntry({
    required this.key,
    required this.displayLabel,
    required this.amount,
    required this.unit,
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.mealSnapshot,
    required this.uses,
    required this.updatedAt,
  });

  factory AiFoodMemoryEntry.fromMap(String key, Map<dynamic, dynamic> map) {
    return AiFoodMemoryEntry(
      key: key,
      displayLabel: map['displayLabel']?.toString() ?? key,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      unit: map['unit']?.toString() ?? 'serving',
      kcal: (map['kcal'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      mealSnapshot: _mealFromMap(map['mealSnapshot']),
      uses: (map['uses'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'displayLabel': displayLabel,
        'amount': amount,
        'unit': unit,
        'kcal': kcal,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
        'mealSnapshot': mealSnapshot == null ? null : _mealToMap(mealSnapshot!),
        'uses': uses,
        'updatedAt': updatedAt.toIso8601String(),
      };

  AiFoodMemoryEntry copyWith({
    String? key,
    String? displayLabel,
    double? amount,
    String? unit,
    double? kcal,
    double? carbs,
    double? fat,
    double? protein,
    MealEntity? mealSnapshot,
    int? uses,
    DateTime? updatedAt,
  }) {
    return AiFoodMemoryEntry(
      key: key ?? this.key,
      displayLabel: displayLabel ?? this.displayLabel,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      kcal: kcal ?? this.kcal,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      mealSnapshot: mealSnapshot ?? this.mealSnapshot,
      uses: uses ?? this.uses,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static MealEntity? _mealFromMap(dynamic raw) {
    if (raw is! Map) {
      return null;
    }

    final nutrimentsMap = raw['nutriments'];
    MealNutrimentsEntity nutriments = MealNutrimentsEntity.empty();
    if (nutrimentsMap is Map) {
      nutriments = MealNutrimentsEntity(
        energyKcal100: (nutrimentsMap['energyKcal100'] as num?)?.toDouble(),
        carbohydrates100:
            (nutrimentsMap['carbohydrates100'] as num?)?.toDouble(),
        fat100: (nutrimentsMap['fat100'] as num?)?.toDouble(),
        proteins100: (nutrimentsMap['proteins100'] as num?)?.toDouble(),
        sugars100: (nutrimentsMap['sugars100'] as num?)?.toDouble(),
        saturatedFat100:
            (nutrimentsMap['saturatedFat100'] as num?)?.toDouble(),
        fiber100: (nutrimentsMap['fiber100'] as num?)?.toDouble(),
      );
    }

    final sourceName = raw['source']?.toString();
    final source = MealSourceEntity.values.firstWhere(
      (value) => value.name == sourceName,
      orElse: () => MealSourceEntity.custom,
    );

    return MealEntity(
      code: raw['code']?.toString(),
      name: raw['name']?.toString(),
      brands: raw['brands']?.toString(),
      thumbnailImageUrl: raw['thumbnailImageUrl']?.toString(),
      mainImageUrl: raw['mainImageUrl']?.toString(),
      url: raw['url']?.toString(),
      mealQuantity: raw['mealQuantity']?.toString(),
      mealUnit: raw['mealUnit']?.toString(),
      servingQuantity: (raw['servingQuantity'] as num?)?.toDouble(),
      servingUnit: raw['servingUnit']?.toString(),
      servingSize: raw['servingSize']?.toString(),
      nutriments: nutriments,
      source: source,
    );
  }

  static Map<String, dynamic> _mealToMap(MealEntity meal) => {
        'code': meal.code,
        'name': meal.name,
        'brands': meal.brands,
        'thumbnailImageUrl': meal.thumbnailImageUrl,
        'mainImageUrl': meal.mainImageUrl,
        'url': meal.url,
        'mealQuantity': meal.mealQuantity,
        'mealUnit': meal.mealUnit,
        'servingQuantity': meal.servingQuantity,
        'servingUnit': meal.servingUnit,
        'servingSize': meal.servingSize,
        'source': meal.source.name,
        'nutriments': {
          'energyKcal100': meal.nutriments.energyKcal100,
          'carbohydrates100': meal.nutriments.carbohydrates100,
          'fat100': meal.nutriments.fat100,
          'proteins100': meal.nutriments.proteins100,
          'sugars100': meal.nutriments.sugars100,
          'saturatedFat100': meal.nutriments.saturatedFat100,
          'fiber100': meal.nutriments.fiber100,
        },
      };

  @override
  List<Object?> get props => [
        key,
        displayLabel,
        amount,
        unit,
        kcal,
        carbs,
        fat,
        protein,
        mealSnapshot,
        uses,
        updatedAt,
      ];
}
