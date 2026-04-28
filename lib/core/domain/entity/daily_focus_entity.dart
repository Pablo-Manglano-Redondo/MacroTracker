enum DailyFocusEntity {
  lowerBody,
  upperBody,
  cardio,
  rest,
}

extension DailyFocusEntityX on DailyFocusEntity {
  String get storageValue {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return 'lowerBody';
      case DailyFocusEntity.upperBody:
        return 'upperBody';
      case DailyFocusEntity.cardio:
        return 'cardio';
      case DailyFocusEntity.rest:
        return 'rest';
    }
  }

  String get label {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return 'Pierna';
      case DailyFocusEntity.upperBody:
        return 'Torso';
      case DailyFocusEntity.cardio:
        return 'Cardio';
      case DailyFocusEntity.rest:
        return 'Descanso';
    }
  }

  String get headline {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return 'Día de pierna: prioriza energía y recuperación.';
      case DailyFocusEntity.upperBody:
        return 'Día de torso: rendimiento estable con buena recuperación.';
      case DailyFocusEntity.cardio:
        return 'Día de cardio: combustible limpio y control de fatiga.';
      case DailyFocusEntity.rest:
        return 'Día de descanso: recupera manteniendo proteína alta.';
    }
  }

  String get macroHint {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return 'Carbohidrato alto alrededor del entreno y proteína constante.';
      case DailyFocusEntity.upperBody:
        return 'Carbohidrato moderado-alto y proteína estable durante el día.';
      case DailyFocusEntity.cardio:
        return 'Carbohidrato moderado, grasas más contenidas e hidratación.';
      case DailyFocusEntity.rest:
        return 'Mantén proteína alta y recorta algo de carbohidrato.';
    }
  }

  double adjustKcalGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return (baseGoal * 1.10).roundToDouble();
      case DailyFocusEntity.upperBody:
        return (baseGoal * 1.06).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.02).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 0.94).roundToDouble();
    }
  }

  double adjustCarbGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return (baseGoal * 1.18).roundToDouble();
      case DailyFocusEntity.upperBody:
        return (baseGoal * 1.10).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.05).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 0.82).roundToDouble();
    }
  }

  double adjustProteinGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return (baseGoal * 1.08).roundToDouble();
      case DailyFocusEntity.upperBody:
        return (baseGoal * 1.06).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 1.03).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 1.1).roundToDouble();
    }
  }

  double adjustFatGoal(double baseGoal) {
    switch (this) {
      case DailyFocusEntity.lowerBody:
        return (baseGoal * 0.94).roundToDouble();
      case DailyFocusEntity.upperBody:
        return (baseGoal * 0.96).roundToDouble();
      case DailyFocusEntity.cardio:
        return (baseGoal * 0.92).roundToDouble();
      case DailyFocusEntity.rest:
        return (baseGoal * 1.05).roundToDouble();
    }
  }

  static DailyFocusEntity fromStorageValue(String? value) {
    switch (value) {
      case 'lowerBody':
      case 'leg':
      case 'pierna':
        return DailyFocusEntity.lowerBody;
      case 'upperBody':
      case 'torso':
      case 'training':
        return DailyFocusEntity.upperBody;
      case 'cardio':
        return DailyFocusEntity.cardio;
      case 'rest':
        return DailyFocusEntity.rest;
      default:
        return DailyFocusEntity.upperBody;
    }
  }
}
