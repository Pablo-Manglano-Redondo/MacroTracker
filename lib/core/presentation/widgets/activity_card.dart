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
              SizedBox(
                height: cardHeight,
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: InkWell(
                    onLongPress: () {
                      onLongPressedItem(context);
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            "🔥${activityEntity.burnedKcal.toInt()} kcal",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer),
                          ),
                        ),
                        Center(
                          child: Icon(
                            activityEntity.physicalActivityEntity.displayIcon,
                            size: iconSize,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  activityEntity.physicalActivityEntity.getName(context),
                  style: titleStyle?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${activityEntity.duration.toInt()} min',
                    style: subtitleStyle?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8)),
                    maxLines: 1,
                  ))
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
