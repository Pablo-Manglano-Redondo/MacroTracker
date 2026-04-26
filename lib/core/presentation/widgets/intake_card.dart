import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:macrotracker/core/utils/locator.dart';

class IntakeCard extends StatelessWidget {
  final bool compact;
  final IntakeEntity intake;
  final Function(BuildContext, IntakeEntity)? onItemLongPressed;
  final Function(BuildContext, IntakeEntity, bool)? onItemTapped;
  final bool firstListElement;
  final bool usesImperialUnits;

  const IntakeCard(
      {required super.key,
      this.compact = false,
      required this.intake,
      this.onItemLongPressed,
      this.onItemTapped,
      required this.firstListElement,
      required this.usesImperialUnits});

  @override
  Widget build(BuildContext context) {
    final cardSize = compact ? 104.0 : 120.0;
    final borderRadius = compact ? 14.0 : 16.0;
    final margin = compact ? 6.0 : 8.0;
    final kcalFont = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.bodySmall;
    final titleStyle = compact
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.titleMedium;
    final amountStyle = compact
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.titleSmall;

    return Row(
      children: [
        SizedBox(width: firstListElement ? 16 : 0),
        SizedBox(
          width: cardSize,
          height: cardSize,
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 1,
            child: InkWell(
              onLongPress: onItemLongPressed != null
                  ? () => onLongPressedItem(context)
                  : null,
              onTap: onItemTapped != null
                  ? () => onTappedItem(context, usesImperialUnits)
                  : null,
              child: Stack(
                children: [
                  intake.meal.mainImageUrl != null
                      ? CachedNetworkImage(
                          cacheManager: locator<CacheManager>(),
                          imageUrl: intake.meal.mainImageUrl ?? "",
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.restaurant_outlined,
                              color: Theme.of(context).colorScheme.secondary)),
                  Container(
                    // Add color shade
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(margin),
                    padding:
                        EdgeInsets.fromLTRB(margin + 2, 4.0, margin + 2, 4.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${intake.totalKcal.toInt()} kcal',
                      style: kcalFont?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(margin),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            intake.meal.name ?? "?",
                            style: titleStyle?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          MealValueUnitText(
                            value: intake.amount,
                            meal: intake.meal,
                            usesImperialUnits: usesImperialUnits,
                            textStyle: amountStyle?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                    .withValues(alpha: 0.7)),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onLongPressedItem(BuildContext context) {
    onItemLongPressed?.call(context, intake);
  }

  void onTappedItem(BuildContext context, bool usesImperialUnits) {
    onItemTapped?.call(context, intake, usesImperialUnits);
  }
}
