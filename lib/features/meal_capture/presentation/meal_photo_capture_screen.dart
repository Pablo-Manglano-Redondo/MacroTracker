import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/presentation/widgets/ai_usage_gate.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_photo_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class MealPhotoCaptureScreen extends StatefulWidget {
  const MealPhotoCaptureScreen({super.key});

  @override
  State<MealPhotoCaptureScreen> createState() => _MealPhotoCaptureScreenState();
}

class _MealPhotoCaptureScreenState extends State<MealPhotoCaptureScreen> {
  static const _maxUploadBytes = 768 * 1024;
  static const _maxImageDimension = 1024;
  static const _primaryJpegQuality = 76;
  static const _fallbackJpegQuality = 68;
  static const _fallbackMaxImageDimension = 768;

  final ImagePicker _imagePicker = ImagePicker();
  late MealPhotoCaptureScreenArguments _args;
  String? _loadingStatus;
  Uint8List? _loadingPreviewBytes;
  _PhotoAiDebugStats? _loadingDebugStats;
  _SelectedMealPhoto? _pendingPhoto;

  bool get _isLoading => _loadingStatus != null;

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
      appBar: AppBar(title: Text(S.of(context).aiMealPhotoTitle)),
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
                          Icons.auto_awesome_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        S.of(context).aiCaptureByPhotoTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        S.of(context).aiCaptureByPhotoSubtitle(
                            _args.intakeTypeEntity.name),
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
                                    ? 'La IA propone ingredientes y macros. Tu revisas todo antes de guardar.'
                                    : 'AI suggests ingredients and macros. You review everything before saving.',
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
                      S.of(context).aiHintRecommendations,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    subtitle: Text(
                      _isSpanish
                          ? 'Abre esto si quieres mejorar la deteccion.'
                          : 'Open this if you want better detection.',
                    ),
                    children: [
                      _CaptureHintRow(
                        icon: Icons.crop_free_outlined,
                        title: S.of(context).aiHintShowFullPlateTitle,
                        subtitle: S.of(context).aiHintShowFullPlateSubtitle,
                      ),
                      const SizedBox(height: 10),
                      _CaptureHintRow(
                        icon: Icons.opacity_outlined,
                        title: S.of(context).aiHintCheckSaucesTitle,
                        subtitle: S.of(context).aiHintCheckSaucesSubtitle,
                      ),
                      const SizedBox(height: 10),
                      _CaptureHintRow(
                        icon: Icons.fitness_center_outlined,
                        title: S.of(context).aiHintGymMealsTitle,
                        subtitle: S.of(context).aiHintGymMealsSubtitle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AiTrialBanner(placement: PaywallPlacement.aiPhoto),
                const SizedBox(height: 16),
                if (_pendingPhoto != null) ...[
                  _SelectedPhotoPreview(
                    photo: _pendingPhoto!,
                    isSpanish: _isSpanish,
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _captureAndPreviewPhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      _pendingPhoto == null
                          ? (_isSpanish ? 'Hacer foto' : 'Take photo')
                          : (_isSpanish ? 'Repetir foto' : 'Retake photo'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickAndPreviewPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _isSpanish ? 'Elegir de galeria' : 'Choose from gallery',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSpanish
                      ? 'Podras corregir ingredientes antes de guardar.'
                      : 'You will be able to correct ingredients before saving.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                if (_pendingPhoto != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isLoading ? null : _confirmAndInterpretPendingPhoto,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        _isSpanish ? 'Usar esta foto' : 'Use this photo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _pendingPhoto = null;
                            });
                          },
                    child: Text(
                      _isSpanish ? 'Quitar foto' : 'Remove photo',
                    ),
                  ),
                ],
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
              if (_loadingPreviewBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.memory(
                      _loadingPreviewBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
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
                _loadingStatus ?? '',
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
              if (kDebugMode && _loadingDebugStats != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSpanish
                            ? 'Diagnostico IA foto'
                            : 'Photo AI diagnostics',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Original' : 'Original',
                        value: _formatBytes(_loadingDebugStats!.originalBytes),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Preparada' : 'Prepared',
                        value: _formatBytes(_loadingDebugStats!.preparedBytes),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Preparar' : 'Prepare',
                        value: _formatMs(_loadingDebugStats!.prepareMs),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Remoto' : 'Remote',
                        value: _formatMs(_loadingDebugStats!.remoteMs),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Edge' : 'Edge',
                        value: _formatMs(_loadingDebugStats!.remoteEdgeMs),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Gemini' : 'Gemini',
                        value: _formatMs(_loadingDebugStats!.remoteGeminiMs),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Intentos' : 'Attempts',
                        value: _formatInt(_loadingDebugStats!.modelAttempts),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Fallback' : 'Fallback',
                        value: _formatBool(
                          _loadingDebugStats!.fallbackUsed,
                          isSpanish: _isSpanish,
                        ),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Personalizar' : 'Personalize',
                        value: _formatMs(_loadingDebugStats!.personalizeMs),
                      ),
                      _DebugMetricRow(
                        label: _isSpanish ? 'Total' : 'Total',
                        value: _formatMs(_loadingDebugStats!.totalMs),
                      ),
                    ],
                  ),
                ),
              ],
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
                            ? 'La IA prepara un borrador. Tu podras revisar, corregir o borrar ingredientes antes de guardar.'
                            : 'AI is preparing a draft. You will be able to review, edit, or remove ingredients before saving.',
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

  Future<void> _captureAndPreviewPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (picked == null) return;
    await _setPendingPhoto(
      fileName: picked.name.isEmpty ? 'captured.jpg' : picked.name,
      filePath: picked.path,
      bytes: await picked.readAsBytes(),
    );
  }

  Future<void> _pickAndPreviewPhoto() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      return;
    }
    await _setPendingPhoto(
      fileName: file.name,
      filePath: file.path,
      bytes: bytes,
    );
  }

  Future<void> _setPendingPhoto({
    required String fileName,
    required String? filePath,
    required Uint8List bytes,
  }) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingPhoto = _SelectedMealPhoto(
        fileName: fileName,
        filePath: filePath,
        bytes: bytes,
      );
    });
  }

  Future<void> _confirmAndInterpretPendingPhoto() async {
    final photo = _pendingPhoto;
    if (photo == null) {
      return;
    }
    await _interpretPickedFile(
      fileName: photo.fileName,
      filePath: photo.filePath,
      bytes: photo.bytes,
    );
  }

  Future<void> _interpretPickedFile({
    required String fileName,
    required String? filePath,
    required Uint8List bytes,
  }) async {
    setState(() {
      _loadingStatus = _isSpanish
          ? 'Abriendo analisis por foto...'
          : 'Opening photo analysis...';
      _loadingPreviewBytes = bytes;
      _loadingDebugStats = null;
    });
    await WidgetsBinding.instance.endOfFrame;

    final access = await AiUsageGate.ensureAccess(
      context,
      placement: PaywallPlacement.aiPhoto,
    );
    if (!access.allowed) {
      if (mounted) {
        setState(() {
          _loadingStatus = null;
          _loadingPreviewBytes = null;
          _loadingDebugStats = null;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loadingStatus = S.of(context).aiStatusPreparing;
        });
      }
      await WidgetsBinding.instance.endOfFrame;

      final totalStopwatch = Stopwatch()..start();
      final prepareStopwatch = Stopwatch()..start();
      final preparedImage = _prepareImageForUpload(
        imageBytes: bytes,
        fileName: fileName,
      );
      prepareStopwatch.stop();
      var debugStats = _PhotoAiDebugStats(
        originalBytes: bytes.lengthInBytes,
        preparedBytes: preparedImage.bytes.lengthInBytes,
        prepareMs: prepareStopwatch.elapsedMilliseconds,
      );
      if (mounted) {
        setState(() {
          _loadingDebugStats = debugStats;
        });
      }
      _logPhotoStage(
        'prepare',
        'original=${_formatBytes(bytes.lengthInBytes)} prepared=${_formatBytes(preparedImage.bytes.lengthInBytes)} elapsed=${prepareStopwatch.elapsedMilliseconds}ms',
      );

      setState(() {
        _loadingStatus = S.of(context).aiStatusConsulting;
      });

      final config = await locator<GetConfigUsecase>().getConfig();
      final personalizationContext =
          await locator<MealInterpretationPersonalizationUsecase>()
              .buildContext(
        intakeType: _args.intakeTypeEntity,
      );
      final remoteStopwatch = Stopwatch()..start();
      final remoteResult = await locator<InterpretMealFromPhotoUsecase>()
          .interpretWithDiagnostics(
        imageBytes: preparedImage.bytes,
        fileName: preparedImage.fileName,
        mimeType: preparedImage.mimeType,
        locale: _appLocaleTag(context),
        unitSystem: config.usesImperialUnits ? 'imperial' : 'metric',
        mealTypeHint: _args.intakeTypeEntity.name,
        analysisContext: personalizationContext.promptContext,
        personalExamples: personalizationContext.remoteExamples,
      );
      final draft = remoteResult.draft;
      remoteStopwatch.stop();
      debugStats = debugStats.copyWith(
        remoteMs: remoteStopwatch.elapsedMilliseconds,
        remoteEdgeMs: remoteResult.diagnostics?.edgeTotalMs,
        remoteGeminiMs: remoteResult.diagnostics?.geminiFetchMs,
        modelAttempts: remoteResult.diagnostics?.modelAttempts,
        fallbackUsed: remoteResult.diagnostics?.fallbackUsed,
      );
      if (mounted) {
        setState(() {
          _loadingDebugStats = debugStats;
        });
      }
      _logPhotoStage(
        'remote',
        'elapsed=${remoteStopwatch.elapsedMilliseconds}ms payload=${_formatBytes(preparedImage.bytes.lengthInBytes)}',
      );
      setState(() {
        _loadingStatus = S.of(context).aiStatusPersonalizing;
      });

      final personalizeStopwatch = Stopwatch()..start();
      final personalizedDraft =
          await locator<MealInterpretationPersonalizationUsecase>()
              .personalizeDraft(
        draft: draft,
        intakeType: _args.intakeTypeEntity,
        context: personalizationContext,
      );
      personalizeStopwatch.stop();
      totalStopwatch.stop();
      debugStats = debugStats.copyWith(
        personalizeMs: personalizeStopwatch.elapsedMilliseconds,
        totalMs: totalStopwatch.elapsedMilliseconds,
      );
      if (mounted) {
        setState(() {
          _loadingDebugStats = debugStats;
        });
      }
      _logPhotoStage(
        'personalize',
        'elapsed=${personalizeStopwatch.elapsedMilliseconds}ms total=${totalStopwatch.elapsedMilliseconds}ms',
      );
      final updatedDraft = personalizedDraft.copyWith(localImagePath: filePath);
      await locator<SaveInterpretationDraftUsecase>().saveDraft(updatedDraft);

      if (mounted) {
        Navigator.of(context).pushNamed(
          NavigationOptions.mealInterpretationReviewRoute,
          arguments: MealInterpretationReviewScreenArguments(
            updatedDraft.id,
            _args.day,
            _args.intakeTypeEntity,
            photoOriginalBytes: debugStats.originalBytes,
            photoPreparedBytes: debugStats.preparedBytes,
            photoPrepareMs: debugStats.prepareMs,
            photoRemoteMs: debugStats.remoteMs,
            photoRemoteEdgeMs: debugStats.remoteEdgeMs,
            photoRemoteGeminiMs: debugStats.remoteGeminiMs,
            photoModelAttempts: debugStats.modelAttempts,
            photoFallbackUsed: debugStats.fallbackUsed,
            photoPersonalizeMs: debugStats.personalizeMs,
            photoTotalMs: debugStats.totalMs,
          ),
        );
      }
    } on MealInterpretationRemoteException catch (exception) {
      if (mounted) {
        await _showAiFailureDialog(
          message: _buildRemoteFailureMessage(exception),
          onRetry: () => _interpretPickedFile(
            fileName: fileName,
            filePath: filePath,
            bytes: bytes,
          ),
          onContinueManually: () =>
              _createLocalDraft(imagePath: filePath, fileName: fileName),
        );
      }
    } catch (exception) {
      if (mounted) {
        await _showAiFailureDialog(
          message: _buildRemoteFailureMessage(exception),
          onRetry: () => _interpretPickedFile(
            fileName: fileName,
            filePath: filePath,
            bytes: bytes,
          ),
          onContinueManually: () =>
              _createLocalDraft(imagePath: filePath, fileName: fileName),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStatus = null;
          _loadingPreviewBytes = null;
        });
      }
    }
  }

  String _appLocaleTag(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}-$countryCode';
  }

  _PreparedUploadImage _prepareImageForUpload({
    required Uint8List imageBytes,
    required String fileName,
  }) {
    final extension = _fileExtension(fileName);
    final decoded = img.decodeImage(imageBytes);

    if (decoded == null) {
      return _PreparedUploadImage(
        bytes: imageBytes,
        fileName: fileName,
        mimeType: _mimeTypeForExtension(extension),
      );
    }

    final shouldResize = decoded.width > _maxImageDimension ||
        decoded.height > _maxImageDimension;

    final resized = shouldResize
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? _maxImageDimension : null,
            height: decoded.height > decoded.width ? _maxImageDimension : null,
            interpolation: img.Interpolation.cubic,
          )
        : decoded;

    var encoded = Uint8List.fromList(
      img.encodeJpg(resized, quality: _primaryJpegQuality),
    );
    if (encoded.lengthInBytes > _maxUploadBytes) {
      final fallbackResized = resized.width > _fallbackMaxImageDimension ||
              resized.height > _fallbackMaxImageDimension
          ? img.copyResize(
              resized,
              width: resized.width >= resized.height
                  ? _fallbackMaxImageDimension
                  : null,
              height: resized.height > resized.width
                  ? _fallbackMaxImageDimension
                  : null,
              interpolation: img.Interpolation.average,
            )
          : resized;
      encoded = Uint8List.fromList(
        img.encodeJpg(fallbackResized, quality: _fallbackJpegQuality),
      );
    }
    return _PreparedUploadImage(
      bytes: encoded,
      fileName: _replaceExtension(fileName, 'jpg'),
      mimeType: 'image/jpeg',
    );
  }

  void _logPhotoStage(String stage, String message) {
    debugPrint('[MealPhotoAI][$stage] $message');
  }

  String _formatBytes(int bytes) {
    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(0)}KB';
    }
    final megabytes = kilobytes / 1024;
    return '${megabytes.toStringAsFixed(2)}MB';
  }

  String _formatMs(int? milliseconds) {
    if (milliseconds == null) {
      return '--';
    }
    if (milliseconds < 1000) {
      return '${milliseconds}ms';
    }
    return '${(milliseconds / 1000).toStringAsFixed(1)}s';
  }

  String _formatInt(int? value) => value?.toString() ?? '--';

  String _formatBool(bool? value, {required bool isSpanish}) {
    if (value == null) {
      return '--';
    }
    if (isSpanish) {
      return value ? 'Si' : 'No';
    }
    return value ? 'Yes' : 'No';
  }

  String _buildRemoteFailureMessage(Object error) {
    if (error is MealInterpretationRemoteException) {
      switch (error.category) {
        case MealInterpretationFailureCategory.timeout:
          return _isSpanish
              ? 'La petición de IA tardó demasiado. Reintenta o sigue con revisión manual.'
              : 'The AI request timed out. Retry or continue with a manual review.';
        case MealInterpretationFailureCategory.noNetwork:
          return _isSpanish
              ? 'No hay conexión. Reintenta cuando vuelvas a tener red o sigue con revisión manual.'
              : 'No network connection. Retry when you are back online or continue with a manual review.';
        case MealInterpretationFailureCategory.authInvalid:
          return _isSpanish
              ? 'La sesión cloud ya no es válida. Vuelve a abrir o proteger tu cuenta y reintenta.'
              : 'Your cloud session is no longer valid. Reopen or protect your cloud account and retry.';
        case MealInterpretationFailureCategory.invalidResponse:
          return _isSpanish
              ? 'La respuesta de IA no se pudo usar. Reintenta o sigue con borrador manual.'
              : 'The AI response could not be used. Retry or continue with a manual draft.';
        case MealInterpretationFailureCategory.unavailable:
          return _isSpanish
              ? 'La interpretación por IA no está disponible temporalmente. Reintenta o sigue manual.'
              : 'AI meal interpretation is temporarily unavailable. Retry or continue manually.';
      }
    }

    final normalized = _extractBackendError(error.toString()).toLowerCase();
    if (normalized.contains('payload is too large') ||
        normalized.contains('413')) {
      return S.current.aiErrorPayloadTooLarge;
    }
    if (normalized.contains('missing gemini_api_key')) {
      return S.current.aiErrorMissingKey;
    }
    if (normalized.contains('429') ||
        normalized.contains('resource_exhausted') ||
        normalized.contains('quota')) {
      return S.current.aiErrorQuotaExceeded;
    }
    if (normalized.contains('mime') ||
        normalized.contains('unsupported') ||
        normalized.contains('invalid argument')) {
      return S.current.aiErrorUnsupportedFormat;
    }
    return S.current.aiErrorGeneric;
  }

  bool get _isSpanish => Localizations.localeOf(context).languageCode == 'es';

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
            child: Text(_isSpanish ? 'Seguir manual' : 'Continue manually'),
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

  String _fileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) {
      return '';
    }
    return parts.last.toLowerCase();
  }

  String _replaceExtension(String fileName, String extension) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) {
      return '$fileName.$extension';
    }
    return '${fileName.substring(0, lastDot)}.$extension';
  }

  String _mimeTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String _extractBackendError(String rawError) {
    final jsonStart = rawError.indexOf('{');
    if (jsonStart == -1) {
      return rawError;
    }

    final possibleJson = rawError.substring(jsonStart);
    try {
      final decoded = jsonDecode(possibleJson);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Keep raw error when payload is not valid JSON.
    }
    return rawError;
  }

  Future<void> _createLocalDraft({
    String? imagePath,
    required String fileName,
  }) async {
    final draft = await locator<MealInterpretationPersonalizationUsecase>()
        .buildFallbackDraft(
      sourceType: DraftSourceEntity.photo,
      title: S.current.aiReviewDraftTitle,
      intakeType: _args.intakeTypeEntity,
      inputText: fileName,
      localImagePath: imagePath,
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

class _PreparedUploadImage {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  const _PreparedUploadImage({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
}

class _PhotoAiDebugStats {
  final int originalBytes;
  final int preparedBytes;
  final int prepareMs;
  final int? remoteMs;
  final int? remoteEdgeMs;
  final int? remoteGeminiMs;
  final int? modelAttempts;
  final bool? fallbackUsed;
  final int? personalizeMs;
  final int? totalMs;

  const _PhotoAiDebugStats({
    required this.originalBytes,
    required this.preparedBytes,
    required this.prepareMs,
    this.remoteMs,
    this.remoteEdgeMs,
    this.remoteGeminiMs,
    this.modelAttempts,
    this.fallbackUsed,
    this.personalizeMs,
    this.totalMs,
  });

  _PhotoAiDebugStats copyWith({
    int? originalBytes,
    int? preparedBytes,
    int? prepareMs,
    int? remoteMs,
    int? remoteEdgeMs,
    int? remoteGeminiMs,
    int? modelAttempts,
    bool? fallbackUsed,
    int? personalizeMs,
    int? totalMs,
  }) {
    return _PhotoAiDebugStats(
      originalBytes: originalBytes ?? this.originalBytes,
      preparedBytes: preparedBytes ?? this.preparedBytes,
      prepareMs: prepareMs ?? this.prepareMs,
      remoteMs: remoteMs ?? this.remoteMs,
      remoteEdgeMs: remoteEdgeMs ?? this.remoteEdgeMs,
      remoteGeminiMs: remoteGeminiMs ?? this.remoteGeminiMs,
      modelAttempts: modelAttempts ?? this.modelAttempts,
      fallbackUsed: fallbackUsed ?? this.fallbackUsed,
      personalizeMs: personalizeMs ?? this.personalizeMs,
      totalMs: totalMs ?? this.totalMs,
    );
  }
}

class _DebugMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _DebugMetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMealPhoto {
  final String fileName;
  final String? filePath;
  final Uint8List bytes;

  const _SelectedMealPhoto({
    required this.fileName,
    required this.filePath,
    required this.bytes,
  });
}

class MealPhotoCaptureScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  MealPhotoCaptureScreenArguments(this.day, this.intakeTypeEntity);
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

class _SelectedPhotoPreview extends StatelessWidget {
  final _SelectedMealPhoto photo;
  final bool isSpanish;

  const _SelectedPhotoPreview({
    required this.photo,
    required this.isSpanish,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Image.memory(
                  photo.bytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSpanish ? 'Vista previa' : 'Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              isSpanish
                  ? 'Confirma que la foto se ve bien antes de enviarla a IA.'
                  : 'Confirm the photo looks good before sending it to AI.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
