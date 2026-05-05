import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/food_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:macrotracker/features/add_meal/presentation/widgets/default_results_widget.dart';
import 'package:macrotracker/features/add_meal/presentation/widgets/meal_item_card.dart';
import 'package:macrotracker/features/add_meal/presentation/widgets/meal_search_bar.dart';
import 'package:macrotracker/features/add_meal/presentation/widgets/no_results_widget.dart';
import 'package:macrotracker/core/presentation/widgets/error_dialog.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class AddMealScreenArguments {
  final DateTime day;
  final AddMealType mealType;

  AddMealScreenArguments(this.mealType, this.day);
}

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductsBloc _productsBloc;
  late FoodBloc _foodBloc;
  late RecentMealBloc _recentMealBloc;

  late DateTime _day;
  late AddMealType _mealType;

  final ValueNotifier<String> _searchStringListener = ValueNotifier<String>("");

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _productsBloc = locator<ProductsBloc>();
    _foodBloc = locator<FoodBloc>();
    _recentMealBloc = locator<RecentMealBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)!.settings.arguments as AddMealScreenArguments;
    _day = args.day;
    _mealType = args.mealType;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchStringListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(localizations.addLabel),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              MealSearchBar(
                searchStringListener: _searchStringListener,
                onSearchSubmit: _onSearchSubmit,
                onBarcodePressed: _onBarcodeIconPressed,
              ),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.35),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.addMealQuickActionsTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.addMealQuickActionsSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _onBarcodeIconPressed,
                      icon: const Icon(Icons.qr_code_scanner_outlined),
                      label: Text(S.of(context).addMealBarcode),
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButton.icon(
                      onPressed: _openTextCapture,
                      icon: const Icon(Icons.text_fields_outlined),
                      label: Text(S.of(context).addMealText),
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButton.icon(
                      onPressed: _openPhotoCapture,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(S.of(context).addMealPhoto),
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButton.icon(
                      onPressed: _openRecipeLibrary,
                      icon: const Icon(Icons.bookmarks_outlined),
                      label: Text(S.of(context).addMealSaved),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TabBar(
                  tabs: [
                    Tab(text: localizations.addMealTabPackaged),
                    Tab(text: localizations.addMealTabGeneric),
                    Tab(text: localizations.addMealTabRecent)
                  ],
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return Text(
                      _tabHelperText(localizations),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              localizations.addMealSectionPackagedResults,
                              style:
                                  Theme.of(context).textTheme.headlineSmall)),
                      BlocBuilder<ProductsBloc, ProductsState>(
                        bloc: _productsBloc,
                        builder: (context, state) {
                          if (state is ProductsInitial) {
                            return DefaultsResultsWidget.message(
                              localizations.addMealSearchPromptPackaged,
                            );
                          } else if (state is ProductsLoadingState) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is ProductsLoadedState) {
                            return state.products.isNotEmpty
                                ? Flexible(
                                    child: ListView.builder(
                                        itemCount: state.products.length,
                                        itemBuilder: (context, index) {
                                          return MealItemCard(
                                            day: _day,
                                            mealEntity: state.products[index],
                                            addMealType: _mealType,
                                            usesImperialUnits:
                                                state.usesImperialUnits,
                                          );
                                        }))
                                : NoResultsWidget.message(
                                    localizations.noResultsFound,
                                  );
                          } else if (state is ProductsFailedState) {
                            return ErrorDialog(
                              errorText: localizations.errorFetchingProductData,
                              onRefreshPressed: _onProductsRefreshButtonPressed,
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              localizations.addMealSectionGenericResults,
                              style:
                                  Theme.of(context).textTheme.headlineSmall)),
                      BlocBuilder<FoodBloc, FoodState>(
                        bloc: _foodBloc,
                        builder: (context, state) {
                          if (state is FoodInitial) {
                            return DefaultsResultsWidget.message(
                              localizations.addMealSearchPromptGeneric,
                            );
                          } else if (state is FoodLoadingState) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is FoodLoadedState) {
                            return state.food.isNotEmpty
                                ? Flexible(
                                    child: ListView.builder(
                                        itemCount: state.food.length,
                                        itemBuilder: (context, index) {
                                          return MealItemCard(
                                            day: _day,
                                            mealEntity: state.food[index],
                                            addMealType: _mealType,
                                            usesImperialUnits:
                                                state.usesImperialUnits,
                                          );
                                        }))
                                : NoResultsWidget.message(
                                    localizations.noResultsFound,
                                  );
                          } else if (state is FoodFailedState) {
                            return ErrorDialog(
                              errorText: localizations.errorFetchingProductData,
                              onRefreshPressed: _onFoodRefreshButtonPressed,
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(localizations.addMealSectionRecentResults,
                              style:
                                  Theme.of(context).textTheme.headlineSmall)),
                      BlocBuilder<RecentMealBloc, RecentMealState>(
                          bloc: _recentMealBloc,
                          builder: (context, state) {
                            if (state is RecentMealInitial) {
                              _recentMealBloc.add(
                                  const LoadRecentMealEvent(searchString: ""));
                              return const SizedBox();
                            } else if (state is RecentMealLoadingState) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 32),
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is RecentMealLoadedState) {
                              return state.recentMeals.isNotEmpty
                                  ? Flexible(
                                      child: ListView.builder(
                                          itemCount: state.recentMeals.length,
                                          itemBuilder: (context, index) {
                                            return MealItemCard(
                                              day: _day,
                                              mealEntity:
                                                  state.recentMeals[index],
                                              addMealType: _mealType,
                                              usesImperialUnits:
                                                  state.usesImperialUnits,
                                            );
                                          }))
                                  : NoResultsWidget.message(
                                      localizations.addMealRecentEmpty,
                                    );
                            } else if (state is RecentMealFailedState) {
                              return ErrorDialog(
                                errorText: localizations.addMealRecentEmpty,
                                onRefreshPressed:
                                    _onRecentMealsRefreshButtonPressed,
                              );
                            }
                            return const SizedBox();
                          })
                    ],
                  )
                ]),
              )
            ],
          ),
        ));
  }

  String _tabHelperText(S localizations) {
    switch (_tabController.index) {
      case 0:
        return localizations.addMealTabPackagedHelper;
      case 1:
        return localizations.addMealTabGenericHelper;
      case 2:
        return localizations.addMealTabRecentHelper;
      default:
        return localizations.addMealTabPackagedHelper;
    }
  }

  void _onProductsRefreshButtonPressed() {
    _productsBloc.add(const RefreshProductsEvent());
  }

  void _onFoodRefreshButtonPressed() {
    _foodBloc.add(const RefreshFoodEvent());
  }

  void _onRecentMealsRefreshButtonPressed() {
    _recentMealBloc.add(const LoadRecentMealEvent(searchString: ""));
  }

  void _onSearchSubmit(String inputText) {
    switch (_tabController.index) {
      case 0:
        _productsBloc.add(LoadProductsEvent(searchString: inputText));
        break;
      case 1:
        _foodBloc.add(LoadFoodEvent(searchString: inputText));
        break;
      case 2:
        _recentMealBloc.add(LoadRecentMealEvent(searchString: inputText));
        break;
    }
  }

  void _onBarcodeIconPressed() {
    Navigator.of(context).pushNamed(
      NavigationOptions.scannerRoute,
      arguments: ScannerScreenArguments(_day, _mealType.getIntakeType()),
    );
  }

  void _openTextCapture() {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealTextCaptureRoute,
      arguments:
          MealTextCaptureScreenArguments(_day, _mealType.getIntakeType()),
    );
  }

  void _openPhotoCapture() {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealPhotoCaptureRoute,
      arguments:
          MealPhotoCaptureScreenArguments(_day, _mealType.getIntakeType()),
    );
  }

  void _openRecipeLibrary() {
    Navigator.of(context).pushNamed(
      NavigationOptions.recipeLibraryRoute,
      arguments: RecipeLibraryScreenArguments(_day, _mealType.getIntakeType()),
    );
  }
}
