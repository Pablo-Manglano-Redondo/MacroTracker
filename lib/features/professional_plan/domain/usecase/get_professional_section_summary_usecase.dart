import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class GetProfessionalSectionSummaryUsecase {
  final ProfessionalPlanRepository _repository;
  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetIntakeUsecase _getIntakeUsecase;

  GetProfessionalSectionSummaryUsecase(
    this._repository,
    this._getTrackedDayUsecase,
    this._getIntakeUsecase,
  );

  Future<ProfessionalSectionSummaryEntity?> execute({
    bool refreshRemotePlan = false,
  }) async {
    final connection = await _loadConnection(
      refreshRemotePlan: refreshRemotePlan,
    );
    if (connection == null) {
      return null;
    }

    final now = DateTime.now();
    final todayTarget = connection.activePlan?.targetForDate(now);
    final weekStart = _startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final trackedDays =
        await _getTrackedDayUsecase.getTrackedDaysByRange(weekStart, weekEnd);
    final mealsByDay = <String, int>{};

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      mealsByDay[_dateKey(day)] = await _mealsLoggedForDay(day);
    }

    final todayTracked = trackedDays.firstWhereOrNull(
      (day) => _dateKey(day.day) == _dateKey(now),
    );
    final today = _buildSlice(
      trackedDays: [
        if (todayTracked != null) todayTracked,
      ],
      mealsByDay: mealsByDay,
      fallbackTarget: todayTarget,
    );
    final week = _buildSlice(
      trackedDays: trackedDays,
      mealsByDay: mealsByDay,
      fallbackTarget: todayTarget,
    );
    final pendingSyncCount = await _repository.getPendingSyncCount();
    final dailyNote = await _repository.getDailyNote(now);
    final pendingCheckinRequest = await _repository.getPendingCheckinRequest(
      connection: connection,
    );
    final messages = await _repository.getMessages(connection: connection);
    final pendingRecipeProposalCount =
        await _repository.getPendingRecipeProposalCount(connection: connection);
    final currentPlanSignature = connection.activePlan?.cacheSignature;
    final hasUnseenPlanUpdate = currentPlanSignature != null &&
        connection.lastPlanSyncAt != null &&
        connection.lastPlanSyncAt!.isAfter(
          now.subtract(const Duration(minutes: 10)),
        );
    return ProfessionalSectionSummaryEntity(
      connection: connection.copyWith(
        pendingSyncCount: pendingSyncCount,
      ),
      activePlan: connection.activePlan,
      todayTarget: todayTarget,
      weekPlan: connection.activePlan?.weekView(anchorDate: now) ?? const [],
      today: today,
      week: week,
      syncStatus: ProfessionalSyncStatusEntity(
        lastPlanSyncAt: connection.lastPlanSyncAt,
        lastSnapshotSyncAt: connection.lastSnapshotSyncAt,
        pendingSyncCount: pendingSyncCount,
        connectionStatus: connection.connectionStatus,
      ),
      weekTrackedDays: trackedDays,
      dailyNote: dailyNote,
      pendingCheckinRequest: pendingCheckinRequest,
      unreadMessageCount: messages.unreadCount,
      pendingRecipeProposalCount: pendingRecipeProposalCount,
      hasUnseenPlanUpdate: hasUnseenPlanUpdate,
    );
  }

  Future<ProfessionalConnectionEntity?> _loadConnection({
    required bool refreshRemotePlan,
  }) async {
    if (!refreshRemotePlan) {
      return _repository.getActiveConnection();
    }
    try {
      return await _repository.refreshActivePlan();
    } catch (_) {
      return _repository.getActiveConnection();
    }
  }

  Future<int> _mealsLoggedForDay(DateTime day) async {
    final mealGroups = await Future.wait<List<IntakeEntity>>([
      _getIntakeUsecase.getBreakfastIntakeByDay(day),
      _getIntakeUsecase.getLunchIntakeByDay(day),
      _getIntakeUsecase.getDinnerIntakeByDay(day),
      _getIntakeUsecase.getSnackIntakeByDay(day),
    ]);
    return mealGroups.fold<int>(
      0,
      (total, list) => total + list.length,
    );
  }

  ProfessionalAdherenceSliceEntity _buildSlice({
    required List<TrackedDayEntity> trackedDays,
    required Map<String, int> mealsByDay,
    required NutritionPlanDayEntity? fallbackTarget,
  }) {
    if (trackedDays.isEmpty) {
      return ProfessionalAdherenceSliceEntity(
        kcalTarget: fallbackTarget?.kcalGoal ?? 0,
        kcalActual: 0,
        carbsTarget: fallbackTarget?.carbsGoal ?? 0,
        carbsActual: 0,
        fatTarget: fallbackTarget?.fatGoal ?? 0,
        fatActual: 0,
        proteinTarget: fallbackTarget?.proteinGoal ?? 0,
        proteinActual: 0,
        mealsLogged: 0,
        trackedDays: 0,
      );
    }
    return ProfessionalAdherenceSliceEntity(
      kcalTarget: trackedDays.fold<double>(
        0,
        (total, day) => total + day.calorieGoal,
      ),
      kcalActual: trackedDays.fold<double>(
        0,
        (total, day) => total + day.caloriesTracked,
      ),
      carbsTarget: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.carbsGoal ?? 0),
      ),
      carbsActual: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.carbsTracked ?? 0),
      ),
      fatTarget: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.fatGoal ?? 0),
      ),
      fatActual: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.fatTracked ?? 0),
      ),
      proteinTarget: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.proteinGoal ?? 0),
      ),
      proteinActual: trackedDays.fold<double>(
        0,
        (total, day) => total + (day.proteinTracked ?? 0),
      ),
      mealsLogged: trackedDays.fold<int>(
        0,
        (total, day) => total + (mealsByDay[_dateKey(day.day)] ?? 0),
      ),
      trackedDays: trackedDays.length,
    );
  }

  DateTime _startOfWeek(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  String _dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}
