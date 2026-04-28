import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';

void main() {
  group('DailyFocusEntity', () {
    test('falls back to upper body when storage value is missing', () {
      expect(
        DailyFocusEntityX.fromStorageValue(null),
        DailyFocusEntity.upperBody,
      );
      expect(
        DailyFocusEntityX.fromStorageValue('unexpected'),
        DailyFocusEntity.upperBody,
      );
    });

    test('returns focus specific macro adjustments', () {
      expect(DailyFocusEntity.lowerBody.adjustKcalGoal(2000), 2200);
      expect(DailyFocusEntity.lowerBody.adjustCarbGoal(250), 295);
      expect(DailyFocusEntity.lowerBody.adjustProteinGoal(180), 194);
      expect(DailyFocusEntity.lowerBody.adjustFatGoal(70), 66);

      expect(DailyFocusEntity.upperBody.adjustKcalGoal(2000), 2120);
      expect(DailyFocusEntity.upperBody.adjustCarbGoal(250), 275);
      expect(DailyFocusEntity.upperBody.adjustProteinGoal(180), 191);
      expect(DailyFocusEntity.upperBody.adjustFatGoal(70), 67);

      expect(DailyFocusEntity.rest.adjustKcalGoal(2000), 1880);
      expect(DailyFocusEntity.rest.adjustCarbGoal(250), 205);
      expect(DailyFocusEntity.rest.adjustProteinGoal(180), 198);
      expect(DailyFocusEntity.rest.adjustFatGoal(70), 74);

      expect(DailyFocusEntity.cardio.adjustKcalGoal(2000), 2040);
      expect(DailyFocusEntity.cardio.adjustCarbGoal(250), 263);
      expect(DailyFocusEntity.cardio.adjustProteinGoal(180), 185);
      expect(DailyFocusEntity.cardio.adjustFatGoal(70), 64);
    });
  });
}
