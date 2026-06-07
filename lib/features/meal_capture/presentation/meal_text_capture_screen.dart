import 'dart:io';

import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/presentation/widgets/ai_usage_gate.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_capture/data/data_sources/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_text_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';
import 'package:macrotracker/core/presentation/widgets/shimmer_loading.dart';
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
      body: _isLoading
          ? _buildLoadingSkeleton(context)
          : Padding(
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
                      child: Text(_isLoading
                          ? S.of(context).aiTextCaptureLoading
                          : S.of(context).aiTextCaptureButton),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AiTrialBanner(placement: PaywallPlacement.aiText),
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

  Widget _buildLoadingSkeleton(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              const SkeletonBox(width: 72, height: 72, borderRadius: 24),
              const SizedBox(height: 24),
              Text(
                S.of(context).aiTextCaptureLoading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const SkeletonBox(
            width: double.infinity, height: 160, borderRadius: 20),
        const SizedBox(height: 16),
        const SkeletonBox(width: double.infinity, height: 90, borderRadius: 16),
        const SizedBox(height: 16),
        const SkeletonBox(width: double.infinity, height: 90, borderRadius: 16),
      ],
    );
  }

  Future<void> _createDraft() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      return;
    }

    final access = await AiUsageGate.ensureAccess(
      context,
      placement: PaywallPlacement.aiText,
    );
    if (!access.allowed) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = await locator<GetConfigUsecase>().getConfig();
      final personalizationContext =
          await locator<MealInterpretationPersonalizationUsecase>()
              .buildContext(
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
    } on MealInterpretationRemoteException catch (error) {
      if (mounted) {
        await _showAiFailureDialog(
          message: _buildFailureMessage(error),
          onRetry: _createDraft,
          onContinueManually: () => _createLocalDraft(input),
        );
      }
    } catch (_) {
      if (mounted) {
        await _showAiFailureDialog(
          message: S.current.aiTextCaptureError,
          onRetry: _createDraft,
          onContinueManually: () => _createLocalDraft(input),
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

  String _buildFailureMessage(MealInterpretationRemoteException error) {
    switch (error.category) {
      case MealInterpretationFailureCategory.timeout:
        return 'The AI request timed out. Retry or continue with a manual review.';
      case MealInterpretationFailureCategory.noNetwork:
        return 'No network connection. Retry when you are back online or continue manually.';
      case MealInterpretationFailureCategory.authInvalid:
        return 'Your cloud session expired. Protect or reopen your cloud account and try again.';
      case MealInterpretationFailureCategory.invalidResponse:
        return 'The AI response could not be used. Retry or continue with a manual draft.';
      case MealInterpretationFailureCategory.unavailable:
        return 'AI meal interpretation is temporarily unavailable. Retry or continue manually.';
    }
  }

  Future<void> _showAiFailureDialog({
    required String message,
    required Future<void> Function() onRetry,
    required Future<void> Function() onContinueManually,
  }) async {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEs ? 'IA no disponible' : 'AI unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onContinueManually();
            },
            child: Text(isEs ? 'Seguir manual' : 'Continue manually'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onRetry();
            },
            child: Text(isEs ? 'Reintentar' : 'Retry'),
          ),
        ],
      ),
    );
  }
}

class MealTextCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealTextCaptureScreenArguments(this.day, this.intakeTypeEntity);
}
