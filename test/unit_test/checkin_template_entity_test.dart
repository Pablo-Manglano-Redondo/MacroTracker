import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';

void main() {
  group('CheckinTemplateEntity and CheckinQuestionEntity Tests', () {
    test('serialization and deserialization roundtrip', () {
      final question1 = const CheckinQuestionEntity(
        id: 'q1',
        label: 'How do you feel today?',
        type: 'text',
      );
      final question2 = const CheckinQuestionEntity(
        id: 'q2',
        label: 'Energy level (1-5)',
        type: 'rating',
      );

      final template = CheckinTemplateEntity(
        id: 'template-1',
        title: 'Daily Check-in',
        questions: [question1, question2],
      );

      // Verify question toJson / fromJson
      final qMap = question1.toJson();
      expect(qMap['id'], 'q1');
      expect(qMap['label'], 'How do you feel today?');
      expect(qMap['type'], 'text');

      final deserializedQ = CheckinQuestionEntity.fromJson(qMap);
      expect(deserializedQ, question1);

      // Verify template toJson / fromJson
      final tMap = template.toJson();
      expect(tMap['id'], 'template-1');
      expect(tMap['title'], 'Daily Check-in');
      expect(tMap['questions'], isA<List>());
      expect(tMap['questions'].length, 2);

      final deserializedT = CheckinTemplateEntity.fromJson(tMap);
      expect(deserializedT, template);
      expect(deserializedT.questions.first.label, 'How do you feel today?');
    });

    test('fromJson with missing fields uses defaults', () {
      final rawQ = <String, dynamic>{};
      final question = CheckinQuestionEntity.fromJson(rawQ);
      expect(question.id, '');
      expect(question.label, '');
      expect(question.type, 'text');

      final rawT = <String, dynamic>{};
      final template = CheckinTemplateEntity.fromJson(rawT);
      expect(template.id, '');
      expect(template.title, '');
      expect(template.questions, isEmpty);
    });

    test('Equatable props check', () {
      const q1 = CheckinQuestionEntity(id: '1', label: 'L', type: 'T');
      const q2 = CheckinQuestionEntity(id: '1', label: 'L', type: 'T');
      expect(q1, q2);

      final t1 = CheckinTemplateEntity(id: '1', title: 'T', questions: [q1]);
      final t2 = CheckinTemplateEntity(id: '1', title: 'T', questions: [q2]);
      expect(t1, t2);
    });
  });
}
