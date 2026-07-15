import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_plan_card.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  testWidgets('ProfessionalPlanCard highlights active plan and opens details',
      (tester) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: Size(320, 640)),
            child: SingleChildScrollView(
              child: ProfessionalPlanCard(
                padding: const EdgeInsets.all(16),
                summary: const ProfessionalPlanSummaryEntity(
                  professionalName: 'Coach Studio',
                  planName: 'Semana fuerza',
                  kcalTarget: 2200,
                  kcalActual: 1850,
                  carbsTarget: 250,
                  carbsActual: 210,
                  fatTarget: 70,
                  fatActual: 62,
                  proteinTarget: 170,
                  proteinActual: 150,
                ),
                onOpenPlan: () => opened = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Semana fuerza'), findsOneWidget);
    expect(find.text('Coach Studio'), findsOneWidget);
    expect(find.text('Ver plan'), findsOneWidget);

    await tester.tap(find.text('Ver plan'));
    expect(opened, isTrue);
  });
}
