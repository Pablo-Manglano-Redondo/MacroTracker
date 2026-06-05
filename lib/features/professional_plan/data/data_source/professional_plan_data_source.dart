import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalPlanDataSource {
  static const _activeConnectionKey = 'activeProfessionalConnection';
  static const debugInviteCode = 'DEBUG';

  final Box<dynamic> _box;
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;

  ProfessionalPlanDataSource(
    this._box,
    this._supabaseClient,
    this._identityService,
  );

  Future<ProfessionalConnectionEntity?> getActiveConnection() async {
    final value = _box.get(_activeConnectionKey);
    if (value is! Map) {
      return null;
    }
    return ProfessionalConnectionEntity.fromJson(
      Map<String, dynamic>.from(value),
    );
  }

  Future<void> saveActiveConnection(
      ProfessionalConnectionEntity connection) async {
    await _box.put(_activeConnectionKey, connection.toJson());
  }

  Future<void> clearActiveConnection() async {
    final connection = await getActiveConnection();
    await _box.delete(_activeConnectionKey);
    if (kDebugMode && connection?.relationshipId == 'debug-relationship') {
      return;
    }
    if (connection != null && connection.relationshipId.isNotEmpty) {
      await _identityService.ensureUserSession();
      await _supabaseClient
          .from('professional_clients')
          .update({
            'status': 'revoked',
            'revoked_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', connection.relationshipId)
          .eq('client_id', connection.clientId);
    }
  }

  Future<ProfessionalInvitePreviewEntity?> fetchInvitePreview(
      String inviteCode) async {
    final normalizedCode = _normalizeCode(inviteCode);
    if (kDebugMode && normalizedCode == debugInviteCode) {
      return _debugInvitePreview();
    }
    final response = await _supabaseClient.rpc(
      'preview_client_invite',
      params: {'p_invite_code': normalizedCode},
    );
    final row = response is List && response.isNotEmpty
        ? Map<String, dynamic>.from(response.first as Map)
        : response is Map
            ? Map<String, dynamic>.from(response)
            : null;
    if (row == null || row['status'] != 'pending') {
      return null;
    }
    return ProfessionalInvitePreviewEntity.fromJson(
      row,
    );
  }

  Future<ProfessionalConnectionEntity> acceptInvite(String inviteCode) async {
    final normalizedCode = _normalizeCode(inviteCode);
    if (kDebugMode && normalizedCode == debugInviteCode) {
      final connection = _debugConnection();
      await saveActiveConnection(connection);
      return connection;
    }
    await _identityService.ensureUserSession();
    final response = await _supabaseClient.rpc(
      'accept_client_invite',
      params: {'p_invite_code': normalizedCode},
    );
    final row = response is List && response.isNotEmpty
        ? Map<String, dynamic>.from(response.first as Map)
        : Map<String, dynamic>.from(response as Map);

    final plan = await fetchActivePlan(row['client_id']?.toString() ?? '');
    final now = DateTime.now();
    final connection = ProfessionalConnectionEntity(
      relationshipId: row['relationship_id']?.toString() ?? '',
      professionalId: row['professional_id']?.toString() ?? '',
      clientId: row['client_id']?.toString() ?? '',
      professionalName: row['professional_name']?.toString() ?? 'Professional',
      connectedAt:
          DateTime.tryParse(row['connected_at']?.toString() ?? '') ?? now,
      consentAcceptedAt:
          DateTime.tryParse(row['consent_accepted_at']?.toString() ?? '') ??
              now,
      activePlan: plan,
    );
    await saveActiveConnection(connection);
    return connection;
  }

  Future<NutritionPlanEntity?> fetchActivePlan(String clientId) async {
    if (kDebugMode && clientId == 'debug-client') {
      return _debugPlan();
    }
    if (clientId.isEmpty) {
      return null;
    }
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('nutrition_plans')
        .select(
            'id, professional_id, client_id, name, objective, notes, starts_on, ends_on, nutrition_plan_days(plan_date, weekday, kcal_goal, carbs_goal, fat_goal, protein_goal), nutrition_plan_meals(id, slot, title, notes, kcal, carbs, fat, protein)')
        .eq('client_id', clientId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    return NutritionPlanEntity.fromJson(Map<String, dynamic>.from(response));
  }

  Future<ProfessionalConnectionEntity?> refreshActivePlan() async {
    final connection = await getActiveConnection();
    if (connection == null) {
      return null;
    }
    final plan = await fetchActivePlan(connection.clientId);
    final refreshed = connection.copyWith(activePlan: plan);
    await saveActiveConnection(refreshed);
    return refreshed;
  }

  Future<void> uploadDailySnapshot({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required double kcalActual,
    required double kcalTarget,
    required double carbsActual,
    required double carbsTarget,
    required double fatActual,
    required double fatTarget,
    required double proteinActual,
    required double proteinTarget,
    required int mealsLogged,
  }) async {
    if (kDebugMode && connection.relationshipId == 'debug-relationship') {
      return;
    }
    await _identityService.ensureUserSession();
    await _supabaseClient.from('client_shared_snapshots').upsert({
      'professional_client_id': connection.relationshipId,
      'professional_id': connection.professionalId,
      'client_id': connection.clientId,
      'snapshot_date': _dateKey(day),
      'kcal_actual': kcalActual,
      'kcal_target': kcalTarget,
      'carbs_actual': carbsActual,
      'carbs_target': carbsTarget,
      'fat_actual': fatActual,
      'fat_target': fatTarget,
      'protein_actual': proteinActual,
      'protein_target': proteinTarget,
      'meals_logged': mealsLogged,
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'professional_client_id,snapshot_date');
  }

  String _normalizeCode(String inviteCode) =>
      inviteCode.trim().replaceAll(' ', '').toUpperCase();

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  ProfessionalInvitePreviewEntity _debugInvitePreview() {
    return ProfessionalInvitePreviewEntity(
      inviteId: 'debug-invite',
      code: debugInviteCode,
      professionalId: 'debug-professional',
      professionalName: 'Nutricionista Debug',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      isExpired: false,
    );
  }

  ProfessionalConnectionEntity _debugConnection() {
    final now = DateTime.now();
    return ProfessionalConnectionEntity(
      relationshipId: 'debug-relationship',
      professionalId: 'debug-professional',
      clientId: 'debug-client',
      professionalName: 'Nutricionista Debug',
      connectedAt: now,
      consentAcceptedAt: now,
      activePlan: _debugPlan(),
    );
  }

  NutritionPlanEntity _debugPlan() {
    final now = DateTime.now();
    return NutritionPlanEntity(
      id: 'debug-plan',
      professionalId: 'debug-professional',
      clientId: 'debug-client',
      name: 'Plan debug de recomposicion',
      objective: 'Validar la experiencia del nutricionista profesional.',
      notes: 'Plan local generado solo en modo debug.',
      startsOn: DateTime(now.year, now.month, now.day),
      endsOn: DateTime(now.year, now.month, now.day).add(
        const Duration(days: 14),
      ),
      days: const [
        NutritionPlanDayEntity(
          dateKey: null,
          weekday: null,
          kcalGoal: 2300,
          carbsGoal: 260,
          fatGoal: 70,
          proteinGoal: 170,
        ),
      ],
      meals: const [
        NutritionPlanMealEntity(
          id: 'debug-meal-1',
          slot: 'breakfast',
          title: 'Avena proteica',
          notes: 'Avena, yogur griego y fruta.',
          kcal: 520,
          carbs: 62,
          fat: 12,
          protein: 38,
        ),
        NutritionPlanMealEntity(
          id: 'debug-meal-2',
          slot: 'lunch',
          title: 'Bowl de arroz y pollo',
          notes: 'Arroz, pollo, verduras y aceite de oliva.',
          kcal: 760,
          carbs: 86,
          fat: 21,
          protein: 54,
        ),
        NutritionPlanMealEntity(
          id: 'debug-meal-3',
          slot: 'dinner',
          title: 'Cena alta en proteina',
          notes: 'Pescado, patata y ensalada.',
          kcal: 640,
          carbs: 58,
          fat: 18,
          protein: 52,
        ),
      ],
    );
  }
}
