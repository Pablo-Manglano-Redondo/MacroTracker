import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  testWidgets('DashboardWidget displays correct data',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: DashboardWidget(
            nutritionPhase: UserWeightGoalEntity.gainWeight,
            onNutritionPhaseChanged: _noopPhaseChange,
            dailyFocus: DailyFocusEntity.training,
            onDailyFocusChanged: _noopFocusChange,
            trainingTemplate: TrainingDayTemplateEntity.upperBody,
            onTrainingTemplateChanged: _noopTrainingTemplateChange,
            totalKcalSupplied: 1500,
            totalKcalBurned: 500,
            totalKcalDaily: 2000,
            totalKcalLeft: 1000,
            totalCarbsIntake: 200,
            totalFatsIntake: 50,
            totalProteinsIntake: 100,
            totalCarbsGoal: 250,
            totalFatsGoal: 60,
            totalProteinsGoal: 120,
            mealsLogged: 4,
            sessionsLogged: 1,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Gym nutrition'), findsOneWidget);
    expect(find.text('4 meals logged'), findsOneWidget);
    expect(find.text('500 burned'), findsOneWidget);
    expect(find.text('1 sessions'), findsOneWidget);
    expect(find.text('Protein left'), findsOneWidget);
    expect(find.text('Kcal left'), findsOneWidget);
    expect(find.text('Feed performance and recover hard'), findsOneWidget);
    expect(find.text('Push performance and recovery'), findsOneWidget);
    expect(find.text('Bulk'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);

    final counters = tester.widgetList<AnimatedFlipCounter>(
      find.byType(AnimatedFlipCounter),
    );
    expect(counters.map((counter) => counter.value), containsAll([20, 1000]));
  });
}

void _noopPhaseChange(UserWeightGoalEntity _) {}

void _noopFocusChange(DailyFocusEntity _) {}

void _noopTrainingTemplateChange(TrainingDayTemplateEntity _) {}
