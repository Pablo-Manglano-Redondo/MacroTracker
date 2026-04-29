import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class AiMealMemoryEntry extends Equatable {
  final String key;
  final String title;
  final String searchText;
  final IntakeTypeEntity intakeType;
  final MealEntity mealSnapshot;
  final double defaultAmount;
  final String defaultUnit;
  final int uses;
  final DateTime updatedAt;

  const AiMealMemoryEntry({
    required this.key,
    required this.title,
    required this.searchText,
    required this.intakeType,
    required this.mealSnapshot,
    required this.defaultAmount,
    required this.defaultUnit,
    required this.uses,
    required this.updatedAt,
  });

  factory AiMealMemoryEntry.fromMap(String key, Map<dynamic, dynamic> map) {
    return AiMealMemoryEntry(
      key: key,
      title: map['title']?.toString() ?? key,
      searchText: map['searchText']?.toString() ?? '',
      intakeType: _intakeTypeFromString(map['intakeType']?.toString()),
      mealSnapshot: _mealFromMap(map['mealSnapshot'] as Map? ?? const {}),
      defaultAmount: (map['defaultAmount'] as num?)?.toDouble() ?? 1,
      defaultUnit: map['defaultUnit']?.toString() ?? 'serving',
      uses: (map['uses'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'searchText': searchText,
        'intakeType': intakeType.name,
        'mealSnapshot': _mealToMap(mealSnapshot),
        'defaultAmount': defaultAmount,
        'defaultUnit': defaultUnit,
        'uses': uses,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static IntakeTypeEntity _intakeTypeFromString(String? value) {
    return IntakeTypeEntity.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => IntakeTypeEntity.breakfast,
    );
  }

  static MealEntity _mealFromMap(Map<dynamic, dynamic> raw) {
    final nutrimentsMap = raw['nutriments'] as Map? ?? const {};
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
      nutriments: MealNutrimentsEntity(
        energyKcal100: (nutrimentsMap['energyKcal100'] as num?)?.toDouble(),
        carbohydrates100:
            (nutrimentsMap['carbohydrates100'] as num?)?.toDouble(),
        fat100: (nutrimentsMap['fat100'] as num?)?.toDouble(),
        proteins100: (nutrimentsMap['proteins100'] as num?)?.toDouble(),
        sugars100: (nutrimentsMap['sugars100'] as num?)?.toDouble(),
        saturatedFat100:
            (nutrimentsMap['saturatedFat100'] as num?)?.toDouble(),
        fiber100: (nutrimentsMap['fiber100'] as num?)?.toDouble(),
      ),
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
        title,
        searchText,
        intakeType,
        mealSnapshot,
        defaultAmount,
        defaultUnit,
        uses,
        updatedAt,
      ];
}
