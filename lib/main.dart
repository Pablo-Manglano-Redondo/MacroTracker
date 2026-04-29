import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/data_source/user_data_source.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/presentation/main_screen.dart';
import 'package:macrotracker/core/presentation/widgets/image_full_screen.dart';
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
import 'package:macrotracker/features/recipes/presentation/recipe_editor_screen.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';
import 'package:macrotracker/features/settings/settings_screen.dart';
import 'package:macrotracker/features/weekly_insights/presentation/weekly_insights_screen.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerConfig.intiLogger();
  await initLocator();
  final isUserInitialized = await locator<UserDataSource>().hasUserData();
  final configRepo = locator<ConfigRepository>();
  final hasAcceptedAnonymousData =
      await configRepo.getConfigHasAcceptedAnonymousData();
  final savedAppTheme = await configRepo.getConfigAppTheme();
  final savedLocale = await configRepo.getConfigLocale();
  final locale = savedLocale != null ? Locale(savedLocale) : null;
  final log = Logger('main');

  // If the user has accepted anonymous data collection, run the app with
  // sentry enabled, else run without it
  if (kReleaseMode && hasAcceptedAnonymousData) {
    log.info('Starting App with Sentry enabled ...');
    _runAppWithSentryReporting(isUserInitialized, savedAppTheme, locale);
  } else {
    log.info('Starting App ...');
    runAppWithChangeNotifiers(isUserInitialized, savedAppTheme, locale);
  }
}

void _runAppWithSentryReporting(
    bool isUserInitialized, AppThemeEntity savedAppTheme, Locale? locale) async {
  await SentryFlutter.init((options) {
    options.dsn = Env.sentryDns;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () =>
          runAppWithChangeNotifiers(isUserInitialized, savedAppTheme, locale));
}

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme, Locale? locale) =>
    runApp(ChangeNotifierProvider(
        create: (_) => ThemeModeProvider(appTheme: savedAppTheme, locale: locale),
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
      },
    );
  }

  ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final scaffoldColor =
        isDark ? const Color(0xFF101311) : colorScheme.surface;
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
        titleTextStyle: appTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 0.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant
                .withValues(alpha: isDark ? 0.38 : 0.65),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scaffoldColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant;
          return appTextTheme.labelMedium?.copyWith(color: color);
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
            BorderSide(color: colorScheme.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
