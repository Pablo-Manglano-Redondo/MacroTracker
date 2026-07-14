import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class ProfessionalSyncStatusEntity extends Equatable {
  final DateTime? lastPlanSyncAt;
  final DateTime? lastSnapshotSyncAt;
  final int pendingSyncCount;
  final String connectionStatus;

  const ProfessionalSyncStatusEntity({
    required this.lastPlanSyncAt,
    required this.lastSnapshotSyncAt,
    required this.pendingSyncCount,
    required this.connectionStatus,
  });

  bool get hasPendingSyncs => pendingSyncCount > 0;

  @override
  List<Object?> get props => [
        lastPlanSyncAt,
        lastSnapshotSyncAt,
        pendingSyncCount,
        connectionStatus,
      ];
}

class ProfessionalSharingScopeEntity extends Equatable {
  final String sharingMode;
  final bool messagesEnabled;
  final DateTime consentAcceptedAt;
  final List<String> sharedNow;
  final List<String> notSharedYet;
  final List<String> nextAvailable;

  const ProfessionalSharingScopeEntity({
    required this.sharingMode,
    required this.messagesEnabled,
    required this.consentAcceptedAt,
    required this.sharedNow,
    required this.notSharedYet,
    required this.nextAvailable,
  });

  @override
  List<Object?> get props => [
        sharingMode,
        messagesEnabled,
        consentAcceptedAt,
        sharedNow,
        notSharedYet,
        nextAvailable,
      ];
}

class ProfessionalMessageEntity extends Equatable {
  final String id;
  final String authorRole;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? professionalReadAt;

  const ProfessionalMessageEntity({
    required this.id,
    required this.authorRole,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.professionalReadAt,
  });

  ProfessionalMessageEntity copyWith({bool? isRead, DateTime? professionalReadAt}) {
    return ProfessionalMessageEntity(
      id: id,
      authorRole: authorRole,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      professionalReadAt: professionalReadAt ?? this.professionalReadAt,
    );
  }

  @override
  List<Object?> get props => [id, authorRole, body, createdAt, isRead, professionalReadAt];
}

class ProfessionalMessageThreadEntity extends Equatable {
  final String threadId;
  final bool isSupported;
  final bool messagesEnabled;
  final List<ProfessionalMessageEntity> messages;

  const ProfessionalMessageThreadEntity({
    required this.threadId,
    required this.isSupported,
    required this.messagesEnabled,
    required this.messages,
  });

  int get unreadCount => messages.where((message) => !message.isRead).length;

  @override
  List<Object?> get props => [threadId, isSupported, messagesEnabled, messages];
}

class ProfessionalCheckinRequestEntity extends Equatable {
  final String id;
  final String professionalClientId;
  final String professionalId;
  final String clientId;
  final String? templateId;
  final String status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? completedCheckinId;

  const ProfessionalCheckinRequestEntity({
    required this.id,
    required this.professionalClientId,
    required this.professionalId,
    required this.clientId,
    required this.templateId,
    required this.status,
    required this.requestedAt,
    required this.completedAt,
    required this.completedCheckinId,
  });

  bool get isPending => status == 'pending';

  factory ProfessionalCheckinRequestEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalCheckinRequestEntity(
      id: json['id']?.toString() ?? '',
      professionalClientId: json['professional_client_id']?.toString() ?? '',
      professionalId: json['professional_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      templateId: json['template_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      requestedAt: DateTime.tryParse(json['requested_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      completedCheckinId: json['completed_checkin_id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        professionalClientId,
        professionalId,
        clientId,
        templateId,
        status,
        requestedAt,
        completedAt,
        completedCheckinId,
      ];
}

enum ProfessionalPendingActionKind {
  checkin,
  messages,
  recipes,
  plan,
  sync,
}

class ProfessionalPendingActionEntity extends Equatable {
  final ProfessionalPendingActionKind kind;
  final int count;

  const ProfessionalPendingActionEntity({
    required this.kind,
    this.count = 1,
  });

  @override
  List<Object?> get props => [kind, count];
}

class ProfessionalAdherenceSliceEntity extends Equatable {
  final double kcalTarget;
  final double kcalActual;
  final double carbsTarget;
  final double carbsActual;
  final double fatTarget;
  final double fatActual;
  final double proteinTarget;
  final double proteinActual;
  final int mealsLogged;
  final int trackedDays;

  const ProfessionalAdherenceSliceEntity({
    required this.kcalTarget,
    required this.kcalActual,
    required this.carbsTarget,
    required this.carbsActual,
    required this.fatTarget,
    required this.fatActual,
    required this.proteinTarget,
    required this.proteinActual,
    required this.mealsLogged,
    required this.trackedDays,
  });

  double adherenceFor(double target, double actual) {
    if (target <= 0) return 0;
    final deviation = (target - actual).abs() / target;
    return (1 - deviation).clamp(0, 1).toDouble();
  }

  double get kcalAdherence => adherenceFor(kcalTarget, kcalActual);

  @override
  List<Object?> get props => [
        kcalTarget,
        kcalActual,
        carbsTarget,
        carbsActual,
        fatTarget,
        fatActual,
        proteinTarget,
        proteinActual,
        mealsLogged,
        trackedDays,
      ];
}

class ProfessionalSectionSummaryEntity extends Equatable {
  final ProfessionalConnectionEntity connection;
  final NutritionPlanEntity? activePlan;
  final NutritionPlanDayEntity? todayTarget;
  final List<NutritionPlanResolvedDayEntity> weekPlan;
  final ProfessionalAdherenceSliceEntity today;
  final ProfessionalAdherenceSliceEntity week;
  final ProfessionalSyncStatusEntity syncStatus;
  final List<TrackedDayEntity>? _weekTrackedDays;
  List<TrackedDayEntity> get weekTrackedDays => _weekTrackedDays ?? const [];
  final String? dailyNote;
  final ProfessionalCheckinRequestEntity? pendingCheckinRequest;
  final int unreadMessageCount;
  final int pendingRecipeProposalCount;
  final bool hasUnseenPlanUpdate;

  const ProfessionalSectionSummaryEntity({
    required this.connection,
    required this.activePlan,
    required this.todayTarget,
    required this.weekPlan,
    required this.today,
    required this.week,
    required this.syncStatus,
    List<TrackedDayEntity>? weekTrackedDays,
    this.dailyNote,
    this.pendingCheckinRequest,
    this.unreadMessageCount = 0,
    this.pendingRecipeProposalCount = 0,
    this.hasUnseenPlanUpdate = false,
  }) : _weekTrackedDays = weekTrackedDays;

  bool get hasActivePlan => activePlan != null && todayTarget != null;

  List<ProfessionalPendingActionEntity> get pendingActions => [
        if (pendingCheckinRequest?.isPending == true)
          const ProfessionalPendingActionEntity(
            kind: ProfessionalPendingActionKind.checkin,
          ),
        if (unreadMessageCount > 0)
          ProfessionalPendingActionEntity(
            kind: ProfessionalPendingActionKind.messages,
            count: unreadMessageCount,
          ),
        if (pendingRecipeProposalCount > 0)
          ProfessionalPendingActionEntity(
            kind: ProfessionalPendingActionKind.recipes,
            count: pendingRecipeProposalCount,
          ),
        if (hasUnseenPlanUpdate)
          const ProfessionalPendingActionEntity(
            kind: ProfessionalPendingActionKind.plan,
          ),
        if (syncStatus.hasPendingSyncs)
          ProfessionalPendingActionEntity(
            kind: ProfessionalPendingActionKind.sync,
            count: syncStatus.pendingSyncCount,
          ),
      ];

  int get pendingActionCount =>
      pendingActions.fold(0, (total, action) => total + action.count);

  @override
  List<Object?> get props => [
        connection,
        activePlan,
        todayTarget,
        weekPlan,
        today,
        week,
        syncStatus,
        _weekTrackedDays,
        dailyNote,
        pendingCheckinRequest,
        unreadMessageCount,
        pendingRecipeProposalCount,
        hasUnseenPlanUpdate,
      ];
}
