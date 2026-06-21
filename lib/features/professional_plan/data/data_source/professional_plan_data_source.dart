import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/data/dbo/pending_snapshot_sync_dbo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalPlanDataSource {
  static const _activeConnectionKey = 'activeProfessionalConnection';
  static const _lastSeenPlanSignatureKey = 'professionalLastSeenPlanSignature';
  static const _lastSeenMessagesCountKey = 'professionalLastSeenMessagesCount';
  static const _messageTable = 'professional_client_messages';
  static const debugInviteCode = 'DEBUG';

  final Box<dynamic> _box;
  final Box<PendingSnapshotSyncDBO> _syncQueueBox;
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;

  ProfessionalPlanDataSource(
    this._box,
    this._syncQueueBox,
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
    await _box.delete(_lastSeenPlanSignatureKey);
    await _box.delete(_lastSeenMessagesCountKey);

    // Clear any pending syncs for this connection in the queue
    if (connection != null) {
      final keysToRemove = _syncQueueBox.keys.where((key) {
        final item = _syncQueueBox.get(key);
        return item?.relationshipId == connection.relationshipId;
      }).toList();
      for (final key in keysToRemove) {
        await _syncQueueBox.delete(key);
      }
    }

    if (kDebugMode && connection?.relationshipId == 'debug-relationship') {
      return;
    }
    if (connection != null && connection.relationshipId.isNotEmpty) {
      await _identityService.ensureUserSession();
      try {
        await _supabaseClient
            .from('professional_clients')
            .update({
              'status': 'revoked',
              'revoked_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', connection.relationshipId)
            .eq('client_id', connection.clientId);
      } catch (_) {}
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
      lastPlanSyncAt: now,
      lastSnapshotSyncAt: null,
      pendingSyncCount: _syncQueueBox.length,
      sharingMode: row['sharing_mode']?.toString() ?? 'aggregate',
      messagesEnabled: true,
      connectionStatus: row['connection_status']?.toString() ??
          row['status']?.toString() ??
          'active',
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
            'id, professional_id, client_id, name, objective, notes, created_at, updated_at, starts_on, ends_on, nutrition_plan_days(plan_date, weekday, kcal_goal, carbs_goal, fat_goal, protein_goal), nutrition_plan_meals(id, slot, title, notes, kcal, carbs, fat, protein, recipe_id)')
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
    final refreshedConnection = await _refreshRemoteConnection(connection);
    if (refreshedConnection == null) {
      await clearActiveConnection();
      return null;
    }
    final plan = await fetchActivePlan(connection.clientId);
    final refreshed = refreshedConnection.copyWith(
      activePlan: plan,
      lastPlanSyncAt: DateTime.now(),
      pendingSyncCount: _syncQueueBox.length,
    );
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
    String? notes,
    double? weightKg,
    double? waistCm,
  }) async {
    if (kDebugMode && connection.relationshipId == 'debug-relationship') {
      await saveDailyNote(day, notes ?? '');
      return;
    }
    try {
      await saveDailyNote(day, notes ?? '');
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
        'notes': notes,
        'weight_kg': weightKg,
        'waist_cm': waistCm,
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'professional_client_id,snapshot_date');
      await _updateSyncStatus(
        relationshipId: connection.relationshipId,
        lastSnapshotSyncAt: DateTime.now(),
      );
    } catch (error) {
      final pendingId = '${connection.relationshipId}_${_dateKey(day)}';
      await _syncQueueBox.put(
        pendingId,
        PendingSnapshotSyncDBO(
          id: pendingId,
          relationshipId: connection.relationshipId,
          professionalId: connection.professionalId,
          clientId: connection.clientId,
          day: day,
          kcalActual: kcalActual,
          kcalTarget: kcalTarget,
          carbsActual: carbsActual,
          carbsTarget: carbsTarget,
          fatActual: fatActual,
          fatTarget: fatTarget,
          proteinActual: proteinActual,
          proteinTarget: proteinTarget,
          mealsLogged: mealsLogged,
          createdAt: DateTime.now(),
          notes: notes,
          weightKg: weightKg,
          waistCm: waistCm,
        ),
      );
      await _updateSyncStatus(
        relationshipId: connection.relationshipId,
        pendingSyncCount: _syncQueueBox.length,
      );
      rethrow;
    }
  }

  Future<void> uploadDiaryEntries({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required List<Map<String, dynamic>> entries,
  }) async {
    if (connection.sharingMode != 'detailed') return;
    if (entries.isEmpty) return;
    if (kDebugMode && connection.relationshipId == 'debug-relationship') return;

    try {
      await _identityService.ensureUserSession();
      // Delete existing entries for this day to avoid duplicates
      await _supabaseClient
          .from('client_diary_entries')
          .delete()
          .eq('professional_client_id', connection.relationshipId)
          .eq('entry_date', _dateKey(day));
      // Insert fresh entries
      final rows = entries
          .map((e) => {
                'professional_client_id': connection.relationshipId,
                'professional_id': connection.professionalId,
                'client_id': connection.clientId,
                'entry_date': _dateKey(day),
                ...e,
              })
          .toList();
      await _supabaseClient.from('client_diary_entries').insert(rows);
    } catch (_) {
      // Non-blocking; diary upload must never break the main sync
    }
  }

  Future<void> processPendingSyncs() async {
    if (_syncQueueBox.isEmpty) {
      return;
    }
    final keys = List<dynamic>.from(_syncQueueBox.keys);
    final activeConnection = await getActiveConnection();
    
    for (final key in keys) {
      final pending = _syncQueueBox.get(key);
      if (pending == null) continue;

      // Discard pending syncs if the relationship is no longer active
      if (activeConnection == null ||
          activeConnection.relationshipId != pending.relationshipId) {
        await _syncQueueBox.delete(key);
        continue;
      }

      try {
        await _identityService.ensureUserSession();
        await _supabaseClient.from('client_shared_snapshots').upsert({
          'professional_client_id': pending.relationshipId,
          'professional_id': pending.professionalId,
          'client_id': pending.clientId,
          'snapshot_date': _dateKey(pending.day),
          'kcal_actual': pending.kcalActual,
          'kcal_target': pending.kcalTarget,
          'carbs_actual': pending.carbsActual,
          'carbs_target': pending.carbsTarget,
          'fat_actual': pending.fatActual,
          'fat_target': pending.fatTarget,
          'protein_actual': pending.proteinActual,
          'protein_target': pending.proteinTarget,
          'meals_logged': pending.mealsLogged,
          'notes': pending.notes,
          'weight_kg': pending.weightKg,
          'waist_cm': pending.waistCm,
          'synced_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'professional_client_id,snapshot_date');

        await _syncQueueBox.delete(key);
        await _updateSyncStatus(
          relationshipId: pending.relationshipId,
          lastSnapshotSyncAt: DateTime.now(),
          pendingSyncCount: _syncQueueBox.length,
        );
      } catch (error) {
        if (_shouldRetryPendingSync(error)) {
          break;
        }
      }
    }
  }

  Future<void> saveDailyNote(DateTime day, String note) async {
    await _box.put('professional_daily_note_${_dateKey(day)}', note);
  }

  Future<String?> getDailyNote(DateTime day) async {
    final note = _box.get('professional_daily_note_${_dateKey(day)}');
    return note as String?;
  }

  Future<int> getPendingSyncCount() async => _syncQueueBox.length;

  Future<int> getUnseenSectionCount() async {
    final connection = await getActiveConnection();
    if (connection == null) {
      return 0;
    }

    var unseenCount = 0;
    final currentPlanSignature = _planSignature(connection.activePlan);
    final lastSeenPlanSignature =
        _box.get(_lastSeenPlanSignatureKey) as String?;
    if (currentPlanSignature != null &&
        currentPlanSignature != lastSeenPlanSignature) {
      unseenCount += 1;
    }

    final messages = await getMessages(connection: connection);
    final seenMessagesCount = _readInt(_box.get(_lastSeenMessagesCountKey));
    if (messages.unreadCount > seenMessagesCount) {
      unseenCount += messages.unreadCount - seenMessagesCount;
    }
    return unseenCount;
  }

  Future<void> markSectionSeen({
    required ProfessionalConnectionEntity connection,
  }) async {
    await _box.put(
      _lastSeenPlanSignatureKey,
      _planSignature(connection.activePlan),
    );
    final messages = await getMessages(connection: connection);
    await _box.put(_lastSeenMessagesCountKey, messages.unreadCount);
  }

  Future<ProfessionalMessageThreadEntity> getMessages({
    required ProfessionalConnectionEntity connection,
  }) async {
    if (connection.relationshipId.isEmpty) {
      return ProfessionalMessageThreadEntity(
        threadId: connection.relationshipId,
        isSupported: false,
        messagesEnabled: true,
        messages: const [],
      );
    }
    if (kDebugMode && connection.relationshipId == 'debug-relationship') {
      final debugMessages = [
        ProfessionalMessageEntity(
          id: 'debug-message-1',
          authorRole: 'professional',
          body: 'Plan actualizado. Revisa la vista semanal.',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          isRead: true,
        ),
        ProfessionalMessageEntity(
          id: 'debug-message-2',
          authorRole: 'professional',
          body: 'Hoy prioriza adherencia y deja la cena simple.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
      ];

      // Apply local read overrides even in debug mode so UI behaves the same
      // as in production when a user marks a debug message as read.
      final localReadKey = _localReadKey(connection.relationshipId);
      final localReadList = _box.get(localReadKey) as List<dynamic>?;
      final localReadIds = <String>{
        if (localReadList != null) ...localReadList.map((e) => e.toString())
      };

      final applied = debugMessages
          .map(
              (m) => localReadIds.contains(m.id) ? m.copyWith(isRead: true) : m)
          .toList();

      return ProfessionalMessageThreadEntity(
        threadId: connection.relationshipId,
        isSupported: true,
        messagesEnabled: true,
        messages: applied,
      );
    }

    try {
      await _identityService.ensureUserSession();
    } catch (_) {
      return ProfessionalMessageThreadEntity(
        threadId: connection.relationshipId,
        isSupported: false,
        messagesEnabled: true,
        messages: const [],
      );
    }

    final rows = await _tryFetchMessagesRows(
      relationshipId: connection.relationshipId,
    );
    if (rows == null) {
      return ProfessionalMessageThreadEntity(
        threadId: connection.relationshipId,
        isSupported: false,
        messagesEnabled: true,
        messages: const [],
      );
    }
    final rawMessages = rows
        .map(parseMessageRow)
        .whereType<ProfessionalMessageEntity>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply locally persisted read flags so reads survive reloads even if
    // the server update failed or is delayed.
    final localReadKey = _localReadKey(connection.relationshipId);
    final localReadList = _box.get(localReadKey) as List<dynamic>?;
    final localReadIds = <String>{
      if (localReadList != null) ...localReadList.map((e) => e.toString())
    };

    final messages = rawMessages
        .map((m) => localReadIds.contains(m.id) ? m.copyWith(isRead: true) : m)
        .toList();

    return ProfessionalMessageThreadEntity(
      threadId: connection.relationshipId,
      isSupported: true,
      messagesEnabled: true,
      messages: messages,
    );
  }

  Future<void> markMessageRead({
    required ProfessionalConnectionEntity connection,
    required String messageId,
  }) async {
    if (connection.relationshipId.isEmpty || messageId.isEmpty) {
      return;
    }
    if (kDebugMode &&
        (connection.relationshipId == 'debug-relationship' ||
            messageId.startsWith('debug-'))) {
      // In debug mode we do not call the backend, but we should still
      // persist the read state locally so reads survive reloads.
      try {
        final key = _localReadKey(connection.relationshipId);
        final current = _box.get(key) as List<dynamic>? ?? <dynamic>[];
        if (!current.map((e) => e.toString()).contains(messageId)) {
          current.add(messageId);
          await _box.put(key, current);
        }
      } catch (_) {}
      return;
    }
    try {
      await _identityService.ensureUserSession();
    } catch (_) {
      return;
    }

    await _tryMarkMessageRead(
      relationshipId: connection.relationshipId,
      messageId: messageId,
      clientReadAt: DateTime.now().toUtc().toIso8601String(),
    );
    // Persist locally as a fallback so the UI reflects the read state after
    // a reload even if the backend update didn't persist or is delayed.
    try {
      final key = _localReadKey(connection.relationshipId);
      final current = _box.get(key) as List<dynamic>? ?? <dynamic>[];
      if (!current.map((e) => e.toString()).contains(messageId)) {
        current.add(messageId);
        await _box.put(key, current);
      }
    } catch (_) {
      // Do not fail the whole flow if local persistence fails.
    }
  }

  String _localReadKey(String relationshipId) =>
      'professional_client_message_reads_$relationshipId';

  Future<ProfessionalMessageEntity> sendMessage({
    required ProfessionalConnectionEntity connection,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (connection.relationshipId.isEmpty || trimmedBody.isEmpty) {
      throw ArgumentError('Message body cannot be empty.');
    }
    if (kDebugMode && connection.relationshipId == 'debug-relationship') {
      return ProfessionalMessageEntity(
        id: 'debug-client-${DateTime.now().millisecondsSinceEpoch}',
        authorRole: 'client',
        body: trimmedBody,
        createdAt: DateTime.now(),
        isRead: true,
      );
    }
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from(_messageTable)
        .insert({
          'professional_client_id': connection.relationshipId,
          'professional_id': connection.professionalId,
          'client_id': connection.clientId,
          'author_role': 'client',
          'body': trimmedBody,
        })
        .select('id, author_role, body, created_at, client_read_at')
        .single();
    final parsed = parseMessageRow(Map<String, dynamic>.from(response));
    if (parsed == null) {
      throw StateError('Could not parse inserted professional message.');
    }
    return parsed;
  }

  Future<ProfessionalSharingScopeEntity> getSharingScope({
    required ProfessionalConnectionEntity connection,
  }) async {
    final isDetailed = connection.sharingMode == 'detailed';
    const isMessagesEnabled = true;

    return ProfessionalSharingScopeEntity(
      sharingMode: connection.sharingMode,
      messagesEnabled: isMessagesEnabled,
      consentAcceptedAt: connection.consentAcceptedAt,
      sharedNow: [
        'aggregate_targets_vs_actuals',
        'aggregate_tracked_days_and_meals',
        'aggregate_daily_adherence',
        if (isDetailed) ...[
          'per_meal_detail',
          'raw_diary_entries',
        ],
        'realtime_bidirectional_messages',
      ],
      notSharedYet: [
        if (!isDetailed) ...[
          'raw_diary_entries',
          'per_meal_detail',
        ],
      ],
      nextAvailable: const [],
    );
  }

  Future<void> updateSharingMode({
    required String relationshipId,
    required String clientId,
    required String sharingMode,
  }) async {
    final connection = await getActiveConnection();
    if (connection != null && connection.relationshipId == relationshipId) {
      final updated = connection.copyWith(sharingMode: sharingMode);
      await saveActiveConnection(updated);
    }
    if (kDebugMode && relationshipId == 'debug-relationship') {
      return;
    }
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('professional_clients')
        .update({
          'sharing_mode': sharingMode,
        })
        .eq('id', relationshipId)
        .eq('client_id', clientId)
        .select('id, sharing_mode')
        .maybeSingle();

    if (response == null) {
      throw StateError(
        'Sharing mode update did not return a relationship row. The relationship may be missing or blocked by permissions.',
      );
    }

    final confirmedMode = response['sharing_mode']?.toString();
    if (confirmedMode != sharingMode) {
      throw StateError(
        'Sharing mode update was not persisted. Expected "$sharingMode" but received "$confirmedMode".',
      );
    }
  }

  Future<ProfessionalConnectionEntity?> _refreshRemoteConnection(
    ProfessionalConnectionEntity connection,
  ) async {
    if (kDebugMode && connection.relationshipId == 'debug-relationship') {
      return connection;
    }

    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('professional_clients')
        .select(
          'id, professional_id, client_id, status, connected_at, consent_accepted_at, sharing_mode, messages_enabled, professionals(display_name, business_name)',
        )
        .eq('id', connection.relationshipId)
        .eq('client_id', connection.clientId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final row = Map<String, dynamic>.from(response);
    final professionalRaw = row['professionals'];
    final professionalMap = professionalRaw is Map
        ? Map<String, dynamic>.from(professionalRaw)
        : professionalRaw is List && professionalRaw.isNotEmpty
            ? Map<String, dynamic>.from(professionalRaw.first as Map)
            : const <String, dynamic>{};

    final businessName = professionalMap['business_name']?.toString();
    final displayName = professionalMap['display_name']?.toString();

    return ProfessionalConnectionEntity(
      relationshipId: row['id']?.toString() ?? connection.relationshipId,
      professionalId:
          row['professional_id']?.toString() ?? connection.professionalId,
      clientId: row['client_id']?.toString() ?? connection.clientId,
      professionalName: businessName?.isNotEmpty == true
          ? businessName!
          : (displayName?.isNotEmpty == true
              ? displayName!
              : connection.professionalName),
      connectedAt:
          DateTime.tryParse(row['connected_at']?.toString() ?? '') ??
              connection.connectedAt,
      consentAcceptedAt:
          DateTime.tryParse(row['consent_accepted_at']?.toString() ?? '') ??
              connection.consentAcceptedAt,
      lastPlanSyncAt: connection.lastPlanSyncAt,
      lastSnapshotSyncAt: connection.lastSnapshotSyncAt,
      pendingSyncCount: connection.pendingSyncCount,
      sharingMode: row['sharing_mode']?.toString() ?? connection.sharingMode,
      messagesEnabled:
          row['messages_enabled'] as bool? ?? connection.messagesEnabled,
      connectionStatus: row['status']?.toString() ?? connection.connectionStatus,
      activePlan: connection.activePlan,
    );
  }

  bool _shouldRetryPendingSync(Object error) {
    final errorStr = error.toString().toLowerCase();
    final isNetwork = errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout');
    final isAuth = errorStr.contains('jwt') ||
        errorStr.contains('auth') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('forbidden') ||
        errorStr.contains('session') ||
        errorStr.contains('token') ||
        errorStr.contains('sign in') ||
        errorStr.contains('sign-in') ||
        errorStr.contains('refresh');
    return isNetwork || isAuth;
  }

  String _normalizeCode(String inviteCode) =>
      inviteCode.trim().replaceAll(' ', '').toUpperCase();

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<List<Map<String, dynamic>>?> _tryFetchMessagesRows({
    required String relationshipId,
  }) async {
    try {
      final response = await _supabaseClient
          .from(_messageTable)
          .select(
            'id, author_role, body, created_at, client_read_at',
          )
          .eq('professional_client_id', relationshipId)
          .order('created_at', ascending: false);
      return response
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    } catch (error) {
      if (isIgnorableMessagesBackendError(error)) {
        return null;
      }
      return null;
    }
  }

  Future<void> _tryMarkMessageRead({
    required String relationshipId,
    required String messageId,
    required String clientReadAt,
  }) async {
    try {
      await _supabaseClient
          .from(_messageTable)
          .update({'client_read_at': clientReadAt})
          .eq('id', messageId)
          .eq('professional_client_id', relationshipId);
    } catch (error, stack) {
      debugPrint('ERROR in _tryMarkMessageRead: $error');
      debugPrint(stack.toString());
      if (isIgnorableMessagesBackendError(error)) {
        return;
      }
    }
  }

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
      lastPlanSyncAt: now,
      lastSnapshotSyncAt: now.subtract(const Duration(minutes: 12)),
      pendingSyncCount: 0,
      sharingMode: 'aggregate',
      messagesEnabled: true,
      connectionStatus: 'active',
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
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 3)),
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

  Future<void> _updateSyncStatus({
    required String relationshipId,
    DateTime? lastSnapshotSyncAt,
    int? pendingSyncCount,
  }) async {
    final connection = await getActiveConnection();
    if (connection == null || connection.relationshipId != relationshipId) {
      return;
    }
    await saveActiveConnection(
      connection.copyWith(
        lastSnapshotSyncAt: lastSnapshotSyncAt ?? connection.lastSnapshotSyncAt,
        pendingSyncCount: pendingSyncCount ?? _syncQueueBox.length,
      ),
    );
  }

  String? _planSignature(NutritionPlanEntity? plan) {
    if (plan == null) {
      return null;
    }
    return plan.cacheSignature;
  }

  @visibleForTesting
  static ProfessionalMessageEntity? parseMessageRow(Map<String, dynamic> row) {
    final id = _firstString(row, const ['id']);
    final body = _firstString(row, const ['body']);
    if (id == null || id.isEmpty || body == null || body.trim().isEmpty) {
      return null;
    }
    final authorRole =
        _firstString(row, const ['author_role']) ?? 'professional';
    final createdAt = DateTime.tryParse(
          _firstString(row, const ['created_at']) ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final isRead =
        row['client_read_at'] != null || authorRole.toLowerCase() == 'client';

    return ProfessionalMessageEntity(
      id: id,
      authorRole: authorRole,
      body: body.trim(),
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  @visibleForTesting
  static bool isIgnorableMessagesBackendError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('relation') ||
        raw.contains('column') ||
        raw.contains('schema cache') ||
        raw.contains('does not exist') ||
        raw.contains('could not find') ||
        raw.contains('pgrst');
  }

  static String? _firstString(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value == null) {
        continue;
      }
      final text = value.toString();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}
