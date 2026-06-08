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
  String _loadingInput = '';

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).aiTextCaptureTitle)),
      body: _isLoading
          ? _buildLoadingState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notes_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isSpanish
                            ? 'Describe tu comida'
                            : 'Describe your meal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSpanish
                            ? 'Escribe ingredientes, cantidades o una comida completa para que la IA te prepare un borrador.'
                            : 'Write ingredients, quantities, or a full meal so AI can prepare a draft for you.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isSpanish
                                    ? 'La IA crea un borrador editable. Tu revisas ingredientes y macros antes de guardar.'
                                    : 'AI creates an editable draft. You review ingredients and macros before saving.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AiTrialBanner(placement: PaywallPlacement.aiText),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isSpanish
                                    ? 'Que has comido'
                                    : 'What did you eat',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (_controller.text.trim().isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                                child: Text(
                                  _isSpanish ? 'Limpiar' : 'Clear',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          maxLines: 6,
                          minLines: 5,
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _isSpanish
                                ? 'Ej: 200 g de pollo, 150 g de arroz, ensalada con aceite de oliva y un yogur griego'
                                : 'Example: 200 g chicken, 150 g rice, salad with olive oil, and a Greek yogurt',
                            alignLabelWithHint: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isSpanish
                              ? 'Cuanto más concreto seas, mejor saldrá el borrador.'
                              : 'The more specific you are, the better the draft will be.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isSpanish ? 'Ejemplos rápidos' : 'Quick examples',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ExampleChip(
                      label:
                          _isSpanish ? 'Desayuno simple' : 'Simple breakfast',
                      onTap: () => _applyExample(
                        _isSpanish
                            ? 'Café con leche, tostada con tomate y dos huevos'
                            : 'Coffee with milk, toast with tomato, and two eggs',
                      ),
                    ),
                    _ExampleChip(
                      label: _isSpanish
                          ? 'Comida con cantidades'
                          : 'Meal with amounts',
                      onTap: () => _applyExample(
                        _isSpanish
                            ? '180 g de salmón, 220 g de patata asada y ensalada con 10 ml de aceite de oliva'
                            : '180 g salmon, 220 g roasted potato, and salad with 10 ml olive oil',
                      ),
                    ),
                    _ExampleChip(
                      label: _isSpanish ? 'Cena rápida' : 'Quick dinner',
                      onTap: () => _applyExample(
                        _isSpanish
                            ? 'Burrito de pollo con queso, guacamole y una coca cola zero'
                            : 'Chicken burrito with cheese, guacamole, and a Coke Zero',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _createDraft,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      _isSpanish ? 'Crear borrador con IA' : 'Create AI draft',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSpanish
                      ? 'Podrás corregir ingredientes antes de guardar.'
                      : 'You will be able to correct ingredients before saving.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      _isSpanish ? '¿Qué funciona mejor?' : 'What works best?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    subtitle: Text(
                      _isSpanish
                          ? 'Abre esto si quieres mejores resultados.'
                          : 'Open this if you want better results.',
                    ),
                    children: [
                      _TextHintRow(
                        icon: Icons.straighten_outlined,
                        title: _isSpanish
                            ? 'Incluye cantidades si las sabes'
                            : 'Include amounts if you know them',
                        subtitle: _isSpanish
                            ? 'Gramajes, unidades o cucharadas ayudan mucho a estimar mejor.'
                            : 'Grams, units, or tablespoons help estimate more accurately.',
                      ),
                      const SizedBox(height: 10),
                      _TextHintRow(
                        icon: Icons.restaurant_menu_outlined,
                        title: _isSpanish
                            ? 'Escribe plato y acompañamientos'
                            : 'Write the dish and the sides',
                        subtitle: _isSpanish
                            ? 'No pongas solo "pasta"; mejor "pasta con atún y tomate".'
                            : 'Do not write only "pasta"; better "pasta with tuna and tomato".',
                      ),
                      const SizedBox(height: 10),
                      _TextHintRow(
                        icon: Icons.local_drink_outlined,
                        title: _isSpanish
                            ? 'No olvides bebidas y salsas'
                            : 'Do not forget drinks and sauces',
                        subtitle: _isSpanish
                            ? 'Suelen cambiar bastante las calorías finales.'
                            : 'They often change the final calories quite a bit.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surfaceContainerLow,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.55),
                ),
                child: Text(
                  _loadingInput,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _loadingStepLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSpanish
                    ? 'Esto suele tardar entre 5 y 10 segundos.'
                    : 'This usually takes 5 to 10 seconds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isSpanish
                            ? 'La IA prepara un borrador. Luego podrás revisar, corregir o borrar ingredientes antes de guardar.'
                            : 'AI is preparing a draft. Later you will be able to review, edit, or remove ingredients before saving.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      _loadingInput = input;
    });

    try {
      setState(() {});
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
          _loadingInput = '';
        });
      }
    }
  }

  bool get _isSpanish => Localizations.localeOf(context).languageCode == 'es';

  String get _loadingStepLabel => _isSpanish
      ? 'Analizando ingredientes y cantidades'
      : 'Analyzing ingredients and quantities';

  void _applyExample(String value) {
    _controller
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
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
        return _isSpanish
            ? 'La petición de IA tardó demasiado. Reintenta o sigue con revisión manual.'
            : 'The AI request timed out. Retry or continue with a manual review.';
      case MealInterpretationFailureCategory.noNetwork:
        return _isSpanish
            ? 'No hay conexión. Reintenta cuando vuelvas a tener red o sigue manualmente.'
            : 'No network connection. Retry when you are back online or continue manually.';
      case MealInterpretationFailureCategory.authInvalid:
        return _isSpanish
            ? 'Tu sesión cloud caducó. Protege o reabre tu cuenta cloud y vuelve a intentarlo.'
            : 'Your cloud session expired. Protect or reopen your cloud account and try again.';
      case MealInterpretationFailureCategory.invalidResponse:
        return _isSpanish
            ? 'La respuesta de IA no se pudo usar. Reintenta o sigue con borrador manual.'
            : 'The AI response could not be used. Retry or continue with a manual draft.';
      case MealInterpretationFailureCategory.unavailable:
        return _isSpanish
            ? 'La interpretación de comidas por IA no está disponible temporalmente. Reintenta o sigue manualmente.'
            : 'AI meal interpretation is temporarily unavailable. Retry or continue manually.';
    }
  }

  Future<void> _showAiFailureDialog({
    required String message,
    required Future<void> Function() onRetry,
    required Future<void> Function() onContinueManually,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_isSpanish ? 'IA no disponible' : 'AI unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onContinueManually();
            },
            child: Text(
              _isSpanish ? 'Seguir manual' : 'Continue manually',
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onRetry();
            },
            child: Text(_isSpanish ? 'Reintentar' : 'Retry'),
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

class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.auto_awesome_outlined, size: 16),
    );
  }
}

class _TextHintRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TextHintRow({
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
