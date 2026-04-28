enum TrainingDayTemplateEntity {
  lowerBody,
  upperBody,
  rest;

  String get storageValue {
    switch (this) {
      case TrainingDayTemplateEntity.lowerBody:
        return 'lower_body';
      case TrainingDayTemplateEntity.upperBody:
        return 'upper_body';
      case TrainingDayTemplateEntity.rest:
        return 'rest';
    }
  }

  String get label {
    switch (this) {
      case TrainingDayTemplateEntity.lowerBody:
        return 'Pierna';
      case TrainingDayTemplateEntity.upperBody:
        return 'Torso';
      case TrainingDayTemplateEntity.rest:
        return 'Descanso';
    }
  }
}

extension TrainingDayTemplateEntityX on TrainingDayTemplateEntity {
  static TrainingDayTemplateEntity fromStorageValue(String? value) {
    switch (value) {
      case 'lower_body':
        return TrainingDayTemplateEntity.lowerBody;
      case 'upper_body':
        return TrainingDayTemplateEntity.upperBody;
      case 'rest':
      default:
        return TrainingDayTemplateEntity.rest;
    }
  }
}
