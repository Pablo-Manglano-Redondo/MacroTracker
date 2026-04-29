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
import 'package:macrotracker/generated/l10n.dart';

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
      appBar: AppBar(title: Text(S.of(context).aiTextCaptureTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: S.of(context).aiTextCaptureHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _createDraft,
                child:
                    Text(_isLoading ? S.of(context).aiTextCaptureLoading : S.of(context).aiTextCaptureButton),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).aiTextCaptureDescription,
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
          SnackBar(
            content: Text(
              S.current.aiTextCaptureError,
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
