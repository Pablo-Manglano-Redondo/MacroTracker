import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class UploadProfessionalSnapshotUsecase {
  final ProfessionalPlanRepository _repository;

  UploadProfessionalSnapshotUsecase(this._repository);

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
    return _repository.uploadDailySnapshot(
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
}
