import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:macrotracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';

class MealItemCard extends StatelessWidget {
  final DateTime day;
  final AddMealType addMealType;
  final MealEntity mealEntity;
  final bool usesImperialUnits;

  const MealItemCard(
      {super.key,
      required this.day,
      required this.mealEntity,
      required this.addMealType,
      required this.usesImperialUnits});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: () => _onItemPressed(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              children: [
                // Thumbnail / Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    child: mealEntity.thumbnailImageUrl != null
                        ? CachedNetworkImage(
                            cacheManager: locator<CacheManager>(),
                            fit: BoxFit.cover,
                            imageUrl: mealEntity.thumbnailImageUrl!,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => const Icon(Icons.restaurant_outlined),
                          )
                        : const Icon(Icons.restaurant_outlined),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: mealEntity.name ?? "?",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          children: [
                            if (mealEntity.brands != null && mealEntity.brands!.isNotEmpty)
                              TextSpan(
                                text: ' ${mealEntity.brands}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mealEntity.mealQuantity != null) ...[
                        const SizedBox(height: 4),
                        MealValueUnitText(
                          value: double.parse(mealEntity.mealQuantity ?? "0"),
                          meal: mealEntity,
                          usesImperialUnits: usesImperialUnits,
                          // No pass style if the widget doesn't support it, 
                          // let's assume it follows theme.
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Add button
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemPressed(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
            mealEntity, addMealType.getIntakeType(), day, usesImperialUnits));
  }
}
