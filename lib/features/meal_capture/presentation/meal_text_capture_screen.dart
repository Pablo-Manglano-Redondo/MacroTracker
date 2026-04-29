import 'dart:io';

import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_text_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';

class MealTextCaptureScreen extends StatefulWidget {
  const MealTextCaptureScreen({super.key});

  @override
  State<MealTextCaptureScreen> createState() => _MealTextCaptureScreenState();
}

class _MealTextCaptureScreenState extends State<MealTextCaptureScreen> {
  final _controller = TextEditingController();
  late MealTextCaptureScreenArguments _args;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    _args = ModalRoute.of(context)?.settings.arguments
            as MealTextCaptureScreenArguments? ??
        MealTextCaptureScreenArguments(
          DateTime.now(),
          IntakeTypeEntity.breakfast,
        );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comida por texto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ejemplo: 2 huevos, tostadas con mantequilla y café con leche',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _createDraft,
                child:
                    Text(_isLoading ? 'Interpretando...' : 'Interpretar comida'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Describe la comida de forma natural. El texto puede procesarse de forma remota para estimar ingredientes y macros, y siempre revisarás el borrador antes de guardarlo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDraft() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = await locator<GetConfigUsecase>().getConfig();
      final personalizationContext =
          await locator<MealInterpretationPersonalizationUsecase>().buildContext(
        intakeType: _args.intakeTypeEntity,
        freeText: input,
      );

      final draft = await locator<InterpretMealFromTextUsecase>().interpret(
        text: input,
        locale: Platform.localeName,
        unitSystem: config.usesImperialUnits ? 'imperial' : 'metric',
        mealTypeHint: _args.intakeTypeEntity.name,
        analysisContext: personalizationContext.promptContext,
        personalExamples: personalizationContext.remoteExamples,
      );

      final personalizedDraft =
          await locator<MealInterpretationPersonalizationUsecase>()
              .personalizeDraft(
        draft: draft,
        intakeType: _args.intakeTypeEntity,
        context: personalizationContext,
      );
      await locator<SaveInterpretationDraftUsecase>()
          .saveDraft(personalizedDraft);

      if (mounted) {
        Navigator.of(context).pushNamed(
          NavigationOptions.mealInterpretationReviewRoute,
          arguments: MealInterpretationReviewScreenArguments(
            personalizedDraft.id,
            _args.day,
            _args.intakeTypeEntity,
          ),
        );
      }
    } catch (_) {
      await _createLocalDraft(input);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Interpretación remota no disponible. Se creó un borrador local con apoyo de memoria.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createLocalDraft(String input) async {
    final draft = await locator<MealInterpretationPersonalizationUsecase>()
        .buildFallbackDraft(
      sourceType: DraftSourceEntity.text,
      title: input,
      intakeType: _args.intakeTypeEntity,
      inputText: input,
    );

    await locator<SaveInterpretationDraftUsecase>().saveDraft(draft);
    if (mounted) {
      Navigator.of(context).pushNamed(
        NavigationOptions.mealInterpretationReviewRoute,
        arguments: MealInterpretationReviewScreenArguments(
          draft.id,
          _args.day,
          _args.intakeTypeEntity,
        ),
      );
    }
  }
}

class MealTextCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealTextCaptureScreenArguments(this.day, this.intakeTypeEntity);
}
