import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_photo_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';
import 'package:macrotracker/generated/l10n.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  late Directory tempDir;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;
  late _FakeMealInterpretationPersonalizationUsecase fakePersonalizationUsecase;
  late _FakeInterpretMealFromPhotoUsecase fakeInterpretUsecase;
  late _FakeSaveInterpretationDraftUsecase fakeSaveUsecase;
  late _FakeMonetizationService fakeMonetizationService;
  late _FakeConversionAnalyticsService fakeAnalyticsService;
  late _FakeFilePicker fakeFilePicker;
  late _FakeImagePickerPlatform fakeImagePickerPlatform;

  MealInterpretationReviewScreenArguments? navigatedArguments;

  setUp(() async {
    await locator.reset();
    tempDir = await Directory.systemTemp.createTemp('macrotracker_photo_test_');
    Hive.init(tempDir.path);

    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    fakePersonalizationUsecase =
        _FakeMealInterpretationPersonalizationUsecase();
    fakeInterpretUsecase = _FakeInterpretMealFromPhotoUsecase();
    fakeSaveUsecase = _FakeSaveInterpretationDraftUsecase();
    fakeMonetizationService = _FakeMonetizationService();
    fakeAnalyticsService = _FakeConversionAnalyticsService();

    fakeFilePicker = _FakeFilePicker();
    FilePicker.platform = fakeFilePicker;

    fakeImagePickerPlatform = _FakeImagePickerPlatform();
    ImagePickerPlatform.instance = fakeImagePickerPlatform;

    locator.registerSingleton<GetConfigUsecase>(fakeGetConfigUsecase);
    locator.registerSingleton<MealInterpretationPersonalizationUsecase>(
        fakePersonalizationUsecase);
    locator
        .registerSingleton<InterpretMealFromPhotoUsecase>(fakeInterpretUsecase);
    locator.registerSingleton<SaveInterpretationDraftUsecase>(fakeSaveUsecase);
    locator.registerSingleton<MonetizationService>(fakeMonetizationService);
    locator.registerSingleton<ConversionAnalyticsService>(fakeAnalyticsService);

    navigatedArguments = null;
  });

  tearDown(() async {
    await locator.reset();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  Widget createTestWidget() {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      onGenerateRoute: (settings) {
        if (settings.name == NavigationOptions.mealInterpretationReviewRoute) {
          navigatedArguments =
              settings.arguments as MealInterpretationReviewScreenArguments?;
          return MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: Text('Review Screen Mock')),
          );
        }
        return MaterialPageRoute(
          settings: RouteSettings(
            arguments: MealPhotoCaptureScreenArguments(
              DateTime(2026, 6, 15),
              IntakeTypeEntity.breakfast,
            ),
          ),
          builder: (context) => const MealPhotoCaptureScreen(),
        );
      },
    );
  }

  InterpretationDraftEntity buildDummyDraft({
    required String id,
    required String title,
  }) {
    return InterpretationDraftEntity(
      id: id,
      sourceType: DraftSourceEntity.photo,
      inputText: 'captured.jpg',
      localImagePath: '/path/to/mock_image.jpg',
      title: title,
      summary: 'A simple breakfast draft',
      totalKcal: 250,
      totalCarbs: 27,
      totalFat: 10,
      totalProtein: 14,
      totalFiber: 3,
      totalSugar: 12,
      confidenceBand: ConfidenceBandEntity.high,
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      items: [
        InterpretationDraftItemEntity(
          id: 'item-1',
          label: 'Eggs',
          matchedMealSnapshot: null,
          amount: 2,
          unit: 'serving',
          kcal: 150,
          carbs: 1,
          fat: 10,
          protein: 12,
          fiber: 0,
          sugar: 0,
          confidenceBand: ConfidenceBandEntity.high,
          editable: true,
          removed: false,
        ),
      ],
    );
  }

  testWidgets(
      'renders introductory state and recommendation hints expansion tile',
      (tester) async {
    // Expand viewport to avoid overflow or layout issues
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text(S.current.aiMealPhotoTitle), findsOneWidget);
    expect(find.text(S.current.aiPhotoTakePhoto), findsOneWidget);
    expect(find.text(S.current.aiPhotoChooseGallery), findsOneWidget);

    // Verify recommendation hints tile
    final hintTile = find.text(S.current.aiHintRecommendations);
    expect(hintTile, findsOneWidget);

    // Tap to expand hints
    await tester.tap(hintTile);
    await tester.pumpAndSettle();

    // Verify hints are expanded and visible
    expect(find.text(S.current.aiHintShowFullPlateTitle), findsOneWidget);
    expect(find.text(S.current.aiHintCheckSaucesTitle), findsOneWidget);
  });

  testWidgets(
      'captures image from camera, shows preview, and confirms interpretation',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    // Write a mock file to disk
    final mockFile = File('${tempDir.path}/captured.jpg');
    final realBytes =
        File('assets/icon/macrotracker_logo_square.png').readAsBytesSync();
    mockFile.writeAsBytesSync(realBytes);

    fakeImagePickerPlatform.pickedPath = mockFile.path;
    fakeImagePickerPlatform.pickedBytes = realBytes;

    // Setup usecases
    final draft = buildDummyDraft(id: 'draft-abc', title: 'Comida Foto 1');
    fakeInterpretUsecase.result = MealInterpretationRemoteResult(
      draft: draft,
      estimatedCostUsd: 0.01,
      diagnostics: null,
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap "Hacer foto"
    await tester.tap(find.text(S.current.aiPhotoTakePhoto));
    await tester.pump();
    await tester.pumpAndSettle();

    // Preview should show up
    expect(find.text(S.current.aiPhotoCaptured), findsOneWidget);
    expect(find.text(S.current.aiPhotoUseThisPhoto), findsOneWidget);
    expect(find.text(S.current.aiPhotoRemovePhoto), findsOneWidget);

    // Tap "Usar esta foto"
    await tester.tap(find.text(S.current.aiPhotoUseThisPhoto));
    await tester.pump(); // Start loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(); // first endOfFrame (Opening photo analysis)
    await tester.pump(); // second endOfFrame (Preparing)
    await tester.pump(); // third endOfFrame (Personalizing)
    await tester.pumpAndSettle(); // route transition

    // Should have saved the draft
    expect(fakeSaveUsecase.savedDraft, isNotNull);
    expect(fakeSaveUsecase.savedDraft!.id, equals('draft-abc'));

    // Should have navigated to review route with arguments
    expect(navigatedArguments, isNotNull);
    expect(navigatedArguments!.draftId, equals('draft-abc'));
  });

  testWidgets('picks image from gallery, shows preview, and removes it',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    // Set picked file on fake picker
    final realBytes =
        File('assets/icon/macrotracker_logo_square.png').readAsBytesSync();
    fakeFilePicker.pickedPath = '${tempDir.path}/gallery.png';
    fakeFilePicker.pickedBytes = realBytes;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap "Elegir de galeria"
    await tester.tap(find.text(S.current.aiPhotoChooseGallery));
    await tester.pumpAndSettle();

    // Preview should show up
    expect(find.text(S.current.aiPhotoCaptured), findsOneWidget);

    // Tap "Quitar foto"
    await tester.tap(find.text(S.current.aiPhotoRemovePhoto));
    await tester.pumpAndSettle();

    // Preview should be gone
    expect(find.text(S.current.aiPhotoCaptured), findsNothing);
  });

  testWidgets(
      'handles AI timeout exception, shows failure dialog, and continues manually',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final mockFile = File('${tempDir.path}/captured.jpg');
    final realBytes =
        File('assets/icon/macrotracker_logo_square.png').readAsBytesSync();
    mockFile.writeAsBytesSync(realBytes);

    fakeImagePickerPlatform.pickedPath = mockFile.path;
    fakeImagePickerPlatform.pickedBytes = realBytes;

    // Stub to throw timeout exception
    fakeInterpretUsecase.shouldThrow = const MealInterpretationRemoteException(
      category: MealInterpretationFailureCategory.timeout,
    );

    // Stub personalization fallback
    final fallbackDraft =
        buildDummyDraft(id: 'fallback-123', title: 'Borrador de comida');
    fakePersonalizationUsecase.fallbackDraft = fallbackDraft;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.current.aiPhotoTakePhoto));
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.current.aiPhotoUseThisPhoto));
    await tester.pump(); // first endOfFrame (Opening photo analysis)
    await tester.pump(); // second endOfFrame (Preparing)
    await tester.pump(); // wait for remote exception and catch block
    await tester.pump(
        const Duration(milliseconds: 500)); // settle the alert dialog animation

    // Verify AI Unavailable Dialog is shown
    expect(find.text(S.current.aiUnavailableTitle), findsOneWidget);
    expect(
        find.text(
            'La petición de IA tardó demasiado. Reintenta o sigue con revisión manual.'),
        findsOneWidget);

    // Tap "Seguir manual"
    await tester.tap(find.text(S.current.aiContinueManually));
    await tester.pumpAndSettle();

    // Verify fallback draft was saved and navigated
    expect(fakeSaveUsecase.savedDraft, isNotNull);
    expect(fakeSaveUsecase.savedDraft!.id, equals('fallback-123'));
    expect(navigatedArguments, isNotNull);
    expect(navigatedArguments!.draftId, equals('fallback-123'));
  });

  testWidgets(
      'handles AI network exception, shows failure dialog, and retries successfully',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final mockFile = File('${tempDir.path}/captured.jpg');
    final realBytes =
        File('assets/icon/macrotracker_logo_square.png').readAsBytesSync();
    mockFile.writeAsBytesSync(realBytes);

    fakeImagePickerPlatform.pickedPath = mockFile.path;
    fakeImagePickerPlatform.pickedBytes = realBytes;

    // First throw no network
    fakeInterpretUsecase.shouldThrow = const MealInterpretationRemoteException(
      category: MealInterpretationFailureCategory.noNetwork,
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.current.aiPhotoTakePhoto));
    await tester.pumpAndSettle();

    await tester.tap(find.text(S.current.aiPhotoUseThisPhoto));
    await tester.pump(); // first endOfFrame (Opening photo analysis)
    await tester.pump(); // second endOfFrame (Preparing)
    await tester.pump(); // wait for remote exception and catch block
    await tester.pump(
        const Duration(milliseconds: 500)); // settle the alert dialog animation

    // Dialog shown
    expect(find.text(S.current.aiUnavailableTitle), findsOneWidget);
    expect(
        find.text(
            'No hay conexión. Reintenta cuando vuelvas a tener red o sigue con revisión manual.'),
        findsOneWidget);

    // Now make retry succeed
    fakeInterpretUsecase.shouldThrow = null;
    final draft = buildDummyDraft(id: 'retry-success', title: 'Comida retry');
    fakeInterpretUsecase.result = MealInterpretationRemoteResult(
      draft: draft,
      estimatedCostUsd: 0.01,
      diagnostics: null,
    );

    // Tap "Reintentar"
    await tester.tap(find.text(S.current.aiRetry));
    await tester.pump(); // first endOfFrame (Opening photo analysis)
    await tester.pump(); // second endOfFrame (Preparing)
    await tester.pump(); // third endOfFrame (Personalizing)
    await tester.pumpAndSettle(); // route transition

    // Navigation succeeds
    expect(navigatedArguments, isNotNull);
    expect(navigatedArguments!.draftId, equals('retry-success'));
  });
}

class _FakeGetConfigUsecase extends Fake implements GetConfigUsecase {
  @override
  Future<ConfigEntity> getConfig() async {
    return const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      macroGoalMode: MacroGoalModeEntity.percentage,
      dailyFocus: DailyFocusEntity.upperBody,
      trainingDayTemplate: TrainingDayTemplateEntity.rest,
    );
  }
}

class _FakeMealInterpretationPersonalizationUsecase extends Fake
    implements MealInterpretationPersonalizationUsecase {
  InterpretationDraftEntity? fallbackDraft;

  @override
  Future<MealInterpretationPersonalizationContext> buildContext({
    required IntakeTypeEntity intakeType,
    String? freeText,
  }) async {
    return const MealInterpretationPersonalizationContext(
      promptContext: 'mock prompt context',
      remoteExamples: [],
      candidates: [],
    );
  }

  @override
  Future<InterpretationDraftEntity> personalizeDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
    MealInterpretationPersonalizationContext? context,
  }) async {
    return draft;
  }

  @override
  Future<InterpretationDraftEntity> buildFallbackDraft({
    required DraftSourceEntity sourceType,
    required String title,
    required IntakeTypeEntity intakeType,
    String? inputText,
    String? localImagePath,
  }) async {
    return fallbackDraft ??
        InterpretationDraftEntity(
          id: 'fallback-id',
          sourceType: sourceType,
          inputText: inputText,
          localImagePath: localImagePath,
          title: title,
          summary: 'Fallback description',
          totalKcal: 0,
          totalCarbs: 0,
          totalFat: 0,
          totalProtein: 0,
          confidenceBand: ConfidenceBandEntity.low,
          status: DraftStatusEntity.ready,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
          items: [],
        );
  }
}

class _FakeInterpretMealFromPhotoUsecase extends Fake
    implements InterpretMealFromPhotoUsecase {
  MealInterpretationRemoteResult? result;
  Object? shouldThrow;

  @override
  Future<MealInterpretationRemoteResult> interpretWithDiagnostics({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    if (shouldThrow != null) {
      throw shouldThrow!;
    }
    return result!;
  }
}

class _FakeSaveInterpretationDraftUsecase extends Fake
    implements SaveInterpretationDraftUsecase {
  InterpretationDraftEntity? savedDraft;

  @override
  Future<void> saveDraft(InterpretationDraftEntity draft) async {
    savedDraft = draft;
  }
}

class _FakeMonetizationService extends Fake implements MonetizationService {
  @override
  AiTrialState? get cachedTrialState => const AiTrialState(
        isPremium: true,
        used: 0,
        limit: 5,
        fullLimit: 5,
        aiMealsSaved: 0,
      );

  @override
  Future<AiTrialState> getAiTrialState() async {
    return const AiTrialState(
      isPremium: true,
      used: 0,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );
  }
}

class _FakeConversionAnalyticsService extends Fake
    implements ConversionAnalyticsService {
  @override
  Future<void> logEvent(String name,
      {Map<String, dynamic>? parameters}) async {}

  @override
  Future<void> logAiInterpretationStarted({required String inputType}) async {}

  @override
  Future<void> logAiInterpretationCompleted({
    required String inputType,
    int? remoteMs,
    int? edgeMs,
    int? geminiMs,
    int? modelAttempts,
    bool? fallbackUsed,
  }) async {}

  @override
  Future<void> logAiInterpretationFailed({
    required String inputType,
    required String category,
  }) async {}
}

class _FakeFilePicker extends FilePicker {
  String? pickedPath;
  Uint8List? pickedBytes;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    int? compressionQuality,
  }) async {
    final path = pickedPath;
    if (path == null) return null;
    return FilePickerResult([
      PlatformFile(
        path: path,
        name: 'gallery.png',
        size: pickedBytes?.length ?? 100,
        bytes: pickedBytes,
      )
    ]);
  }
}

class _FakeImagePickerPlatform extends ImagePickerPlatform {
  String? pickedPath;
  Uint8List? pickedBytes;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final path = pickedPath;
    final bytes = pickedBytes;
    if (path == null || bytes == null) return null;
    return XFile.fromData(bytes, path: path);
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final path = pickedPath;
    final bytes = pickedBytes;
    if (path == null || bytes == null) return null;
    return XFile.fromData(bytes, path: path);
  }
}
