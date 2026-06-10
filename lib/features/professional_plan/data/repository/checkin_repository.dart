import 'package:macrotracker/features/professional_plan/data/data_source/checkin_data_source.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';

class CheckinRepository {
  final CheckinDataSource _dataSource;

  CheckinRepository(this._dataSource);

  Future<CheckinTemplateEntity?> fetchDefaultTemplate({
    required String professionalId,
  }) async {
    final raw = await _dataSource.fetchDefaultTemplate(professionalId: professionalId);
    if (raw == null) return null;
    return CheckinTemplateEntity.fromJson(raw);
  }

  Future<void> submitCheckin({
    required String professionalClientId,
    required String professionalId,
    required String clientId,
    String? templateId,
    Map<String, dynamic> answers = const {},
    int? energyLevel,
    double? sleepHours,
    String? mood,
    String? notes,
  }) {
    return _dataSource.submitCheckin(
      professionalClientId: professionalClientId,
      professionalId: professionalId,
      clientId: clientId,
      templateId: templateId,
      answers: answers,
      energyLevel: energyLevel,
      sleepHours: sleepHours,
      mood: mood,
      notes: notes,
    );
  }
}
