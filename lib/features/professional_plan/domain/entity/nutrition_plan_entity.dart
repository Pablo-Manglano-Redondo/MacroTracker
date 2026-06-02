import 'package:equatable/equatable.dart';

class NutritionPlanEntity extends Equatable {
  final String id;
  final String professionalId;
  final String clientId;
  final String name;
  final String objective;
  final String? notes;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final List<NutritionPlanDayEntity> days;
  final List<NutritionPlanMealEntity> meals;

  const NutritionPlanEntity({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.name,
    required this.objective,
    required this.notes,
    required this.startsOn,
    required this.endsOn,
    required this.days,
    required this.meals,
  });

  NutritionPlanDayEntity? targetForDate(DateTime date) {
    final dateKey = _dateKey(date);
    final dated = days.where((day) => day.dateKey == dateKey);
    if (dated.isNotEmpty) {
      return dated.first;
    }
    final weekday = date.weekday;
    final templated = days.where((day) => day.weekday == weekday);
    if (templated.isNotEmpty) {
      return templated.first;
    }
    return days.isNotEmpty ? days.first : null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'client_id': clientId,
        'name': name,
        'objective': objective,
        'notes': notes,
        'starts_on': startsOn?.toIso8601String(),
        'ends_on': endsOn?.toIso8601String(),
        'days': days.map((day) => day.toJson()).toList(),
        'meals': meals.map((meal) => meal.toJson()).toList(),
      };

  factory NutritionPlanEntity.fromJson(Map<String, dynamic> json) {
    final rawDays = json['nutrition_plan_days'] ?? json['days'] ?? const [];
    final rawMeals = json['nutrition_plan_meals'] ?? json['meals'] ?? const [];
    return NutritionPlanEntity(
      id: json['id']?.toString() ?? '',
      professionalId: json['professional_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      objective: json['objective']?.toString() ?? '',
      notes: json['notes']?.toString(),
      startsOn: _parseDate(json['starts_on']),
      endsOn: _parseDate(json['ends_on']),
      days: (rawDays as List)
          .map((day) => NutritionPlanDayEntity.fromJson(
              Map<String, dynamic>.from(day as Map)))
          .toList(),
      meals: (rawMeals as List)
          .map((meal) => NutritionPlanMealEntity.fromJson(
              Map<String, dynamic>.from(meal as Map)))
          .toList(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
        id,
        professionalId,
        clientId,
        name,
        objective,
        notes,
        startsOn,
        endsOn,
        days,
        meals,
      ];
}

class NutritionPlanDayEntity extends Equatable {
  final String? dateKey;
  final int? weekday;
  final double kcalGoal;
  final double carbsGoal;
  final double fatGoal;
  final double proteinGoal;

  const NutritionPlanDayEntity({
    required this.dateKey,
    required this.weekday,
    required this.kcalGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.proteinGoal,
  });

  Map<String, dynamic> toJson() => {
        'plan_date': dateKey,
        'weekday': weekday,
        'kcal_goal': kcalGoal,
        'carbs_goal': carbsGoal,
        'fat_goal': fatGoal,
        'protein_goal': proteinGoal,
      };

  factory NutritionPlanDayEntity.fromJson(Map<String, dynamic> json) {
    return NutritionPlanDayEntity(
      dateKey: json['plan_date']?.toString(),
      weekday: _readInt(json['weekday']),
      kcalGoal: _readDouble(json['kcal_goal']),
      carbsGoal: _readDouble(json['carbs_goal']),
      fatGoal: _readDouble(json['fat_goal']),
      proteinGoal: _readDouble(json['protein_goal']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props =>
      [dateKey, weekday, kcalGoal, carbsGoal, fatGoal, proteinGoal];
}

class NutritionPlanMealEntity extends Equatable {
  final String id;
  final String slot;
  final String title;
  final String? notes;
  final double? kcal;
  final double? carbs;
  final double? fat;
  final double? protein;

  const NutritionPlanMealEntity({
    required this.id,
    required this.slot,
    required this.title,
    required this.notes,
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot': slot,
        'title': title,
        'notes': notes,
        'kcal': kcal,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
      };

  factory NutritionPlanMealEntity.fromJson(Map<String, dynamic> json) {
    return NutritionPlanMealEntity(
      id: json['id']?.toString() ?? '',
      slot: json['slot']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      notes: json['notes']?.toString(),
      kcal: _readNullableDouble(json['kcal']),
      carbs: _readNullableDouble(json['carbs']),
      fat: _readNullableDouble(json['fat']),
      protein: _readNullableDouble(json['protein']),
    );
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  List<Object?> get props =>
      [id, slot, title, notes, kcal, carbs, fat, protein];
}
