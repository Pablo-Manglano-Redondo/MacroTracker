import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

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
    );
  }
}
