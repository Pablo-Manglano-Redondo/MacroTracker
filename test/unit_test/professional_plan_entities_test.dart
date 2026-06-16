import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';

void main() {
  group('ProfessionalSyncStatusEntity Tests', () {
    test('props and fields', () {
      final now = DateTime.now();
      final entity = ProfessionalSyncStatusEntity(
        lastPlanSyncAt: now,
        lastSnapshotSyncAt: now,
        pendingSyncCount: 2,
        connectionStatus: 'active',
      );

      expect(entity.lastPlanSyncAt, now);
      expect(entity.lastSnapshotSyncAt, now);
      expect(entity.pendingSyncCount, 2);
      expect(entity.connectionStatus, 'active');
      expect(entity.hasPendingSyncs, isTrue);

      final other = ProfessionalSyncStatusEntity(
        lastPlanSyncAt: now,
        lastSnapshotSyncAt: now,
        pendingSyncCount: 2,
        connectionStatus: 'active',
      );
      expect(entity, equals(other));
    });
  });

  group('ProfessionalSharingScopeEntity Tests', () {
    test('props and fields', () {
      final now = DateTime.now();
      final entity = ProfessionalSharingScopeEntity(
        sharingMode: 'aggregate',
        messagesEnabled: true,
        consentAcceptedAt: now,
        sharedNow: const ['weight'],
        notSharedYet: const ['waist'],
        nextAvailable: const ['sleep'],
      );

      expect(entity.sharingMode, 'aggregate');
      expect(entity.messagesEnabled, isTrue);
      expect(entity.consentAcceptedAt, now);
      expect(entity.sharedNow, const ['weight']);
      expect(entity.notSharedYet, const ['waist']);
      expect(entity.nextAvailable, const ['sleep']);

      final other = ProfessionalSharingScopeEntity(
        sharingMode: 'aggregate',
        messagesEnabled: true,
        consentAcceptedAt: now,
        sharedNow: const ['weight'],
        notSharedYet: const ['waist'],
        nextAvailable: const ['sleep'],
      );
      expect(entity, equals(other));
    });
  });

  group('ProfessionalMessageEntity Tests', () {
    test('copyWith updates fields', () {
      final now = DateTime.now();
      final entity = ProfessionalMessageEntity(
        id: 'msg-1',
        authorRole: 'client',
        body: 'Hello',
        createdAt: now,
        isRead: false,
      );

      final updated = entity.copyWith(isRead: true);
      expect(updated.id, 'msg-1');
      expect(updated.body, 'Hello');
      expect(updated.isRead, isTrue);
      expect(entity.isRead, isFalse);

      final same = entity.copyWith();
      expect(same, equals(entity));
    });
  });

  group('ProfessionalMessageThreadEntity Tests', () {
    test('unreadCount counts correctly', () {
      final now = DateTime.now();
      final thread = ProfessionalMessageThreadEntity(
        threadId: 'thread-1',
        isSupported: true,
        messagesEnabled: true,
        messages: [
          ProfessionalMessageEntity(
            id: 'm1',
            authorRole: 'client',
            body: 'Hey',
            createdAt: now,
            isRead: true,
          ),
          ProfessionalMessageEntity(
            id: 'm2',
            authorRole: 'coach',
            body: 'Hello',
            createdAt: now,
            isRead: false,
          ),
        ],
      );

      expect(thread.unreadCount, 1);
      expect(thread.props, [
        'thread-1',
        true,
        true,
        thread.messages,
      ]);
    });
  });

  group('ProfessionalAdherenceSliceEntity Tests', () {
    test('kcalAdherence and adherenceFor calculations', () {
      const slice = ProfessionalAdherenceSliceEntity(
        kcalTarget: 2000,
        kcalActual: 1800,
        carbsTarget: 250,
        carbsActual: 220,
        fatTarget: 70,
        fatActual: 65,
        proteinTarget: 160,
        proteinActual: 150,
        mealsLogged: 4,
        trackedDays: 1,
      );

      expect(slice.kcalAdherence, closeTo(0.9, 0.001));

      // target <= 0 returns 0
      expect(slice.adherenceFor(0, 100), 0);

      // deviation clamps to [0, 1]
      expect(slice.adherenceFor(100, 300), 0.0); // deviation is 2.0 -> clamps 1 - 2 = -1 to 0
      expect(slice.adherenceFor(100, 50), 0.5); // deviation is 0.5 -> 1 - 0.5 = 0.5
    });
  });

  group('ProfessionalSectionSummaryEntity Tests', () {
    test('hasActivePlan logic', () {
      final conn = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );

      final summary = ProfessionalSectionSummaryEntity(
        connection: conn,
        activePlan: null,
        todayTarget: null,
        weekPlan: const [],
        today: const ProfessionalAdherenceSliceEntity(
          kcalTarget: 0,
          kcalActual: 0,
          carbsTarget: 0,
          carbsActual: 0,
          fatTarget: 0,
          fatActual: 0,
          proteinTarget: 0,
          proteinActual: 0,
          mealsLogged: 0,
          trackedDays: 0,
        ),
        week: const ProfessionalAdherenceSliceEntity(
          kcalTarget: 0,
          kcalActual: 0,
          carbsTarget: 0,
          carbsActual: 0,
          fatTarget: 0,
          fatActual: 0,
          proteinTarget: 0,
          proteinActual: 0,
          mealsLogged: 0,
          trackedDays: 0,
        ),
        syncStatus: ProfessionalSyncStatusEntity(
          lastPlanSyncAt: null,
          lastSnapshotSyncAt: null,
          pendingSyncCount: 0,
          connectionStatus: 'active',
        ),
        weekTrackedDays: const [],
      );

      expect(summary.hasActivePlan, isFalse);
      expect(summary.weekTrackedDays, isEmpty);
    });
  });

  group('NutritionPlanEntity and related sub-entities Tests', () {
    final day1 = const NutritionPlanDayEntity(
      dateKey: '2026-06-16',
      weekday: null,
      kcalGoal: 2000,
      carbsGoal: 250,
      fatGoal: 65,
      proteinGoal: 120,
    );
    final day2 = const NutritionPlanDayEntity(
      dateKey: null,
      weekday: 2, // Tuesday
      kcalGoal: 1800,
      carbsGoal: 220,
      fatGoal: 60,
      proteinGoal: 110,
    );

    final meal1 = const NutritionPlanMealEntity(
      id: 'meal-1',
      slot: 'breakfast',
      title: 'Oats',
      notes: 'Add fruits',
      kcal: 400,
      carbs: 60,
      fat: 10,
      protein: 15,
      recipeId: 'rec-1',
    );

    final plan = NutritionPlanEntity(
      id: 'plan-1',
      professionalId: 'pro-1',
      clientId: 'cli-1',
      name: 'Cutting Phase',
      objective: 'Fat loss',
      notes: 'Stay hydrated',
      createdAt: DateTime.utc(2026, 6, 15),
      updatedAt: DateTime.utc(2026, 6, 16),
      startsOn: DateTime.utc(2026, 6, 16),
      endsOn: DateTime.utc(2026, 7, 16),
      days: [day1, day2],
      meals: [meal1],
    );

    test('targetForDate returns correct day targets', () {
      // Exact date match
      final match1 = plan.targetForDate(DateTime(2026, 6, 16));
      expect(match1?.kcalGoal, 2000);

      // Weekday match fallback (2026-06-23 is also Tuesday)
      final match2 = plan.targetForDate(DateTime(2026, 6, 23));
      expect(match2?.kcalGoal, 1800);

      // First day fallback (2026-06-17 is Wednesday, no exact/weekday match)
      final match3 = plan.targetForDate(DateTime(2026, 6, 17));
      expect(match3?.kcalGoal, 2000);
    });

    test('weekView generates correct resolved days', () {
      final week = plan.weekView(anchorDate: DateTime(2026, 6, 16)); // Tuesday
      expect(week, hasLength(7));
      expect(week[0].effectiveDate.weekday, DateTime.monday); // 2026-06-15
      expect(week[1].effectiveDate.weekday, DateTime.tuesday); // 2026-06-16

      // Tuesday has exact date match
      expect(week[1].usesWeekdayFallback, isFalse);
      expect(week[1].target?.kcalGoal, 2000);

      // Next Monday (no matches) will fallback to first day
      final nextWeek = plan.weekView(anchorDate: DateTime(2026, 6, 22));
      expect(nextWeek[0].usesWeekdayFallback, isFalse);
      expect(nextWeek[0].target?.kcalGoal, 2000);
    });

    test('cacheSignature formats correctly', () {
      expect(plan.cacheSignature, 'plan-1|2026-06-16T00:00:00.000Z');

      final nullDatesPlan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'pro-1',
        clientId: 'cli-1',
        name: 'N',
        objective: 'O',
        notes: null,
        createdAt: null,
        updatedAt: null,
        startsOn: null,
        endsOn: null,
        days: const [],
        meals: const [],
      );
      expect(nullDatesPlan.cacheSignature, 'plan-1|||0|0');
    });

    test('toJson and fromJson roundtrip for NutritionPlanEntity', () {
      final json = plan.toJson();
      final parsed = NutritionPlanEntity.fromJson(json);

      expect(parsed.id, plan.id);
      expect(parsed.name, plan.name);
      expect(parsed.days, hasLength(2));
      expect(parsed.meals, hasLength(1));
      expect(parsed.meals.first.recipeId, 'rec-1');
    });

    test('NutritionPlanDayEntity types conversion and defaults', () {
      final raw = {
        'plan_date': '2026-06-16',
        'weekday': '2',
        'kcal_goal': '1800.5',
        'carbs_goal': 220,
        'fat_goal': 60.0,
        'protein_goal': '110',
      };
      final parsed = NutritionPlanDayEntity.fromJson(raw);
      expect(parsed.weekday, 2);
      expect(parsed.kcalGoal, 1800.5);
      expect(parsed.carbsGoal, 220.0);
      expect(parsed.proteinGoal, 110.0);
    });

    test('NutritionPlanResolvedDayEntity empty constructor', () {
      final date = DateTime(2026, 6, 16);
      final empty = NutritionPlanResolvedDayEntity.empty(date);
      expect(empty.effectiveDate, date);
      expect(empty.target, isNull);
      expect(empty.usesWeekdayFallback, isFalse);
    });

    test('NutritionPlanMealEntity null types conversion', () {
      final raw = {
        'id': 'm1',
        'slot': 'breakfast',
        'title': 'Oats',
        'kcal': null,
        'carbs': '50',
      };
      final parsed = NutritionPlanMealEntity.fromJson(raw);
      expect(parsed.kcal, isNull);
      expect(parsed.carbs, 50.0);
    });
  });

  group('ProfessionalInvitePreviewEntity Tests', () {
    test('fromJson parses expired and active invites correctly', () {
      final activeJson = {
        'id': 'inv-1',
        'invite_code': 'ABC123',
        'expires_at': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'professionals': {
          'id': 'pro-1',
          'display_name': 'Dr. John',
          'business_name': 'John Nutrition',
        }
      };

      final invite = ProfessionalInvitePreviewEntity.fromJson(activeJson);
      expect(invite.inviteId, 'inv-1');
      expect(invite.code, 'ABC123');
      expect(invite.professionalName, 'John Nutrition');
      expect(invite.isExpired, isFalse);

      final expiredJson = {
        'id': 'inv-2',
        'invite_code': 'EXP999',
        'expires_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'professionals': {
          'id': 'pro-1',
          'display_name': 'Dr. Expired',
          'business_name': '',
        }
      };
      final expiredInvite = ProfessionalInvitePreviewEntity.fromJson(expiredJson);
      expect(expiredInvite.professionalName, 'Dr. Expired');
      expect(expiredInvite.isExpired, isTrue);
    });
  });

  group('ProfessionalPlanSummaryEntity Tests', () {
    test('adherenceRatio and kcalDelta calculation', () {
      const summary = ProfessionalPlanSummaryEntity(
        professionalName: 'P',
        planName: 'Plan',
        kcalTarget: 2000,
        kcalActual: 1800,
        carbsTarget: 200,
        carbsActual: 180,
        fatTarget: 60,
        fatActual: 55,
        proteinTarget: 140,
        proteinActual: 130,
      );

      expect(summary.adherenceRatio, closeTo(0.9, 0.001));
      expect(summary.kcalDelta, -200.0);

      const invalidTargetSummary = ProfessionalPlanSummaryEntity(
        professionalName: 'P',
        planName: 'Plan',
        kcalTarget: 0,
        kcalActual: 1800,
        carbsTarget: 0,
        carbsActual: 0,
        fatTarget: 0,
        fatActual: 0,
        proteinTarget: 0,
        proteinActual: 0,
      );
      expect(invalidTargetSummary.adherenceRatio, 0.0);
    });
  });
}
