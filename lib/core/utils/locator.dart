import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:macrotracker/core/data/data_source/config_data_source.dart';
import 'package:macrotracker/core/data/data_source/intake_data_source.dart';
import 'package:macrotracker/core/data/data_source/physical_activity_data_source.dart';
import 'package:macrotracker/core/data/data_source/tracked_day_data_source.dart';
import 'package:macrotracker/core/data/data_source/user_activity_data_source.dart';
import 'package:macrotracker/core/data/data_source/user_data_source.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/data/repository/physical_activity_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/core/utils/env.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/ont_image_cache_manager.dart';
import 'package:macrotracker/core/utils/secure_app_storage_provider.dart';
import 'package:macrotracker/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:macrotracker/features/add_activity/presentation/bloc/activities_bloc.dart';
import 'package:macrotracker/features/add_activity/presentation/bloc/recent_activities_bloc.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/repository/products_repository.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/add_meal_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/food_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:macrotracker/features/body_progress/data/data_source/body_measurement_data_source.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/save_body_measurement_usecase.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/daily_habit_log_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/edit_meal/presentation/bloc/edit_meal_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/interpretation_draft_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/data_sources/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/get_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_photo_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_text_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/features/recipes/data/data_source/recipe_data_source.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_quick_recipe_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_frequent_intake_preset_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/set_recipe_favorite_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/features/scanner/domain/usecase/search_product_by_barcode_usecase.dart';
import 'package:macrotracker/features/scanner/presentation/scanner_bloc.dart';
import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:macrotracker/features/settings/domain/usecase/import_data_usecase.dart';
import 'package:macrotracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:macrotracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final locator = GetIt.instance;

Future<void> initLocator() async {
  // Init secure storage and Hive database;
  final secureAppStorageProvider = SecureAppStorageProvider();
  final hiveDBProvider = HiveDBProvider();
  await hiveDBProvider
      .initHiveDB(await secureAppStorageProvider.getHiveEncryptionKey());

  // Backend
  await Supabase.initialize(
      url: Env.supabaseProjectUrl, anonKey: Env.supabaseProjectAnonKey);
  locator.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Cache manager
  locator
      .registerLazySingleton<CacheManager>(() => OntImageCacheManager.instance);

  // BLoCs
  locator.registerLazySingleton<OnboardingBloc>(
      () => OnboardingBloc(locator(), locator()));
  locator.registerLazySingleton<HomeBloc>(() => HomeBloc(
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator()));
  locator.registerLazySingleton(() => DiaryBloc(locator(), locator()));
  locator.registerLazySingleton(() => CalendarDayBloc(
      locator(), locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<ProfileBloc>(() => ProfileBloc(locator(),
      locator(), locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton(() => SettingsBloc(locator(), locator(),
      locator(), locator(), locator(), locator(), locator()));
  locator.registerFactory(() => ExportImportBloc(locator(), locator()));

  locator.registerFactory<ActivitiesBloc>(() => ActivitiesBloc(locator()));
  locator.registerFactory<RecentActivitiesBloc>(
      () => RecentActivitiesBloc(locator()));
  locator.registerFactory<ActivityDetailBloc>(() => ActivityDetailBloc(
      locator(), locator(), locator(), locator(), locator()));
  locator.registerFactory<MealDetailBloc>(
      () => MealDetailBloc(locator(), locator(), locator()));
  locator.registerFactory<ScannerBloc>(() => ScannerBloc(locator(), locator()));
  locator.registerFactory<EditMealBloc>(() => EditMealBloc(locator()));
  locator.registerFactory<AddMealBloc>(() => AddMealBloc(locator()));
  locator
      .registerFactory<ProductsBloc>(() => ProductsBloc(locator(), locator()));
  locator.registerFactory<FoodBloc>(() => FoodBloc(locator(), locator()));
  locator.registerFactory(() => RecentMealBloc(locator(), locator()));

  // UseCases
  locator.registerLazySingleton<GetConfigUsecase>(
      () => GetConfigUsecase(locator()));
  locator.registerLazySingleton<AddConfigUsecase>(
      () => AddConfigUsecase(locator()));
  locator
      .registerLazySingleton<GetUserUsecase>(() => GetUserUsecase(locator()));
  locator
      .registerLazySingleton<AddUserUsecase>(() => AddUserUsecase(locator()));
  locator.registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCase(locator()));
  locator.registerLazySingleton<SearchProductByBarcodeUseCase>(
      () => SearchProductByBarcodeUseCase(locator()));
  locator.registerLazySingleton<GetIntakeUsecase>(
      () => GetIntakeUsecase(locator()));
  locator.registerLazySingleton<AddIntakeUsecase>(
      () => AddIntakeUsecase(locator()));
  locator.registerLazySingleton<GetRecipeLibraryUsecase>(
      () => GetRecipeLibraryUsecase(locator()));
  locator.registerLazySingleton<GetQuickRecipePresetsUsecase>(
      () => GetQuickRecipePresetsUsecase(locator()));
  locator.registerLazySingleton<SaveRecipeUsecase>(
      () => SaveRecipeUsecase(locator()));
  locator.registerLazySingleton<SetRecipeFavoriteUsecase>(
      () => SetRecipeFavoriteUsecase(locator()));
  locator.registerLazySingleton<LogRecipeUsecase>(
      () => LogRecipeUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton<GetFrequentIntakePresetsUsecase>(
      () => GetFrequentIntakePresetsUsecase(locator()));
  locator.registerLazySingleton<LogFrequentIntakePresetUsecase>(
      () => LogFrequentIntakePresetUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton<GetInterpretationDraftUsecase>(
      () => GetInterpretationDraftUsecase(locator()));
  locator.registerLazySingleton<InterpretMealFromTextUsecase>(
      () => InterpretMealFromTextUsecase(locator()));
  locator.registerLazySingleton<InterpretMealFromPhotoUsecase>(
      () => InterpretMealFromPhotoUsecase(locator()));
  locator.registerLazySingleton<MealInterpretationPersonalizationUsecase>(() =>
      MealInterpretationPersonalizationUsecase(
          locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<SaveInterpretationDraftUsecase>(
      () => SaveInterpretationDraftUsecase(locator()));
  locator.registerLazySingleton<CommitInterpretationDraftUsecase>(() =>
      CommitInterpretationDraftUsecase(
          locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<DeleteIntakeUsecase>(
      () => DeleteIntakeUsecase(locator()));
  locator.registerLazySingleton<UpdateIntakeUsecase>(
      () => UpdateIntakeUsecase(locator()));
  locator.registerLazySingleton<GetUserActivityUsecase>(
      () => GetUserActivityUsecase(locator()));
  locator.registerLazySingleton<AddUserActivityUsecase>(
      () => AddUserActivityUsecase(locator()));
  locator.registerLazySingleton<DeleteUserActivityUsecase>(
      () => DeleteUserActivityUsecase(locator()));
  locator.registerLazySingleton<GetPhysicalActivityUsecase>(
      () => GetPhysicalActivityUsecase(locator()));
  locator.registerLazySingleton<GetTrackedDayUsecase>(
      () => GetTrackedDayUsecase(locator()));
  locator.registerLazySingleton<AddTrackedDayUsecase>(
      () => AddTrackedDayUsecase(locator()));
  locator.registerLazySingleton(
      () => GetKcalGoalUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton(() => GetMacroGoalUsecase(locator()));
  locator.registerLazySingleton<GetGymTargetsUsecase>(() =>
      GetGymTargetsUsecase(
          locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<GetBodyProgressUsecase>(
      () => GetBodyProgressUsecase(locator()));
  locator.registerLazySingleton<SaveBodyMeasurementUsecase>(() =>
      SaveBodyMeasurementUsecase(
          locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<GetDailyHabitLogUsecase>(
      () => GetDailyHabitLogUsecase(locator()));
  locator.registerLazySingleton<UpdateDailyHabitLogUsecase>(
      () => UpdateDailyHabitLogUsecase(locator()));
  locator.registerLazySingleton<SyncSleepFromHealthConnectUsecase>(
      () => SyncSleepFromHealthConnectUsecase(locator(), locator(), locator()));
  locator.registerLazySingleton(() => ExportDataUsecase(
      locator(), locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton(() => ImportDataUsecase(
      locator(), locator(), locator(), locator(), locator(), locator()));
  locator.registerLazySingleton<GenerateMacroSuggestionsUsecase>(
      () => GenerateMacroSuggestionsUsecase(locator()));
  locator.registerLazySingleton<BuildWeeklyInsightsUsecase>(
      () => BuildWeeklyInsightsUsecase(
            locator(),
            locator(),
            locator(),
            locator(),
            locator(),
          ));

  // Repositories
  locator.registerLazySingleton(() => ConfigRepository(locator()));
  locator
      .registerLazySingleton<UserRepository>(() => UserRepository(locator()));
  locator.registerLazySingleton<IntakeRepository>(
      () => IntakeRepository(locator()));
  locator.registerLazySingleton<ProductsRepository>(
      () => ProductsRepository(locator(), locator(), locator()));
  locator.registerLazySingleton<RecipeRepository>(
      () => RecipeRepository(locator()));
  locator.registerLazySingleton<InterpretationDraftRepository>(
      () => InterpretationDraftRepository(locator()));
  locator.registerLazySingleton<MealInterpretationRepository>(
      () => MealInterpretationRepository(locator(), locator(), locator()));
  locator.registerLazySingleton<UserActivityRepository>(
      () => UserActivityRepository(locator()));
  locator.registerLazySingleton<PhysicalActivityRepository>(
      () => PhysicalActivityRepository(locator()));
  locator.registerLazySingleton<TrackedDayRepository>(
      () => TrackedDayRepository(locator()));
  locator.registerLazySingleton<BodyMeasurementRepository>(
      () => BodyMeasurementRepository(locator()));
  locator.registerLazySingleton<DailyHabitLogRepository>(
      () => DailyHabitLogRepository(locator()));

  // DataSources
  locator
      .registerLazySingleton(() => ConfigDataSource(hiveDBProvider.configBox));
  locator.registerLazySingleton<UserDataSource>(
      () => UserDataSource(hiveDBProvider.userBox));
  locator.registerLazySingleton<IntakeDataSource>(
      () => IntakeDataSource(hiveDBProvider.intakeBox));
  locator.registerLazySingleton<UserActivityDataSource>(
      () => UserActivityDataSource(hiveDBProvider.userActivityBox));
  locator.registerLazySingleton<PhysicalActivityDataSource>(
      () => PhysicalActivityDataSource());
  locator.registerLazySingleton<OFFDataSource>(() => OFFDataSource());
  locator.registerLazySingleton<FDCDataSource>(() => FDCDataSource());
  locator.registerLazySingleton<SpFdcDataSource>(() => SpFdcDataSource());
  locator.registerLazySingleton<RecipeDataSource>(
      () => RecipeDataSource(hiveDBProvider.recipeBox));
  locator.registerLazySingleton<InterpretationDraftDataSource>(() =>
      InterpretationDraftDataSource(hiveDBProvider.interpretationDraftBox));
  locator.registerLazySingleton<MealInterpretationRemoteDataSource>(
      () => MealInterpretationRemoteDataSource());
  locator.registerLazySingleton(
      () => TrackedDayDataSource(hiveDBProvider.trackedDayBox));
  locator.registerLazySingleton(
      () => BodyMeasurementDataSource(hiveDBProvider.bodyMeasurementBox));
  locator.registerLazySingleton(
      () => DailyHabitLogDataSource(hiveDBProvider.dailyHabitLogBox));
  locator.registerLazySingleton<HealthConnectSleepDataSource>(
      () => HealthConnectSleepDataSource());

  await _initializeConfig(locator());
}

Future<void> _initializeConfig(ConfigDataSource configDataSource) async {
  if (!await configDataSource.configInitialized()) {
    configDataSource.initializeConfig();
  }
}
