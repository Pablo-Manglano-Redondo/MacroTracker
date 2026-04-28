import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';

class GetFrequentIntakePresetsUsecase {
  final GetIntakeUsecase _getIntakeUsecase;

  GetFrequentIntakePresetsUsecase(this._getIntakeUsecase);

  Future<List<FrequentIntakePresetEntity>> getTopPresets({
    int limit = 12,
    int lookbackDays = 45,
  }) async {
    final all = await _getIntakeUsecase.getAllIntakes();
    final cutoff = DateTime.now().subtract(Duration(days: lookbackDays));
    final candidates =
        all.where((intake) => intake.dateTime.isAfter(cutoff)).toList();

    final grouped = groupBy<IntakeEntity, String>(
      candidates,
      (intake) {
        final mealId = intake.meal.code ?? intake.meal.name ?? 'unknown';
        return '$mealId|${intake.type.name}|${intake.unit}|${intake.amount.toStringAsFixed(3)}';
      },
    );

    return grouped.entries
        .where((entry) => entry.value.length >= 2)
        .map((entry) {
          final sample = entry.value.first;
          return FrequentIntakePresetEntity(
            key: entry.key,
            title: sample.meal.name?.trim().isNotEmpty == true
                ? sample.meal.name!
                : 'Frequent meal',
            meal: sample.meal,
            intakeType: sample.type,
            unit: sample.unit,
            amount: sample.amount,
            uses: entry.value.length,
          );
        })
        .sorted((a, b) => b.uses.compareTo(a.uses))
        .take(limit)
        .toList();
  }
}
