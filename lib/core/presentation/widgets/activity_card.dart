import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';

class ActivityCard extends StatelessWidget {
  final bool compact;
  final UserActivityEntity activityEntity;
  final Function(BuildContext, UserActivityEntity) onItemLongPressed;
  final Function(BuildContext, UserActivityEntity)? onItemTapped;
  final bool firstListElement;

  const ActivityCard(
      {super.key,
      this.compact = false,
      required this.activityEntity,
      required this.onItemLongPressed,
      this.onItemTapped,
      required this.firstListElement});

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
    final durationStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.titleSmall;

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
                color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
                child: InkWell(
                  onTap: onItemTapped != null
                      ? () => onTappedItem(context)
                      : null,
                  onLongPress: () => onLongPressedItem(context),
                  child: Stack(
                    children: [
                      // Subtle Tint for Activity
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.03),
                        ),
                      ),

                      // Background Watermark Icon in the Center
                      Center(
                        child: Icon(
                          activityEntity.physicalActivityEntity.displayIcon,
                          size: compact ? 38 : 46,
                          color: colorScheme.tertiary.withValues(alpha: 0.08),
                        ),
                      ),

                      // Calorie Burned Badge (Top Left)
                      Positioned(
                        top: margin,
                        left: margin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.tertiary.withValues(alpha: 0.12),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("🔥", style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                '${activityEntity.burnedKcal.toInt()} kcal',
                                style: kcalFont?.copyWith(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Title & Duration (Bottom Left)
                      Positioned(
                        bottom: margin,
                        left: margin,
                        right: margin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              activityEntity.physicalActivityEntity.getName(context),
                              style: titleStyle?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: compact ? 12.5 : 14,
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activityEntity.duration.toInt()} min',
                              style: durationStyle?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
    onItemLongPressed(context, activityEntity);
  }

  void onTappedItem(BuildContext context) {
    onItemTapped?.call(context, activityEntity);
  }
}
