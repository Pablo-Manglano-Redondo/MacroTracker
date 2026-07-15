import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_nutriments_dto.dart';

class MealNutrimentsEntity extends Equatable {
  final double? energyKcal100;

  final double? carbohydrates100;
  final double? fat100;
  final double? proteins100;
  final double? sugars100;
  final double? saturatedFat100;
  final double? fiber100;

  final double? sodium100;
  final double? potassium100;
  final double? calcium100;
  final double? iron100;
  final double? vitaminC100;
  final double? vitaminD100;
  final int? novaGroup;
  double? get energyPerUnit => _getValuePerUnit(energyKcal100);

  double? get carbohydratesPerUnit => _getValuePerUnit(carbohydrates100);

  double? get fatPerUnit => _getValuePerUnit(fat100);

  double? get proteinsPerUnit => _getValuePerUnit(proteins100);

  double? get sugarsPerUnit => _getValuePerUnit(sugars100);

  double? get saturatedFatPerUnit => _getValuePerUnit(saturatedFat100);

  double? get fiberPerUnit => _getValuePerUnit(fiber100);

  double? get sodiumPerUnit => _getValuePerUnit(sodium100);

  double? get potassiumPerUnit => _getValuePerUnit(potassium100);

  double? get calciumPerUnit => _getValuePerUnit(calcium100);

  double? get ironPerUnit => _getValuePerUnit(iron100);

  double? get vitaminCPerUnit => _getValuePerUnit(vitaminC100);

  double? get vitaminDPerUnit => _getValuePerUnit(vitaminD100);

  const MealNutrimentsEntity({
    required this.energyKcal100,
    required this.carbohydrates100,
    required this.fat100,
    required this.proteins100,
    required this.sugars100,
    required this.saturatedFat100,
    required this.fiber100,
    this.sodium100,
    this.potassium100,
    this.calcium100,
    this.iron100,
    this.vitaminC100,
    this.vitaminD100,
    this.novaGroup,
  });

  factory MealNutrimentsEntity.empty() => const MealNutrimentsEntity(
      energyKcal100: null,
      carbohydrates100: null,
      fat100: null,
      proteins100: null,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
      sodium100: null,
      potassium100: null,
      calcium100: null,
      iron100: null,
      vitaminC100: null,
      vitaminD100: null,
      novaGroup: null,
  );

  factory MealNutrimentsEntity.fromMealNutrimentsDBO(
      MealNutrimentsDBO nutriments) {
    return MealNutrimentsEntity(
        energyKcal100: nutriments.energyKcal100,
        carbohydrates100: nutriments.carbohydrates100,
        fat100: nutriments.fat100,
        proteins100: nutriments.proteins100,
        sugars100: nutriments.sugars100,
        saturatedFat100: nutriments.saturatedFat100,
        fiber100: nutriments.fiber100,
        sodium100: nutriments.sodium100,
        potassium100: nutriments.potassium100,
        calcium100: nutriments.calcium100,
        iron100: nutriments.iron100,
        vitaminC100: nutriments.vitaminC100,
        vitaminD100: nutriments.vitaminD100,
        novaGroup: nutriments.novaGroup,
    );
  }

  factory MealNutrimentsEntity.fromOffNutriments(
      OFFProductNutrimentsDTO offNutriments, [dynamic novaGroup]) {
    // 1. OFF product nutriments can either be String, int, double or null
    // 2. Extension function asDoubleOrNull does not work on a dynamic data
    // type, so cast to it Object?
    return MealNutrimentsEntity(
        energyKcal100:
            (offNutriments.energy_kcal_100g as Object?).asDoubleOrNull(),
        carbohydrates100:
            (offNutriments.carbohydrates_100g as Object?).asDoubleOrNull(),
        fat100: (offNutriments.fat_100g as Object?).asDoubleOrNull(),
        proteins100: (offNutriments.proteins_100g as Object?).asDoubleOrNull(),
        sugars100: (offNutriments.sugars_100g as Object?).asDoubleOrNull(),
        saturatedFat100:
            (offNutriments.saturated_fat_100g as Object?).asDoubleOrNull(),
        fiber100: (offNutriments.fiber_100g as Object?).asDoubleOrNull(),
        sodium100: (offNutriments.sodium_100g as Object?).asDoubleOrNull(),
        potassium100: (offNutriments.potassium_100g as Object?).asDoubleOrNull(),
        calcium100: (offNutriments.calcium_100g as Object?).asDoubleOrNull(),
        iron100: (offNutriments.iron_100g as Object?).asDoubleOrNull(),
        vitaminC100: (offNutriments.vitamin_c_100g as Object?).asDoubleOrNull(),
        vitaminD100: (offNutriments.vitamin_d_100g as Object?).asDoubleOrNull(),
        novaGroup: novaGroup is int ? novaGroup : int.tryParse(novaGroup?.toString() ?? ''),
    );
  }

  factory MealNutrimentsEntity.fromFDCNutriments(
      List<FDCFoodNutrimentDTO> fdcNutriment) {
    // FDC Food nutriments can have different values for Energy [Energy,
    // Energy (Atwater General Factors), Energy (Atwater Specific Factors)]
    final energyTotal = fdcNutriment
            .firstWhereOrNull(
                (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalKcalId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterGeneralId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterSpecificId)
            ?.amount;

    final carbsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalCarbsId)
        ?.amount;

    final fatTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalFatId)
        ?.amount;

    final proteinsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalProteinsId)
        ?.amount;

    final sugarTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalSugarId)
        ?.amount;

    final saturatedFatTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalSaturatedFatId)
        ?.amount;

    final fiberTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalDietaryFiberId)
        ?.amount;

    final sodiumTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalSodiumId)
        ?.amount;

    final potassiumTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalPotassiumId)
        ?.amount;

    final calciumTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalCalciumId)
        ?.amount;

    final ironTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalIronId)
        ?.amount;

    final vitaminCTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalVitaminCId)
        ?.amount;

    final vitaminDTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalVitaminDId)
        ?.amount;

    return MealNutrimentsEntity(
        energyKcal100: energyTotal,
        carbohydrates100: carbsTotal,
        fat100: fatTotal,
        proteins100: proteinsTotal,
        sugars100: sugarTotal,
        saturatedFat100: saturatedFatTotal,
        fiber100: fiberTotal,
        sodium100: sodiumTotal,
        potassium100: potassiumTotal,
        calcium100: calciumTotal,
        iron100: ironTotal,
        vitaminC100: vitaminCTotal,
        vitaminD100: vitaminDTotal,
        novaGroup: null, // FDC does not provide NOVA groups
    );
  }

  static double? _getValuePerUnit(double? valuePer100) {
    if (valuePer100 != null) {
      return valuePer100 / 100;
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        energyKcal100,
        carbohydrates100,
        fat100,
        proteins100,
        sugars100,
        saturatedFat100,
        fiber100,
        sodium100,
        potassium100,
        calcium100,
        iron100,
        vitaminC100,
        vitaminD100,
        novaGroup,
      ];
}
