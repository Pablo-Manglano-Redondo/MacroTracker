import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class ProfessionalPlanRepository {
  final ProfessionalPlanDataSource _dataSource;

  ProfessionalPlanRepository(this._dataSource);

  Future<ProfessionalConnectionEntity?> getActiveConnection() {
    return _dataSource.getActiveConnection();
  }

  Future<ProfessionalConnectionEntity?> refreshActivePlan() {
    return _dataSource.refreshActivePlan();
  }

  Future<ProfessionalInvitePreviewEntity?> fetchInvitePreview(String code) {
    return _dataSource.fetchInvitePreview(code);
  }

  Future<ProfessionalConnectionEntity> acceptInvite(String code) {
    return _dataSource.acceptInvite(code);
  }

  Future<void> disconnect() {
    return _dataSource.clearActiveConnection();
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
  }) {
    return _dataSource.uploadDailySnapshot(
      connection: connection,
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
      notes: notes,
      weightKg: weightKg,
      waistCm: waistCm,
    );
  }

  Future<void> uploadDiaryEntries({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required List<Map<String, dynamic>> entries,
  }) {
    return _dataSource.uploadDiaryEntries(
      connection: connection,
      day: day,
      entries: entries,
    );
  }

  Future<void> saveDailyNote(DateTime day, String note) {
    return _dataSource.saveDailyNote(day, note);
  }

  Future<String?> getDailyNote(DateTime day) {
    return _dataSource.getDailyNote(day);
  }

  Future<void> processPendingSyncs() {
    return _dataSource.processPendingSyncs();
  }

  Future<int> getPendingSyncCount() {
    return _dataSource.getPendingSyncCount();
  }

  Future<ProfessionalCheckinRequestEntity?> getPendingCheckinRequest({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.getPendingCheckinRequest(connection: connection);
  }

  Future<int> getPendingRecipeProposalCount({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.getPendingRecipeProposalCount(connection: connection);
  }

  Future<ProfessionalMessageThreadEntity> getMessages({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.getMessages(connection: connection);
  }

  Future<void> markMessageRead({
    required ProfessionalConnectionEntity connection,
    required String messageId,
  }) {
    return _dataSource.markMessageRead(
      connection: connection,
      messageId: messageId,
    );
  }

  Future<ProfessionalMessageEntity> sendMessage({
    required ProfessionalConnectionEntity connection,
    required String body,
  }) {
    return _dataSource.sendMessage(
      connection: connection,
      body: body,
    );
  }

  Future<ProfessionalSharingScopeEntity> getSharingScope({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.getSharingScope(connection: connection);
  }

  Future<void> updateSharingMode({
    required String relationshipId,
    required String clientId,
    required String sharingMode,
  }) {
    return _dataSource.updateSharingMode(
      relationshipId: relationshipId,
      clientId: clientId,
      sharingMode: sharingMode,
    );
  }

  Future<int> getUnseenSectionCount() {
    return _dataSource.getUnseenSectionCount();
  }

  Future<void> markSectionSeen({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.markSectionSeen(connection: connection);
  }

  Future<bool> isPlanUnseen({
    required ProfessionalConnectionEntity connection,
  }) {
    return _dataSource.isPlanUnseen(connection: connection);
  }
}
