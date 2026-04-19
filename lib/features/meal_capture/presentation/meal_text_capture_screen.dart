import 'dart:io';

import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/usecase/interpret_meal_from_text_usecase.dart';
import 'package:opennutritracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:opennutritracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';

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
        MealTextCaptureScreenArguments(DateTime.now(), IntakeTypeEntity.breakfast);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text meal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Example: 2 eggs, toast with butter and coffee with milk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _createDraft,
                child: Text(_isLoading ? 'Interpreting...' : 'Interpret meal'),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Describe the meal naturally. The text may be processed remotely to estimate ingredients and macros, and you will always review the draft before saving.',
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
      final draft = await locator<InterpretMealFromTextUsecase>().interpret(
        text: input,
        locale: Platform.localeName,
        unitSystem: config.usesImperialUnits ? 'imperial' : 'metric',
        mealTypeHint: _args.intakeTypeEntity.name,
      );

      if (mounted) {
        Navigator.of(context).pushNamed(
          NavigationOptions.mealInterpretationReviewRoute,
          arguments: MealInterpretationReviewScreenArguments(
              draft.id, _args.day, _args.intakeTypeEntity),
        );
      }
    } catch (_) {
      await _createLocalDraft(input);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Remote interpretation unavailable. A local fallback draft was created instead.'),
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
    final itemId = IdGenerator.getUniqueID();
    final draft = InterpretationDraftEntity(
      id: IdGenerator.getUniqueID(),
      sourceType: DraftSourceEntity.text,
      inputText: input,
      localImagePath: null,
      title: input,
      summary: 'Local placeholder interpretation',
      totalKcal: 500,
      totalCarbs: 40,
      totalFat: 20,
      totalProtein: 30,
      confidenceBand: ConfidenceBandEntity.low,
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      items: [
        InterpretationDraftItemEntity(
          id: itemId,
          label: input,
          matchedMealSnapshot: null,
          amount: 1,
          unit: 'serving',
          kcal: 500,
          carbs: 40,
          fat: 20,
          protein: 30,
          confidenceBand: ConfidenceBandEntity.low,
          editable: true,
          removed: false,
        ),
      ],
    );

    await locator<SaveInterpretationDraftUsecase>().saveDraft(draft);
    if (mounted) {
      Navigator.of(context).pushNamed(
        NavigationOptions.mealInterpretationReviewRoute,
        arguments: MealInterpretationReviewScreenArguments(
            draft.id, _args.day, _args.intakeTypeEntity),
      );
    }
  }
}

class MealTextCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealTextCaptureScreenArguments(this.day, this.intakeTypeEntity);
}
