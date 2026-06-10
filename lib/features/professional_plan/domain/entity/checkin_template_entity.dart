import 'package:equatable/equatable.dart';

class CheckinTemplateEntity extends Equatable {
  final String id;
  final String title;
  final List<CheckinQuestionEntity> questions;

  const CheckinTemplateEntity({
    required this.id,
    required this.title,
    required this.questions,
  });

  factory CheckinTemplateEntity.fromJson(Map<String, dynamic> json) {
    final list = json['questions'] as List<dynamic>? ?? const [];
    return CheckinTemplateEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      questions: list
          .map((q) => CheckinQuestionEntity.fromJson(Map<String, dynamic>.from(q as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, questions];
}

class CheckinQuestionEntity extends Equatable {
  final String id;
  final String label;
  final String type; // 'text' | 'rating' | 'boolean'

  const CheckinQuestionEntity({
    required this.id,
    required this.label,
    required this.type,
  });

  factory CheckinQuestionEntity.fromJson(Map<String, dynamic> json) {
    return CheckinQuestionEntity(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type,
      };

  @override
  List<Object?> get props => [id, label, type];
}
