import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  testWidgets('serving aggregate shows nutrition per serving', (tester) async {
    await tester.pumpWidget(_TestApp(
      child: MealDetailNutrimentsTable(
        product: _servingMeal(kcal100: 520, servingQuantity: 100),
        usesImperialUnits: false,
        servingQuantity: 100,
        servingUnit: 'serving',
      ),
    ));

    expect(find.textContaining('raci'), findsOneWidget);
    expect(find.text('520 kcal'), findsOneWidget);
    expect(find.text('52000 kcal'), findsNothing);
  });

  testWidgets('legacy serving aggregate is corrected for display',
      (tester) async {
    await tester.pumpWidget(_TestApp(
      child: MealDetailNutrimentsTable(
        product: _servingMeal(kcal100: 52000, servingQuantity: null),
        usesImperialUnits: false,
      ),
    ));

    expect(find.textContaining('raci'), findsOneWidget);
    expect(find.text('520 kcal'), findsOneWidget);
    expect(find.text('52000 kcal'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}

MealEntity _servingMeal({
  required double kcal100,
  required double? servingQuantity,
}) {
  return MealEntity(
    code: 'aggregate-1',
    name: 'Bowl',
    url: null,
    mealQuantity: '1',
    mealUnit: 'serving',
    servingQuantity: servingQuantity,
    servingUnit: servingQuantity == null ? null : 'serving',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity(
      energyKcal100: kcal100,
      carbohydrates100: 60,
      fat100: 18,
      proteins100: 32,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    ),
    source: MealSourceEntity.custom,
  );
}
