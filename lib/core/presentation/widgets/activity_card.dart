import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';

class ActivityCard extends StatelessWidget {
  final bool compact;
  final UserActivityEntity activityEntity;
  final Function(BuildContext, UserActivityEntity) onItemLongPressed;
  final bool firstListElement;

  const ActivityCard(
      {super.key,
      this.compact = false,
      required this.activityEntity,
      required this.onItemLongPressed,
      required this.firstListElement});

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 104.0 : 120.0;
    final cardHeight = compact ? 104.0 : 120.0;
    final iconSize = compact ? 20.0 : 24.0;
    final titleStyle = compact
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;
    final subtitleStyle = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        SizedBox(
          width: firstListElement ? 16 : 8, // Add leading padding
        ),
        SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: cardHeight,
                width: cardWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(compact ? 16.0 : 20.0)),
                  color: Theme.of(context).colorScheme.brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: Theme.of(context).colorScheme.brightness == Brightness.dark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(compact ? 16.0 : 20.0)),
                  child: InkWell(
                    onLongPress: () {
                      onLongPressedItem(context);
                    },
                    child: Stack(
                      children: [
                        // Background accent icon
                        Positioned(
                          right: -cardHeight * 0.1,
                          bottom: -cardHeight * 0.1,
                          child: Icon(
                            activityEntity.physicalActivityEntity.displayIcon,
                            size: cardHeight * 0.7,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("🔥", style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${activityEntity.burnedKcal.toInt()} kcal",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer,
                                          fontWeight: FontWeight.w800,
                                          fontSize: compact ? 9 : 10,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(compact ? 10 : 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activityEntity.physicalActivityEntity.displayIcon,
                              size: compact ? 22 : 28,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  activityEntity.physicalActivityEntity.getName(context),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        fontSize: compact ? 13 : 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '${activityEntity.duration.toInt()} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void onLongPressedItem(BuildContext context) {
    onItemLongPressed(context, activityEntity);
  }
}
