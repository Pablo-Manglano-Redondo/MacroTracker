import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/data_source/physical_activity_data_source.dart';

void main() {
  group('PhysicalActivityDataSource Tests', () {
    test('getPhysicalActivityList returns non-empty list of activities', () {
      final dataSource = PhysicalActivityDataSource();
      final list = dataSource.getPhysicalActivityList();

      expect(list, isNotEmpty);
      expect(list.length, greaterThan(50));

      final first = list.first;
      expect(first.code, isNotEmpty);
      expect(first.specificActivity, isNotEmpty);
      expect(first.description, isNotEmpty);
      expect(first.mets, greaterThan(0));
      expect(first.type, isNotNull);
    });
  });
}
