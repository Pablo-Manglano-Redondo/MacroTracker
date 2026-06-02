import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

void main() {
  group('NutritionPlanEntity', () {
    test('prefers exact date targets over weekday templates', () {
      final plan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'client-1',
        name: 'Cut week',
        objective: 'general_fitness',
        notes: null,
        startsOn: null,
        endsOn: null,
        days: const [
          NutritionPlanDayEntity(
            dateKey: null,
            weekday: DateTime.monday,
            kcalGoal: 2200,
            carbsGoal: 250,
            fatGoal: 70,
            proteinGoal: 160,
          ),
          NutritionPlanDayEntity(
            dateKey: '2026-06-01',
            weekday: null,
            kcalGoal: 1900,
            carbsGoal: 180,
            fatGoal: 55,
            proteinGoal: 170,
          ),
        ],
        meals: const [],
      );

      final target = plan.targetForDate(DateTime(2026, 6, 1));

      expect(target?.kcalGoal, 1900);
      expect(target?.proteinGoal, 170);
    });

    test('falls back to weekday target and then first target', () {
      final plan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'client-1',
        name: 'Week template',
        objective: 'general_fitness',
        notes: null,
        startsOn: null,
        endsOn: null,
        days: const [
          NutritionPlanDayEntity(
            dateKey: null,
            weekday: DateTime.tuesday,
            kcalGoal: 2300,
            carbsGoal: 260,
            fatGoal: 75,
            proteinGoal: 165,
          ),
        ],
        meals: const [],
      );

      expect(plan.targetForDate(DateTime(2026, 6, 2))?.kcalGoal, 2300);
      expect(plan.targetForDate(DateTime(2026, 6, 4))?.kcalGoal, 2300);
    });

    test('round-trips cached json including meals', () {
      final plan = NutritionPlanEntity.fromJson({
        'id': 'plan-1',
        'professional_id': 'pro-1',
        'client_id': 'client-1',
        'name': 'Performance week',
        'objective': 'general_fitness',
        'notes': 'Keep meals simple',
        'starts_on': '2026-06-01',
        'ends_on': '2026-06-07',
        'days': [
          {
            'weekday': 1,
            'kcal_goal': 2400,
            'carbs_goal': 280,
            'fat_goal': 80,
            'protein_goal': 175,
          }
        ],
        'meals': [
          {
            'id': 'meal-1',
            'slot': 'breakfast',
            'title': 'Yogurt bowl',
            'notes': 'Add berries',
            'kcal': 420,
            'carbs': 50,
            'fat': 12,
            'protein': 30,
          }
        ],
      });

      final cached = NutritionPlanEntity.fromJson(plan.toJson());

      expect(cached.id, 'plan-1');
      expect(cached.startsOn, DateTime(2026, 6, 1));
      expect(cached.days.single.carbsGoal, 280);
      expect(cached.meals.single.title, 'Yogurt bowl');
    });
  });

  group('ProfessionalConnectionEntity', () {
    test('round-trips active plan cache', () {
      final connection = ProfessionalConnectionEntity.fromJson({
        'relationship_id': 'rel-1',
        'professional_id': 'pro-1',
        'client_id': 'client-1',
        'professional_name': 'Coach Studio',
        'connected_at': '2026-06-01T10:00:00Z',
        'consent_accepted_at': '2026-06-01T10:00:01Z',
        'active_plan': {
          'id': 'plan-1',
          'professional_id': 'pro-1',
          'client_id': 'client-1',
          'name': 'Starter plan',
          'objective': 'general_fitness',
          'days': const [],
          'meals': const [],
        },
      });

      final cached = ProfessionalConnectionEntity.fromJson(connection.toJson());

      expect(cached.relationshipId, 'rel-1');
      expect(cached.professionalName, 'Coach Studio');
      expect(cached.activePlan?.name, 'Starter plan');
    });

    test('computes kcal adherence from absolute deviation', () {
      const summary = ProfessionalPlanSummaryEntity(
        professionalName: 'Coach',
        planName: 'Plan',
        kcalTarget: 2000,
        kcalActual: 1800,
        carbsTarget: 250,
        carbsActual: 220,
        fatTarget: 70,
        fatActual: 65,
        proteinTarget: 160,
        proteinActual: 150,
      );

      expect(summary.kcalDelta, -200);
      expect(summary.adherenceRatio, 0.9);
    });
  });
}
