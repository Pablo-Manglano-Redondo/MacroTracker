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
  final log = Logger('main');

  // If the user has accepted anonymous data collection, run the app with
  // sentry enabled, else run without it
  if (kReleaseMode && hasAcceptedAnonymousData) {
    log.info('Starting App with Sentry enabled ...');
    _runAppWithSentryReporting(isUserInitialized, savedAppTheme);
  } else {
    log.info('Starting App ...');
    runAppWithChangeNotifiers(isUserInitialized, savedAppTheme);
  }
}

void _runAppWithSentryReporting(
    bool isUserInitialized, AppThemeEntity savedAppTheme) async {
  await SentryFlutter.init((options) {
    options.dsn = Env.sentryDns;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () =>
          runAppWithChangeNotifiers(isUserInitialized, savedAppTheme));
}

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme) =>
    runApp(ChangeNotifierProvider(
        create: (_) => ThemeModeProvider(appTheme: savedAppTheme),
        child: MacroTrackerApp(userInitialized: userInitialized)));

class MacroTrackerApp extends StatelessWidget {
  final bool userInitialized;

  const MacroTrackerApp({super.key, required this.userInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => S.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: appTextTheme),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: appTextTheme),
      themeMode: Provider.of<ThemeModeProvider>(context).themeMode,
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
      },
    );
  }
}
