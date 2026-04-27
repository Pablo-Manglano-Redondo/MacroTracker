import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';

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
          DateTime.now(),
          IntakeTypeEntity.breakfast,
        );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI photo meal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.08),
                colorScheme.surfaceContainerLow,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Photo-first logging',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Import a meal image, get an editable macro draft, fix portions fast and save it into ${_args.intakeTypeEntity.name}.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _CaptureStepChip(
                      icon: Icons.image_outlined,
                      label: 'Pick image',
                    ),
                    _CaptureStepChip(
                      icon: Icons.tune_outlined,
                      label: 'Review items',
                    ),
                    _CaptureStepChip(
                      icon: Icons.restaurant_outlined,
                      label: 'Save meal',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What works best',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const _CaptureHintRow(
                    icon: Icons.crop_free_outlined,
                    title: 'Keep the whole plate visible',
                    subtitle: 'Better framing means better ingredient guesses.',
                  ),
                  const SizedBox(height: 10),
                  const _CaptureHintRow(
                    icon: Icons.opacity_outlined,
                    title: 'Sauces and oils still need review',
                    subtitle:
                        'The draft is only the first pass. Correct hidden calories.',
                  ),
                  const SizedBox(height: 10),
                  const _CaptureHintRow(
                    icon: Icons.fitness_center_outlined,
                    title: 'Built for gym meals',
                    subtitle:
                        'Use it for bowls, shakes, post-workout plates and repeats.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : _pickAndInterpretPhoto,
            icon: Icon(
              _isLoading ? Icons.hourglass_top_outlined : Icons.auto_awesome,
            ),
            label: Text(
              _isLoading ? 'Building AI draft...' : 'Choose image and review',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _isLoading ? null : _openTextFlow,
              icon: const Icon(Icons.notes_outlined),
              label: const Text('Use text instead'),
            ),
          ),
        ],
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
      final updatedDraft = draft.copyWith(localImagePath: file.path);
      await locator<SaveInterpretationDraftUsecase>().saveDraft(updatedDraft);

      if (mounted) {
        Navigator.of(context).pushNamed(
          NavigationOptions.mealInterpretationReviewRoute,
          arguments: MealInterpretationReviewScreenArguments(
            updatedDraft.id,
            _args.day,
            _args.intakeTypeEntity,
          ),
        );
      }
    } catch (_) {
      await _createLocalDraft(imagePath: file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Remote image interpretation is unavailable. A fallback draft was created instead.',
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

  void _openTextFlow() {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealTextCaptureRoute,
      arguments: MealTextCaptureScreenArguments(
        _args.day,
        _args.intakeTypeEntity,
      ),
    );
  }

  Future<void> _createLocalDraft({String? imagePath}) async {
    final draft = InterpretationDraftEntity(
      id: IdGenerator.getUniqueID(),
      sourceType: DraftSourceEntity.photo,
      inputText: null,
      localImagePath: imagePath,
      title: 'Photo meal draft',
      summary: 'Fallback AI draft from image flow',
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
          draft.id,
          _args.day,
          _args.intakeTypeEntity,
        ),
      );
    }
  }
}

class MealPhotoCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealPhotoCaptureScreenArguments(this.day, this.intakeTypeEntity);
}

class _CaptureStepChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CaptureStepChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _CaptureHintRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CaptureHintRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
