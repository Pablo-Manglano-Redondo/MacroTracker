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

  const ProfessionalMessageEntity({
    required this.id,
    required this.authorRole,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  ProfessionalMessageEntity copyWith({bool? isRead}) {
    return ProfessionalMessageEntity(
      id: id,
      authorRole: authorRole,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, authorRole, body, createdAt, isRead];
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
  }) : _weekTrackedDays = weekTrackedDays;

  bool get hasActivePlan => activePlan != null && todayTarget != null;

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
      ];
}
