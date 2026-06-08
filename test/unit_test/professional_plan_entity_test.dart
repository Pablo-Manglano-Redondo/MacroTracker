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
        createdAt: null,
        updatedAt: null,
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

    test('builds a consumable weekly view with weekday fallback', () {
      final plan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'client-1',
        name: 'Week template',
        objective: 'general_fitness',
        notes: null,
        createdAt: null,
        updatedAt: null,
        startsOn: null,
        endsOn: null,
        days: const [
          NutritionPlanDayEntity(
            dateKey: null,
            weekday: DateTime.monday,
            kcalGoal: 2100,
            carbsGoal: 240,
            fatGoal: 65,
            proteinGoal: 155,
          ),
        ],
        meals: const [],
      );

      final week = plan.weekView(anchorDate: DateTime(2026, 6, 3));

      expect(week, hasLength(7));
      expect(week.first.target?.kcalGoal, 2100);
      expect(week.first.usesWeekdayFallback, true);
    });

    test('falls back to weekday target and then first target', () {
      final plan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'client-1',
        name: 'Week template',
        objective: 'general_fitness',
        notes: null,
        createdAt: null,
        updatedAt: null,
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
        'created_at': '2026-05-31T08:00:00Z',
        'updated_at': '2026-06-01T09:30:00Z',
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
      expect(cached.updatedAt, DateTime.parse('2026-06-01T09:30:00Z'));
      expect(cached.days.single.carbsGoal, 280);
      expect(cached.meals.single.title, 'Yogurt bowl');
    });

    test('builds stable cache signature from plan metadata', () {
      final versionedPlan = NutritionPlanEntity.fromJson({
        'id': 'plan-1',
        'professional_id': 'pro-1',
        'client_id': 'client-1',
        'name': 'Performance week',
        'objective': 'general_fitness',
        'created_at': '2026-05-31T08:00:00Z',
        'updated_at': '2026-06-01T09:30:00Z',
        'days': const [],
        'meals': const [],
      });
      const fallbackPlan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'client-1',
        name: 'Performance week',
        objective: 'general_fitness',
        notes: null,
        createdAt: null,
        updatedAt: null,
        startsOn: null,
        endsOn: null,
        days: [],
        meals: [],
      );

      expect(
        versionedPlan.cacheSignature,
        'plan-1|2026-06-01T09:30:00.000Z',
      );
      expect(fallbackPlan.cacheSignature, 'plan-1|||0|0');
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
        'last_plan_sync_at': '2026-06-01T10:05:00Z',
        'last_snapshot_sync_at': '2026-06-01T10:06:00Z',
        'pending_sync_count': 2,
        'sharing_mode': 'aggregate',
        'messages_enabled': false,
        'connection_status': 'active',
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
      expect(cached.pendingSyncCount, 2);
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
