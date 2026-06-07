import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/data_source/user_data_source.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/presentation/main_screen.dart';
import 'package:macrotracker/core/presentation/widgets/image_full_screen.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/meal_reminder_service.dart';
import 'package:macrotracker/core/styles/color_schemes.dart';
import 'package:macrotracker/core/styles/fonts.dart';
import 'package:macrotracker/core/utils/env.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/logger_config.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/core/utils/theme_mode_provider.dart';
import 'package:macrotracker/features/activity_detail/activity_detail_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:macrotracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:macrotracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:macrotracker/features/body_progress/presentation/body_progress_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';
import 'package:macrotracker/features/onboarding/onboarding_screen.dart';
import 'package:macrotracker/features/professional_plan/presentation/professional_plan_screen.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_editor_screen.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';
import 'package:macrotracker/features/settings/settings_screen.dart';
import 'package:macrotracker/features/settings/data/services/android_drive_backup_scheduler.dart';
import 'package:macrotracker/features/weekly_insights/presentation/weekly_insights_screen.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final _defaultReleaseSentryTraceSampleRate = double.tryParse(
      const String.fromEnvironment(
        'SENTRY_TRACE_SAMPLE_RATE',
        defaultValue: '0.05',
      ),
    ) ??
    0.05;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerConfig.intiLogger();
  try {
    await initLocator();
    final log = Logger('main');
    final isUserInitialized = await locator<UserDataSource>().hasUserData();
    final configRepo = locator<ConfigRepository>();
    final hasAcceptedAnonymousData =
        await configRepo.getConfigHasAcceptedAnonymousData();
    await locator<ConversionAnalyticsService>().initializeFromConsent();
    final savedAppTheme = await configRepo.getConfigAppTheme();
    final savedLocale = await configRepo.getConfigLocale();
    final locale = savedLocale != null ? Locale(savedLocale) : null;

    // If the user has accepted anonymous data collection, run the app with
    // sentry enabled, else run without it
    if (kReleaseMode && hasAcceptedAnonymousData) {
      log.info('Starting App with Sentry enabled ...');
      await _runAppWithSentryReporting(
          isUserInitialized, savedAppTheme, locale);
    } else {
      log.info('Starting App ...');
      runAppWithChangeNotifiers(isUserInitialized, savedAppTheme, locale);
    }
    unawaited(_runDeferredStartupTasks());
  } catch (e, stackTrace) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'FATAL ERROR ON STARTUP:\n\n$e\n\n$stackTrace',
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _runDeferredStartupTasks() async {
  final log = Logger('main');
  await Future<void>.delayed(const Duration(milliseconds: 600));

  try {
    await initializeDriveBackupWorker();
  } catch (error, stackTrace) {
    log.warning(
      'Google Drive background worker initialization failed',
      error,
      stackTrace,
    );
  }

  try {
    final config = await locator<ConfigRepository>().getConfig();
    await locator<AndroidDriveBackupScheduler>()
        .syncFromConfig(config.googleDriveAutoBackupEnabled);
  } catch (error, stackTrace) {
    log.warning('Google Drive backup scheduler sync failed', error, stackTrace);
  }

  try {
    await locator<MealReminderService>().syncFromConfig();
  } catch (error, stackTrace) {
    log.severe('Meal reminder startup sync failed', error, stackTrace);
  }
}

Future<void> _runAppWithSentryReporting(bool isUserInitialized,
    AppThemeEntity savedAppTheme, Locale? locale) async {
  try {
    await SentryFlutter.init((options) {
      options.dsn = Env.sentryDns.startsWith('http') ? Env.sentryDns : '';
      options.tracesSampleRate = _defaultReleaseSentryTraceSampleRate;
    },
        appRunner: () => runAppWithChangeNotifiers(
            isUserInitialized, savedAppTheme, locale));
  } catch (e, stackTrace) {
    Logger('main').severe('Failed to initialize Sentry', e, stackTrace);
    runAppWithChangeNotifiers(isUserInitialized, savedAppTheme, locale);
  }
}

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme, Locale? locale) =>
    runApp(ChangeNotifierProvider(
        create: (_) =>
            ThemeModeProvider(appTheme: savedAppTheme, locale: locale),
        child: MacroTrackerApp(userInitialized: userInitialized)));

class MacroTrackerApp extends StatelessWidget {
  final bool userInitialized;

  const MacroTrackerApp({super.key, required this.userInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(lightColorScheme),
      darkTheme: _buildTheme(darkColorScheme),
      themeMode: Provider.of<ThemeModeProvider>(context).themeMode,
      locale: Provider.of<ThemeModeProvider>(context).locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: userInitialized
          ? NavigationOptions.mainRoute
          : NavigationOptions.onboardingRoute,
      routes: {
        NavigationOptions.mainRoute: (context) => const MainScreen(),
        NavigationOptions.onboardingRoute: (context) =>
            const OnboardingScreen(),
        NavigationOptions.settingsRoute: (context) => const SettingsScreen(),
        NavigationOptions.addMealRoute: (context) => const AddMealScreen(),
        NavigationOptions.scannerRoute: (context) => const ScannerScreen(),
        NavigationOptions.mealDetailRoute: (context) =>
            const MealDetailScreen(),
        NavigationOptions.editMealRoute: (context) => const EditMealScreen(),
        NavigationOptions.addActivityRoute: (context) =>
            const AddActivityScreen(),
        NavigationOptions.activityDetailRoute: (context) =>
            const ActivityDetailScreen(),
        NavigationOptions.imageFullScreenRoute: (context) =>
            const ImageFullScreen(),
        NavigationOptions.mealTextCaptureRoute: (context) =>
            const MealTextCaptureScreen(),
        NavigationOptions.mealPhotoCaptureRoute: (context) =>
            const MealPhotoCaptureScreen(),
        NavigationOptions.mealInterpretationReviewRoute: (context) =>
            const MealInterpretationReviewScreen(),
        NavigationOptions.recipeLibraryRoute: (context) =>
            const RecipeLibraryScreen(),
        NavigationOptions.recipeEditorRoute: (context) =>
            const RecipeEditorScreen(),
        NavigationOptions.weeklyInsightsRoute: (context) =>
            const WeeklyInsightsScreen(),
        NavigationOptions.bodyProgressRoute: (context) =>
            const BodyProgressScreen(),
        NavigationOptions.professionalPlanRoute: (context) =>
            const ProfessionalPlanScreen(),
      },
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final scaffoldColor =
        isDark ? const Color(0xFF000000) : const Color(0xFFF7F8F3);
    final cardColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: appTextTheme,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colorScheme.outlineVariant
                .withValues(alpha: isDark ? 0.26 : 0.42),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF080808) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant;
          return appTextTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant;
          return IconThemeData(color: color);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: appTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.22)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.58),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.58),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          side: WidgetStatePropertyAll(
            BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.68),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary.withValues(alpha: 0.11);
            }
            return Colors.transparent;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest
            .withValues(alpha: isDark ? 0.30 : 0.45),
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
