import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:macrotracker/core/presentation/widgets/image_full_screen.dart';
import 'package:macrotracker/core/utils/recipe_factory.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_detail_bottom_sheet.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_detail_macro_nutrients.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_info_button.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_placeholder.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/meal_title_expanded.dart';
import 'package:macrotracker/features/meal_detail/presentation/widgets/off_disclaimer.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  static const _containerSize = 350.0;

  static const String _initialQuantityMetric = '100';
  static const String _initialQuantityImperial = '1';

  final log = Logger('ItemDetailScreen');

  late MealDetailBloc _mealDetailBloc;
  final _scrollController = ScrollController();

  late MealEntity meal;
  late DateTime _day;
  late IntakeTypeEntity intakeTypeEntity;
  IntakeEntity? _loggedIntake;

  final quantityTextController = TextEditingController();
  late bool _usesImperialUnits;

  String _initialUnit = "";
  String _initialQuantity = "";

  @override
  void initState() {
    _mealDetailBloc = locator<MealDetailBloc>();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as MealDetailScreenArguments;
    meal = args.mealEntity;
    _day = args.day;
    intakeTypeEntity = args.intakeTypeEntity;
    _usesImperialUnits = args.usesImperialUnits;
    _loggedIntake = args.intakeEntity;

    // Set initial unit
    if (_initialUnit == "") {
      if (_loggedIntake != null) {
        _initialUnit = _loggedIntake!.unit;
      } else if (meal.hasServingValues) {
        _initialUnit = UnitDropdownItem.serving.toString();
      } else if (meal.isLiquid) {
        _initialUnit = _usesImperialUnits
            ? UnitDropdownItem.flOz.toString()
            : UnitDropdownItem.ml.toString();
      } else if (meal.isSolid) {
        _initialUnit = _usesImperialUnits
            ? UnitDropdownItem.oz.toString()
            : UnitDropdownItem.g.toString();
      } else {
        _initialUnit = UnitDropdownItem.gml.toString();
      }
      _mealDetailBloc
          .add(UpdateKcalEvent(meal: meal, selectedUnit: _initialUnit));
    }

    // Set initial quantity
    if (_initialQuantity == "") {
      if (_loggedIntake != null) {
        _initialQuantity = _loggedIntake!.amount.toString();
        quantityTextController.text = _formatInitialQuantity(_loggedIntake!.amount);
      } else if (meal.hasServingValues) {
        _initialQuantity = "1";
        quantityTextController.text = "1";
      } else if (_usesImperialUnits) {
        _initialQuantity = _initialQuantityImperial;
        quantityTextController.text = _initialQuantityImperial;
      } else {
        _initialQuantity = _initialQuantityMetric;
        quantityTextController.text = _initialQuantityMetric;
      }
      _mealDetailBloc.add(UpdateKcalEvent(
          meal: meal, totalQuantity: quantityTextController.text));
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<MealDetailBloc, MealDetailState>(
        bloc: _mealDetailBloc,
        builder: (context, state) {
          if (state is MealDetailInitial) {
            return Scaffold(
              body: _getLoadedContent(
                context,
                state.totalQuantityConverted,
                state.totalKcal,
                state.totalCarbs,
                state.totalFat,
                state.totalProtein,
                state.selectedUnit,
              ),
              bottomSheet: _loggedIntake == null
                  ? MealDetailBottomSheet(
                      product: meal,
                      day: _day,
                      intakeTypeEntity: intakeTypeEntity,
                      selectedUnit: state.selectedUnit,
                      mealDetailBloc: _mealDetailBloc,
                      quantityTextController: quantityTextController,
                      onQuantityOrUnitChanged: onQuantityOrUnitChanged,
                    )
                  : null,
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      String totalQuantity,
      double totalKcal,
      double totalCarbs,
      double totalFat,
      double totalProtein,
      String selectedUnit) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            final top = constraints.biggest.height;
            final barsHeight =
                MediaQuery.of(context).padding.top + kToolbarHeight;
            const offset = 10;
            return FlexibleSpaceBar(
                expandedTitleScale: 1, // don't scale title
                background: MealTitleExpanded(
                    meal: meal, usesImperialUnits: _usesImperialUnits),
                title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(meal.name ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis)
                            : const SizedBox()));
          }),
          actions: [
            IconButton(
                onPressed: () {
                  _showSaveRecipeDialog(context, selectedUnit);
                },
                icon: const Icon(Icons.bookmark_add_outlined)),
            if (_loggedIntake == null)
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(NavigationOptions.editMealRoute,
                            arguments: EditMealScreenArguments(
                              _day,
                              meal,
                              intakeTypeEntity,
                              _usesImperialUnits,
                            ));
                  },
                  icon: const Icon(Icons.edit_outlined))
          ],
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: GestureDetector(
                  child: Hero(
                    tag: ImageFullScreen.fullScreenHeroTag,
                    child: CachedNetworkImage(
                      width: 250,
                      height: 250,
                      cacheManager: locator<CacheManager>(),
                      imageUrl: meal.mainImageUrl ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, string) => const MealPlaceholder(),
                      errorWidget: (context, url, error) =>
                          const MealPlaceholder(),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        NavigationOptions.imageFullScreenRoute,
                        arguments:
                            ImageFullScreenArguments(meal.mainImageUrl ?? ""));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loggedIntake != null) ...[
                  _LoggedIntakeSummaryCard(
                    intake: _loggedIntake!,
                    usesImperialUnits: _usesImperialUnits,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Text('${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    MealValueUnitText(
                      value: double.parse(totalQuantity),
                      meal: meal,
                      displayUnit:
                          selectedUnit == UnitDropdownItem.serving.toString()
                              ? meal.servingUnit
                              : selectedUnit,
                      usesImperialUnits: _usesImperialUnits,
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      prefix: ' / ',
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MealDetailMacroNutrients(
                        typeString: S.of(context).carbsLabel,
                        value: totalCarbs),
                    MealDetailMacroNutrients(
                        typeString: S.of(context).fatLabel, value: totalFat),
                    MealDetailMacroNutrients(
                        typeString: S.of(context).proteinLabel,
                        value: totalProtein)
                  ],
                ),
                if (_loggedIntake != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _isEs(context) ? 'Macros del registro' : 'Logged macros',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MealDetailMacroNutrients(
                        typeString: S.of(context).carbsLabel,
                        value: _loggedIntake!.totalCarbsGram,
                      ),
                      MealDetailMacroNutrients(
                        typeString: S.of(context).fatLabel,
                        value: _loggedIntake!.totalFatsGram,
                      ),
                      MealDetailMacroNutrients(
                        typeString: S.of(context).proteinLabel,
                        value: _loggedIntake!.totalProteinsGram,
                      ),
                    ],
                  ),
                ],
                const Divider(),
                const SizedBox(height: 16.0),
                MealDetailNutrimentsTable(
                    product: meal,
                    usesImperialUnits: _usesImperialUnits,
                    servingQuantity: meal.servingQuantity,
                    servingUnit: meal.servingUnit),
                const SizedBox(height: 32.0),
                MealInfoButton(url: meal.url, source: meal.source),
                meal.source == MealSourceEntity.off
                    ? const Column(
                        children: [
                          SizedBox(height: 32),
                          OffDisclaimer(),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 200.0) // height added to scroll
              ],
            ),
          )
        ]))
      ],
    );
  }

  void onQuantityOrUnitChanged(String? quantityString, String? unit) {
    if (quantityString == null || unit == null) {
      return;
    }
    _mealDetailBloc.add(UpdateKcalEvent(
        meal: meal, totalQuantity: quantityString, selectedUnit: unit));
    _scrollToCalorieText();
  }

  void _scrollToCalorieText() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _containerSize - 50,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSaveRecipeDialog(BuildContext context, String selectedUnit) {
    final controller = TextEditingController(text: meal.name ?? '');
    bool favorite = true;
    var quickCategory = QuickRecipeCategoryEntityX.inferLegacyFromRecipe(
      RecipeFactory.fromSingleMeal(
        name: meal.name ?? '',
        meal: meal,
        amount:
            double.tryParse(quantityTextController.text.replaceAll(',', '.')) ??
                1,
        unit: selectedUnit,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      ),
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.of(context).aiSaveAsRecipe),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: S.of(context).aiRecipeNameLabel,
                      helperText: S.of(context).aiRecipeNameHelper,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: favorite,
                    onChanged: (value) {
                      setDialogState(() {
                        favorite = value ?? true;
                      });
                    },
                    title: Text(S.of(context).aiFavoriteQuickAccess),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<QuickRecipeCategoryEntity>(
                    initialValue: quickCategory,
                    decoration: InputDecoration(
                      labelText: S.of(context).recipeQuickCategoryLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: QuickRecipeCategoryEntity.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(_quickCategoryLabel(context, category)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        quickCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(S.of(context).dialogCancelLabel),
                ),
                TextButton(
                  onPressed: () async {
                    final recipeName = controller.text.trim();
                    if (recipeName.isEmpty) {
                      return;
                    }

                    final recipe = RecipeFactory.fromSingleMeal(
                      name: recipeName,
                      meal: meal,
                      amount: double.tryParse(quantityTextController.text
                              .replaceAll(',', '.')) ??
                          1,
                      unit: selectedUnit,
                      quickCategory: quickCategory,
                    ).copyWith(favorite: favorite);

                    await locator<SaveRecipeUsecase>().saveRecipe(recipe);
                    if (!dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).recipeSavedSnackbar)),
                      );
                    }
                  },
                  child: Text(S.of(context).buttonSaveLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatInitialQuantity(double amount) {
    return amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toString();
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _quickCategoryLabel(
    BuildContext context,
    QuickRecipeCategoryEntity category,
  ) {
    switch (category) {
      case QuickRecipeCategoryEntity.preWorkout:
        return S.of(context).quickCategoryPreWorkout;
      case QuickRecipeCategoryEntity.postWorkout:
        return S.of(context).quickCategoryPostWorkout;
      case QuickRecipeCategoryEntity.shake:
        return S.of(context).quickCategoryShake;
      case QuickRecipeCategoryEntity.leanMeal:
        return S.of(context).quickCategoryLeanMeal;
    }
  }
}

class MealDetailScreenArguments {
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final DateTime day;
  final bool usesImperialUnits;
  final IntakeEntity? intakeEntity;

  MealDetailScreenArguments(
      this.mealEntity, this.intakeTypeEntity, this.day, this.usesImperialUnits,
      {this.intakeEntity});
}

class _LoggedIntakeSummaryCard extends StatelessWidget {
  final IntakeEntity intake;
  final bool usesImperialUnits;

  const _LoggedIntakeSummaryCard({
    required this.intake,
    required this.usesImperialUnits,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colorScheme = Theme.of(context).colorScheme;
    final timeLabel = DateFormat.Hm().format(intake.dateTime);
    final mealTypeLabel = _mealTypeLabel(context, intake.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEs ? 'Detalle del registro' : 'Logged entry details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailPill(
                icon: intake.type.getIconData(),
                label: mealTypeLabel,
              ),
              _DetailPill(
                icon: Icons.schedule_outlined,
                label: timeLabel,
              ),
              _DetailPill(
                icon: Icons.local_fire_department_outlined,
                label: '${intake.totalKcal.toStringAsFixed(0)} kcal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          MealValueUnitText(
            value: intake.amount,
            meal: intake.meal,
            displayUnit: intake.unit,
            usesImperialUnits: usesImperialUnits,
            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
            prefix: isEs ? 'Cantidad: ' : 'Amount: ',
          ),
        ],
      ),
    );
  }

  String _mealTypeLabel(BuildContext context, IntakeTypeEntity type) {
    switch (type) {
      case IntakeTypeEntity.breakfast:
        return S.of(context).breakfastLabel;
      case IntakeTypeEntity.lunch:
        return S.of(context).lunchLabel;
      case IntakeTypeEntity.dinner:
        return S.of(context).dinnerLabel;
      case IntakeTypeEntity.snack:
        return S.of(context).snackLabel;
    }
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailPill({
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
            .surface
            .withValues(alpha: 0.9),
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
