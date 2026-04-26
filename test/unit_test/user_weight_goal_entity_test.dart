import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

void main() {
  group('UserWeightGoalEntity gym phase helpers', () {
    test('maps labels to cut maintain and bulk', () {
      expect(UserWeightGoalEntity.loseWeight.gymPhaseLabel, 'Cut');
      expect(UserWeightGoalEntity.maintainWeight.gymPhaseLabel, 'Maintain');
      expect(UserWeightGoalEntity.gainWeight.gymPhaseLabel, 'Bulk');
    });

    test('adjusts macros for each phase', () {
      expect(UserWeightGoalEntity.loseWeight.adjustCarbGoal(250), 225);
      expect(UserWeightGoalEntity.loseWeight.adjustFatGoal(70), 64);
      expect(UserWeightGoalEntity.loseWeight.adjustProteinGoal(180), 216);

      expect(UserWeightGoalEntity.maintainWeight.adjustCarbGoal(250), 250);
      expect(UserWeightGoalEntity.maintainWeight.adjustFatGoal(70), 70);
      expect(UserWeightGoalEntity.maintainWeight.adjustProteinGoal(180), 191);

      expect(UserWeightGoalEntity.gainWeight.adjustCarbGoal(250), 270);
      expect(UserWeightGoalEntity.gainWeight.adjustFatGoal(70), 73);
      expect(UserWeightGoalEntity.gainWeight.adjustProteinGoal(180), 198);
    });
  });
}
