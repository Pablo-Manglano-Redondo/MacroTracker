import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_photo_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';

class MealPhotoCaptureScreen extends StatefulWidget {
  const MealPhotoCaptureScreen({super.key});

  @override
  State<MealPhotoCaptureScreen> createState() => _MealPhotoCaptureScreenState();
}

class _MealPhotoCaptureScreenState extends State<MealPhotoCaptureScreen> {
  late MealPhotoCaptureScreenArguments _args;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    _args = ModalRoute.of(context)?.settings.arguments
            as MealPhotoCaptureScreenArguments? ??
        MealPhotoCaptureScreenArguments(
            DateTime.now(), IntakeTypeEntity.breakfast);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo meal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Choose an image to estimate ingredients and macros.\nThe image may be processed remotely for inference, is never auto-saved as a meal, and the result always stays editable before logging.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _pickAndInterpretPhoto,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(_isLoading
                    ? 'Interpreting...'
                    : 'Choose image and create draft'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndInterpretPhoto() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final file = picked.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = await locator<GetConfigUsecase>().getConfig();
      final draft = await locator<InterpretMealFromPhotoUsecase>().interpret(
        imageBytes: bytes,
        fileName: file.name,
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
      await _createLocalDraft();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Remote image interpretation unavailable. A local fallback draft was created instead.'),
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

  Future<void> _createLocalDraft() async {
    final draft = InterpretationDraftEntity(
      id: IdGenerator.getUniqueID(),
      sourceType: DraftSourceEntity.photo,
      inputText: null,
      localImagePath: null,
      title: 'Photo meal draft',
      summary: 'Local placeholder interpretation from photo flow',
      totalKcal: 650,
      totalCarbs: 55,
      totalFat: 22,
      totalProtein: 38,
      confidenceBand: ConfidenceBandEntity.low,
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      items: [
        InterpretationDraftItemEntity(
          id: IdGenerator.getUniqueID(),
          label: 'Detected meal',
          matchedMealSnapshot: null,
          amount: 1,
          unit: 'serving',
          kcal: 650,
          carbs: 55,
          fat: 22,
          protein: 38,
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

class MealPhotoCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealPhotoCaptureScreenArguments(this.day, this.intakeTypeEntity);
}
