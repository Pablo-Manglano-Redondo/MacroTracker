import 'dart:io';
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
                                S.of(context).aiPhotoReviewNotice,
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
                      S.of(context).aiPhotoHintSubtitle,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _captureAndPreviewPhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      S.of(context).aiPhotoTakePhoto,
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
                      S.of(context).aiPhotoChooseGallery,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).aiPhotoCorrectionHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
                S.of(context).aiCaptureProcessingTime,
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
                        S.of(context).aiCaptureDraftReviewNotice,
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
    final bytes = await picked.readAsBytes();
    await _interpretPickedFile(
      fileName: picked.name.isEmpty ? 'captured.jpg' : picked.name,
      filePath: picked.path,
      bytes: bytes,
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
    await _interpretPickedFile(
      fileName: file.name,
      filePath: file.path,
      bytes: bytes,
    );
  }

  Future<void> _interpretPickedFile({
    required String fileName,
    required String? filePath,
    required Uint8List bytes,
  }) async {
    final localizer = S.of(context);
    final localeTag = _appLocaleTag(context);
    final navigator = Navigator.of(context);

    setState(() {
      _loadingStatus = localizer.aiPhotoOpeningAnalysis;
      _loadingPreviewBytes = bytes;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final access = await AiUsageGate.ensureAccess(
      context,
      placement: PaywallPlacement.aiPhoto,
    );
    if (!access.allowed) {
      if (mounted) {
        setState(() {
          _loadingStatus = null;
          _loadingPreviewBytes = null;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loadingStatus = localizer.aiStatusPreparing;
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
      _logPhotoStage(
        'prepare',
        'original=${_formatBytes(bytes.lengthInBytes)} prepared=${_formatBytes(preparedImage.bytes.lengthInBytes)} elapsed=${prepareStopwatch.elapsedMilliseconds}ms',
      );

      setState(() {
        _loadingStatus = localizer.aiStatusConsulting;
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
        locale: localeTag,
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
      _logPhotoStage(
        'remote',
        'elapsed=${remoteStopwatch.elapsedMilliseconds}ms payload=${_formatBytes(preparedImage.bytes.lengthInBytes)}',
      );
      setState(() {
        _loadingStatus = localizer.aiStatusPersonalizing;
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
      _logPhotoStage(
        'personalize',
        'elapsed=${personalizeStopwatch.elapsedMilliseconds}ms total=${totalStopwatch.elapsedMilliseconds}ms',
      );
      final updatedDraft = personalizedDraft.copyWith(localImagePath: filePath);
      await locator<SaveInterpretationDraftUsecase>().saveDraft(updatedDraft);

      if (mounted) {
        navigator.pushNamed(
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

  String _buildRemoteFailureMessage(Object error) {
    if (error is MealInterpretationRemoteException) {
      switch (error.category) {
        case MealInterpretationFailureCategory.timeout:
          return S.current.aiFailureTimeoutManualReview;
        case MealInterpretationFailureCategory.noNetwork:
          return S.current.aiFailureNoNetworkManualReview;
        case MealInterpretationFailureCategory.authInvalid:
          return S.current.aiFailureCloudSessionInvalid;
        case MealInterpretationFailureCategory.invalidResponse:
          return S.current.aiFailureInvalidResponseManualDraft;
        case MealInterpretationFailureCategory.unavailable:
          return S.current.aiFailureUnavailableManual;
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

  Future<void> _showAiFailureDialog({
    required String message,
    required Future<void> Function() onRetry,
    required Future<void> Function() onContinueManually,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).aiUnavailableTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onContinueManually();
            },
            child: Text(S.of(context).aiContinueManually),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onRetry();
            },
            child: Text(S.of(context).aiRetry),
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


