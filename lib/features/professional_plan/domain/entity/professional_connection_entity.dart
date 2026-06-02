import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';

class ProfessionalConnectionEntity extends Equatable {
  final String relationshipId;
  final String professionalId;
  final String clientId;
  final String professionalName;
  final DateTime connectedAt;
  final DateTime consentAcceptedAt;
  final NutritionPlanEntity? activePlan;

  const ProfessionalConnectionEntity({
    required this.relationshipId,
    required this.professionalId,
    required this.clientId,
    required this.professionalName,
    required this.connectedAt,
    required this.consentAcceptedAt,
    required this.activePlan,
  });

  Map<String, dynamic> toJson() => {
        'relationship_id': relationshipId,
        'professional_id': professionalId,
        'client_id': clientId,
        'professional_name': professionalName,
        'connected_at': connectedAt.toIso8601String(),
        'consent_accepted_at': consentAcceptedAt.toIso8601String(),
        'active_plan': activePlan?.toJson(),
      };

  factory ProfessionalConnectionEntity.fromJson(Map<String, dynamic> json) {
    final plan = json['active_plan'];
    return ProfessionalConnectionEntity(
      relationshipId: json['relationship_id']?.toString() ?? '',
      professionalId: json['professional_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      professionalName: json['professional_name']?.toString() ?? '',
      connectedAt: DateTime.tryParse(json['connected_at']?.toString() ?? '') ??
          DateTime.now(),
      consentAcceptedAt:
          DateTime.tryParse(json['consent_accepted_at']?.toString() ?? '') ??
              DateTime.now(),
      activePlan: plan is Map
          ? NutritionPlanEntity.fromJson(Map<String, dynamic>.from(plan))
          : null,
    );
  }

  ProfessionalConnectionEntity copyWith({
    NutritionPlanEntity? activePlan,
  }) {
    return ProfessionalConnectionEntity(
      relationshipId: relationshipId,
      professionalId: professionalId,
      clientId: clientId,
      professionalName: professionalName,
      connectedAt: connectedAt,
      consentAcceptedAt: consentAcceptedAt,
      activePlan: activePlan ?? this.activePlan,
    );
  }

  @override
  List<Object?> get props => [
        relationshipId,
        professionalId,
        clientId,
        professionalName,
        connectedAt,
        consentAcceptedAt,
        activePlan,
      ];
}

class ProfessionalInvitePreviewEntity extends Equatable {
  final String inviteId;
  final String code;
  final String professionalId;
  final String professionalName;
  final DateTime? expiresAt;
  final bool isExpired;

  const ProfessionalInvitePreviewEntity({
    required this.inviteId,
    required this.code,
    required this.professionalId,
    required this.professionalName,
    required this.expiresAt,
    required this.isExpired,
  });

  factory ProfessionalInvitePreviewEntity.fromJson(Map<String, dynamic> json) {
    final professional = json['professionals'];
    final professionalMap = professional is Map
        ? Map<String, dynamic>.from(professional)
        : const <String, dynamic>{};
    final expiresAt = DateTime.tryParse(json['expires_at']?.toString() ?? '');
    final displayName = professionalMap['display_name']?.toString();
    final businessName = professionalMap['business_name']?.toString();

    return ProfessionalInvitePreviewEntity(
      inviteId: json['id']?.toString() ?? '',
      code: json['invite_code']?.toString() ?? '',
      professionalId: json['professional_id']?.toString() ??
          professionalMap['id']?.toString() ??
          '',
      professionalName: businessName?.isNotEmpty == true
          ? businessName!
          : (displayName?.isNotEmpty == true ? displayName! : 'Professional'),
      expiresAt: expiresAt,
      isExpired: expiresAt != null && expiresAt.isBefore(DateTime.now()),
    );
  }

  @override
  List<Object?> get props =>
      [inviteId, code, professionalId, professionalName, expiresAt, isExpired];
}

class ProfessionalPlanSummaryEntity extends Equatable {
  final String professionalName;
  final String planName;
  final double kcalTarget;
  final double kcalActual;
  final double carbsTarget;
  final double carbsActual;
  final double fatTarget;
  final double fatActual;
  final double proteinTarget;
  final double proteinActual;

  const ProfessionalPlanSummaryEntity({
    required this.professionalName,
    required this.planName,
    required this.kcalTarget,
    required this.kcalActual,
    required this.carbsTarget,
    required this.carbsActual,
    required this.fatTarget,
    required this.fatActual,
    required this.proteinTarget,
    required this.proteinActual,
  });

  double get adherenceRatio {
    if (kcalTarget <= 0) return 0;
    final deviation = (kcalTarget - kcalActual).abs() / kcalTarget;
    return (1 - deviation).clamp(0, 1).toDouble();
  }

  double get kcalDelta => kcalActual - kcalTarget;

  @override
  List<Object?> get props => [
        professionalName,
        planName,
        kcalTarget,
        kcalActual,
        carbsTarget,
        carbsActual,
        fatTarget,
        fatActual,
        proteinTarget,
        proteinActual,
      ];
}
