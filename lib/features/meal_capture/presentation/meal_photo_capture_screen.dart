import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
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
  static const _maxUploadBytes = 4 * 1024 * 1024;
  static const _maxImageDimension = 1600;

  final ImagePicker _imagePicker = ImagePicker();
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
      appBar: AppBar(title: const Text('Comida por foto IA')),
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
                  'Registro por foto',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Importa una imagen de comida, revisa el borrador editable y guardalo en ${_args.intakeTypeEntity.name}.',
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
                      label: 'Elegir imagen',
                    ),
                    _CaptureStepChip(
                      icon: Icons.tune_outlined,
                      label: 'Revisar items',
                    ),
                    _CaptureStepChip(
                      icon: Icons.restaurant_outlined,
                      label: 'Guardar comida',
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
                    'Recomendaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const _CaptureHintRow(
                    icon: Icons.crop_free_outlined,
                    title: 'Muestra el plato completo',
                    subtitle:
                        'Mejor encuadre, mejor deteccion de ingredientes.',
                  ),
                  const SizedBox(height: 10),
                  const _CaptureHintRow(
                    icon: Icons.opacity_outlined,
                    title: 'Revisa salsas y aceites',
                    subtitle:
                        'El borrador es solo el primer paso. Corrige calorias ocultas.',
                  ),
                  const SizedBox(height: 10),
                  const _CaptureHintRow(
                    icon: Icons.fitness_center_outlined,
                    title: 'Pensado para comidas de gimnasio',
                    subtitle:
                        'Util para bowls, batidos, post entreno y comidas repetidas.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : _captureAndInterpretPhoto,
            icon: Icon(
              _isLoading ? Icons.hourglass_top_outlined : Icons.auto_awesome,
            ),
            label: Text(
              _isLoading ? 'Creando borrador IA...' : 'Hacer foto y revisar',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _isLoading ? null : _pickAndInterpretPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Elegir de galeria'),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: _isLoading ? null : _openTextFlow,
              icon: const Icon(Icons.notes_outlined),
              label: const Text('Usar texto'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndInterpretPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (picked == null) return;
    await _interpretPickedFile(
      fileName: picked.name.isEmpty ? 'captured.jpg' : picked.name,
      filePath: picked.path,
      bytes: await picked.readAsBytes(),
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
    setState(() {
      _isLoading = true;
    });

    try {
      final preparedImage = _prepareImageForUpload(
        imageBytes: bytes,
        fileName: fileName,
      );
      final config = await locator<GetConfigUsecase>().getConfig();
      final draft = await locator<InterpretMealFromPhotoUsecase>().interpret(
        imageBytes: preparedImage.bytes,
        fileName: preparedImage.fileName,
        mimeType: preparedImage.mimeType,
        locale: Platform.localeName,
        unitSystem: config.usesImperialUnits ? 'imperial' : 'metric',
        mealTypeHint: _args.intakeTypeEntity.name,
      );
      final updatedDraft = draft.copyWith(localImagePath: filePath);
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
    } catch (exception) {
      await _createLocalDraft(imagePath: filePath);
      if (mounted) {
        final message = _buildRemoteFailureMessage(exception.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
    final shouldCompress = imageBytes.lengthInBytes > _maxUploadBytes;

    if (!shouldResize && !shouldCompress) {
      return _PreparedUploadImage(
        bytes: imageBytes,
        fileName: fileName,
        mimeType: _mimeTypeForExtension(extension),
      );
    }

    final resized = shouldResize
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? _maxImageDimension : null,
            height: decoded.height > decoded.width ? _maxImageDimension : null,
            interpolation: img.Interpolation.cubic,
          )
        : decoded;

    final encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 84));
    return _PreparedUploadImage(
      bytes: encoded,
      fileName: _replaceExtension(fileName, 'jpg'),
      mimeType: 'image/jpeg',
    );
  }

  String _buildRemoteFailureMessage(String rawError) {
    final extractedError = _extractBackendError(rawError);
    final normalized = extractedError.toLowerCase();
    if (normalized.contains('payload is too large') ||
        normalized.contains('413')) {
      return 'La imagen es demasiado grande para IA remota. Se creo borrador local.';
    }
    if (normalized.contains('missing gemini_api_key')) {
      return 'La IA remota no esta configurada en backend. Se creo borrador local.';
    }
    if (normalized.contains('429') ||
        normalized.contains('resource_exhausted') ||
        normalized.contains('quota')) {
      return 'Se alcanzo limite de cuota/rate de IA remota. Se creo borrador local.';
    }
    if (normalized.contains('mime') ||
        normalized.contains('unsupported') ||
        normalized.contains('invalid argument')) {
      return 'Formato de imagen no soportado por IA remota. Prueba JPG/PNG. Se creo borrador local.';
    }
    return 'Fallo la interpretacion remota de imagen. Se creo borrador local. (${_truncateError(extractedError)})';
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

  String _truncateError(String error) {
    final compact = error.replaceAll('\n', ' ').trim();
    if (compact.length <= 90) {
      return compact;
    }
    return '${compact.substring(0, 87)}...';
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
      title: 'Borrador de comida por foto',
      summary: 'Borrador local de respaldo en flujo de imagen',
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
          label: 'Comida detectada',
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
