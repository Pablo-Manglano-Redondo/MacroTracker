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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final cardSize = compact ? 104.0 : 120.0;
    final borderRadius = compact ? 14.0 : 16.0;
    final margin = compact ? 6.0 : 8.0;

    final kcalFont = compact
        ? theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800);
    final titleStyle = compact
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final amountStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.titleSmall;

    final hasImage = intake.meal.mainImageUrl != null;

    return Row(
      children: [
        SizedBox(width: firstListElement ? 16 : 8),
        SizedBox(
          width: cardSize,
          height: cardSize,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              child: Material(
                color: hasImage
                    ? Colors.black
                    : (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface),
                child: InkWell(
                  onLongPress: onItemLongPressed != null
                      ? () => onLongPressedItem(context)
                      : null,
                  onTap: onItemTapped != null
                      ? () => onTappedItem(context, usesImperialUnits)
                      : null,
                  child: Stack(
                    children: [
                      // Image or Icon Background
                      if (hasImage)
                        CachedNetworkImage(
                          cacheManager: locator<CacheManager>(),
                          imageUrl: intake.meal.mainImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      else
                        Center(
                          child: Icon(
                            Icons.restaurant_outlined,
                            size: compact ? 32 : 38,
                            color: colorScheme.primary.withValues(alpha: 0.08),
                          ),
                        ),

                      // Gradient Overlay for Image / Subtle Tint for No Image
                      if (hasImage)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.03),
                          ),
                        ),

                      // Calorie Badge (Top Left)
                      Positioned(
                        top: margin,
                        left: margin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasImage
                                ? Colors.black.withValues(alpha: 0.65)
                                : colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasImage
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : colorScheme.primary.withValues(alpha: 0.12),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${intake.totalKcal.toInt()} kcal',
                            style: kcalFont?.copyWith(
                              color: hasImage ? Colors.white : colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      // Title & Amount (Bottom Left)
                      Positioned(
                        bottom: margin,
                        left: margin,
                        right: margin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              intake.meal.name ?? "?",
                              style: titleStyle?.copyWith(
                                color: hasImage ? Colors.white : colorScheme.onSurface,
                                fontSize: compact ? 12.5 : 14,
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            MealValueUnitText(
                              value: intake.amount,
                              meal: intake.meal,
                              usesImperialUnits: usesImperialUnits,
                              textStyle: amountStyle?.copyWith(
                                color: hasImage
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : colorScheme.onSurfaceVariant,
                                fontSize: compact ? 10.5 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
