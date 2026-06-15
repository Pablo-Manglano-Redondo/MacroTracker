import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/generated/l10n.dart';

class MealDetailBottomSheet extends StatelessWidget {
  final MealEntity product;
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;
  final TextEditingController quantityTextController;
  final MealDetailBloc mealDetailBloc;

  final String selectedUnit;

  final Function(String?, String?) onQuantityOrUnitChanged;

  const MealDetailBottomSheet(
      {super.key,
      required this.product,
      required this.day,
      required this.intakeTypeEntity,
      required this.quantityTextController,
      required this.onQuantityOrUnitChanged,
      required this.mealDetailBloc,
      required this.selectedUnit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    final productMissingRequiredInfo = _hasRequiredProductInfoMissing();
    return BottomSheet(
        elevation: 10,
        onClosing: () {},
        enableDrag: false,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outlineVariant
                    .withValues(alpha: isDark ? 0.22 : 0.45),
                width: 1,
              ),
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Drag handle indicator
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              enabled: !productMissingRequiredInfo,
                              controller: quantityTextController
                                ..addListener(() {
                                  onQuantityOrUnitChanged(
                                      quantityTextController.text,
                                      selectedUnit);
                                }),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+([.,]\d{0,2})?$'))
                              ],
                              decoration: inputDecoration.copyWith(
                                labelText: S.of(context).quantityLabel,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: selectedUnit,
                                  decoration: inputDecoration.copyWith(
                                      labelText: S.of(context).unitLabel),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  items: <DropdownMenuItem<String>>[
                                    if (product.hasServingValues)
                                      _getServingDropdownItem(context),
                                    if (product.isSolid ||
                                        !product.isLiquid && !product.isSolid)
                                      ..._getSolidUnitDropdownItems(context),
                                    if (product.isLiquid ||
                                        !product.isLiquid && !product.isSolid)
                                      ..._getLiquidUnitDropdownItems(context),
                                    ..._getOtherDropdownItems(context)
                                  ],
                                  onChanged: (value) {
                                    onQuantityOrUnitChanged(
                                        quantityTextController.text, value);
                                  }))
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, // Make button full width
                        child: FilledButton.icon(
                            onPressed: !productMissingRequiredInfo
                                ? () {
                                    onAddButtonPressed(context);
                                  }
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                              S.of(context).addLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )),
                      ),
                      if (productMissingRequiredInfo) ...[
                        const SizedBox(height: 12),
                        Text(S.of(context).missingProductInfo,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colorScheme.error)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  bool _hasRequiredProductInfoMissing() {
    final productNutriments = product.nutriments;
    if (productNutriments.energyKcal100 == null ||
        productNutriments.carbohydrates100 == null ||
        productNutriments.fat100 == null ||
        productNutriments.proteins100 == null) {
      return true;
    } else {
      return false;
    }
  }

  void onAddButtonPressed(BuildContext context) {
    mealDetailBloc.addIntake(context, mealDetailBloc.state.selectedUnit,
        quantityTextController.text, intakeTypeEntity, product, day);

    // Refresh Home Page
    locator<HomeBloc>().add(const LoadItemsEvent());

    // Refresh Diary Page
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    // Show snackbar and return to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).infoAddedIntakeLabel)));
    Navigator.of(context)
        .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
  }

  DropdownMenuItem<String> _getServingDropdownItem(BuildContext context) {
    return DropdownMenuItem(
      value: UnitDropdownItem.serving.toString(),
      child: Text(
          product.servingSize ??
              '${S.of(context).servingLabel} (${product.servingQuantity} ${product.servingUnit})',
          overflow: TextOverflow.ellipsis,
          maxLines: 1),
    );
  }

  List<DropdownMenuItem<String>> _getSolidUnitDropdownItems(
      BuildContext context) {
    return [
      DropdownMenuItem(
          value: UnitDropdownItem.g.toString(),
          child: Text(S.of(context).gramUnit,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
      DropdownMenuItem(
          value: UnitDropdownItem.oz.toString(),
          child: Text(S.of(context).ozUnit,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
    ];
  }

  List<DropdownMenuItem<String>> _getLiquidUnitDropdownItems(
      BuildContext context) {
    return [
      DropdownMenuItem(
          value: UnitDropdownItem.ml.toString(),
          child: Text(S.of(context).milliliterUnit,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
      DropdownMenuItem(
          value: UnitDropdownItem.flOz.toString(),
          child: Text(S.of(context).flOzUnit,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
    ];
  }

  List<DropdownMenuItem<String>> _getOtherDropdownItems(BuildContext context) {
    return [
      DropdownMenuItem(
          value: UnitDropdownItem.gml.toString(),
          child: Text(
              "${S.of(context).notAvailableLabel} (${S.of(context).gramMilliliterUnit})",
              overflow: TextOverflow.ellipsis,
              maxLines: 1)),
    ];
  }
}
