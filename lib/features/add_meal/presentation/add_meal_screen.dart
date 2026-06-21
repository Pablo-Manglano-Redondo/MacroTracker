import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
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
  late RecentMealBloc _recentMealBloc;

  late DateTime _day;
  late AddMealType _mealType;

  final ValueNotifier<String> _searchStringListener = ValueNotifier<String>("");
  Timer? _debounceTimer;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _productsBloc = locator<ProductsBloc>();
    _recentMealBloc = locator<RecentMealBloc>();
    _searchStringListener.addListener(_onSearchStringChanged);
    _tabController.addListener(_onTabChanged);
    super.initState();
  }

  void _onSearchStringChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _onSearchSubmit(_searchStringListener.value);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _onSearchSubmit(_searchStringListener.value);
    }
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchStringListener.removeListener(_onSearchStringChanged);
    _searchStringListener.dispose();
    _debounceTimer?.cancel();
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
              const SizedBox(height: 12.0),
              _AddMealQuickActions(
                onTextTap: _openTextCapture,
                onPhotoTap: _openPhotoCapture,
                onLibraryTap: _openRecipeLibrary,
              ),
              const SizedBox(height: 16.0),
              TabBar(
                  tabs: [
                    Tab(text: localizations.addMealTabPackaged),
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
                          } else if (state is ProductsOfflineState) {
                            return state.cachedProducts.isNotEmpty
                                ? Flexible(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.wifi_off_outlined, color: Theme.of(context).colorScheme.error, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  localizations.addMealOfflineCachedResults,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.error,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: state.cachedProducts.length,
                                              itemBuilder: (context, index) {
                                                return MealItemCard(
                                                  day: _day,
                                                  mealEntity: state.cachedProducts[index],
                                                  addMealType: _mealType,
                                                  usesImperialUnits: false,
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  )
                                : NoResultsWidget.message(
                                    localizations.addMealOfflineNoCachedResults,
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
        return localizations.addMealTabRecentHelper;
      default:
        return localizations.addMealTabPackagedHelper;
    }
  }

  void _onProductsRefreshButtonPressed() {
    _productsBloc.add(const RefreshProductsEvent());
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

class _AddMealQuickActions extends StatelessWidget {
  final VoidCallback onTextTap;
  final VoidCallback onPhotoTap;
  final VoidCallback onLibraryTap;

  const _AddMealQuickActions({
    required this.onTextTap,
    required this.onPhotoTap,
    required this.onLibraryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionChip(
            icon: Icons.edit_note_outlined,
            label: S.of(context).addMealText,
            onTap: onTextTap,
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.add_a_photo_outlined,
            label: S.of(context).addMealPhoto,
            onTap: onPhotoTap,
          ),
          const SizedBox(width: 8),
          _QuickActionChip(
            icon: Icons.bookmarks_outlined,
            label: S.of(context).addMealSaved,
            onTap: onLibraryTap,
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: colorScheme.primary,
      ),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
