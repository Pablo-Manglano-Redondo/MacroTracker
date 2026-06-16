import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:macrotracker/core/utils/custom_icons.dart';
import 'package:macrotracker/generated/l10n.dart';


void main() {
  group('PhysicalActivityEntity Tests', () {
    test('props and equality check', () {
      final act1 = PhysicalActivityEntity(
        '01015',
        'Bicycling',
        'Outdoor cycling',
        8.0,
        const ['cycling'],
        PhysicalActivityTypeEntity.bicycling,
      );

      final act2 = PhysicalActivityEntity(
        '01015',
        'Bicycling',
        'Outdoor cycling',
        8.0,
        const ['cycling'],
        PhysicalActivityTypeEntity.bicycling,
      );

      final act3 = PhysicalActivityEntity(
        '02050',
        'Weightlifting',
        'Strength training',
        6.0,
        const ['weights'],
        PhysicalActivityTypeEntity.conditioningExercise,
      );

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
      expect(act1.props, contains('01015'));
      expect(act1.displayIcon, equals(Icons.directions_bike_outlined));
    });

    test('getDisplayIcon returns correct icon for specific codes', () {
      final bike = PhysicalActivityEntity('01015', '', '', 0, const [], PhysicalActivityTypeEntity.bicycling);
      final run = PhysicalActivityEntity('12020', '', '', 0, const [], PhysicalActivityTypeEntity.running);
      final kettlebell = PhysicalActivityEntity('02050', '', '', 0, const [], PhysicalActivityTypeEntity.conditioningExercise);
      final unknown = PhysicalActivityEntity('99999', '', '', 0, const [], PhysicalActivityTypeEntity.sport);

      expect(bike.getDisplayIcon(), equals(Icons.directions_bike_outlined));
      expect(run.getDisplayIcon(), equals(Icons.directions_run));
      expect(kettlebell.getDisplayIcon(), equals(CustomIcons.kettlebell));
      expect(unknown.getDisplayIcon(), equals(CustomIcons.medal));
    });

    test('PhysicalActivityTypeEntity extensions getTypeIcon', () {
      expect(PhysicalActivityTypeEntity.bicycling.getTypeIcon(), equals(Icons.directions_bike_outlined));
      expect(PhysicalActivityTypeEntity.running.getTypeIcon(), equals(Icons.directions_run_outlined));
      expect(PhysicalActivityTypeEntity.sport.getTypeIcon(), equals(Icons.sports_outlined));
    });

    test('conversions from and to DBO', () {
      final dbo = PhysicalActivityDBO(
        '01009',
        'Mountain Biking',
        'Mountain trail cycling',
        8.5,
        ['mtb'],
        PhysicalActivityTypeDBO.bicycling,
      );

      final entity = PhysicalActivityEntity.fromPhysicalActivityDBO(dbo);

      expect(entity.code, equals('01009'));
      expect(entity.specificActivity, equals('Mountain Biking'));
      expect(entity.description, equals('Mountain trail cycling'));
      expect(entity.mets, equals(8.5));
      expect(entity.tags, contains('mtb'));
      expect(entity.type, equals(PhysicalActivityTypeEntity.bicycling));
    });

    test('PhysicalActivityTypeEntity mapping from DBO type', () {
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.bicycling),
        equals(PhysicalActivityTypeEntity.bicycling),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.conditioningExercise),
        equals(PhysicalActivityTypeEntity.conditioningExercise),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.dancing),
        equals(PhysicalActivityTypeEntity.dancing),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.running),
        equals(PhysicalActivityTypeEntity.running),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.sport),
        equals(PhysicalActivityTypeEntity.sport),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.waterActivities),
        equals(PhysicalActivityTypeEntity.waterActivities),
      );
      expect(
        PhysicalActivityTypeEntity.fromPhysicalActivityTypeDBO(PhysicalActivityTypeDBO.winterActivities),
        equals(PhysicalActivityTypeEntity.winterActivities),
      );
    });

    testWidgets('getName, getDescription and getDisplayIcon for all standard codes', (tester) async {
      final codes = [
        "01015", "01009", "01070", "02010", "02030", "02050", "02068", "02120", "03015",
        "12020", "12150", "15010", "15030", "15055", "15080", "15090", "15100", "15110",
        "15130", "15135", "15138", "15150", "15160", "15170", "15180", "15192", "15200",
        "15230", "15235", "15240", "15255", "15300", "15310", "15320", "15340", "15350",
        "15360", "15370", "15420", "15425", "15430", "15440", "15460", "15465", "15470",
        "15480", "15500", "15510", "15530", "15533", "15544", "15551", "15560", "15562",
        "15570", "15580", "15590", "15592", "15600", "15610", "15620", "15652", "15660",
        "15670", "15675", "15700", "15710", "15730", "15731", "15732", "15733", "15734",
        "17010", "17080", "17160", "17165", "18070", "18090", "18100", "18110", "18120",
        "18150", "18200", "18210", "18220", "18225", "18350", "18355", "18360", "19030",
        "19075", "19252"
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                for (final code in codes) {
                  final entity = PhysicalActivityEntity(
                    code,
                    '',
                    '',
                    5.0,
                    const [],
                    PhysicalActivityTypeEntity.sport,
                  );

                  final name = entity.getName(context);
                  final desc = entity.getDescription(context);
                  final icon = entity.getDisplayIcon();

                  expect(name, isNotEmpty);
                  expect(desc, isNotEmpty);
                  expect(icon, isNotNull);
                }

                // Test fallback when code is not matched
                final unknownEntity = PhysicalActivityEntity(
                  'unknown_code',
                  '',
                  '',
                  5.0,
                  const [],
                  PhysicalActivityTypeEntity.sport,
                );
                expect(unknownEntity.getName(context), equals(PhysicalActivityTypeEntity.sport.getName(context)));

                // Test health connect 'hc:' prefix behavior
                final hcEntity = PhysicalActivityEntity(
                  'hc:123',
                  'Custom Activity',
                  'Custom Description',
                  5.0,
                  const [],
                  PhysicalActivityTypeEntity.sport,
                );
                expect(hcEntity.getName(context), equals('Custom Activity'));
                expect(hcEntity.getDescription(context), equals('Custom Description'));

                final hcEmptyEntity = PhysicalActivityEntity(
                  'hc:123',
                  '',
                  '',
                  5.0,
                  const [],
                  PhysicalActivityTypeEntity.sport,
                );
                expect(hcEmptyEntity.getName(context), equals(PhysicalActivityTypeEntity.sport.getName(context)));

                // Test all enum type names
                for (final type in PhysicalActivityTypeEntity.values) {
                  expect(type.getName(context), isNotEmpty);
                  expect(type.getTypeIcon(), isNotNull);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}

