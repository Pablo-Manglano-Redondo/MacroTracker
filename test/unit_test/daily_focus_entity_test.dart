import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';

void main() {
  group('DailyFocusEntity', () {
    test('falls back to training when storage value is missing', () {
      expect(
        DailyFocusEntityX.fromStorageValue(null),
        DailyFocusEntity.training,
      );
      expect(
        DailyFocusEntityX.fromStorageValue('unexpected'),
        DailyFocusEntity.training,
      );
    });

    test('returns focus specific macro adjustments', () {
      expect(DailyFocusEntity.training.adjustKcalGoal(2000), 2160);
      expect(DailyFocusEntity.training.adjustCarbGoal(250), 285);
      expect(DailyFocusEntity.training.adjustProteinGoal(180), 194);
      expect(DailyFocusEntity.training.adjustFatGoal(70), 67);

      expect(DailyFocusEntity.rest.adjustKcalGoal(2000), 1880);
      expect(DailyFocusEntity.rest.adjustCarbGoal(250), 205);
      expect(DailyFocusEntity.rest.adjustProteinGoal(180), 198);
      expect(DailyFocusEntity.rest.adjustFatGoal(70), 74);

      expect(DailyFocusEntity.cardio.adjustKcalGoal(2000), 2060);
      expect(DailyFocusEntity.cardio.adjustCarbGoal(250), 270);
      expect(DailyFocusEntity.cardio.adjustProteinGoal(180), 189);
      expect(DailyFocusEntity.cardio.adjustFatGoal(70), 64);
    });
  });
}
