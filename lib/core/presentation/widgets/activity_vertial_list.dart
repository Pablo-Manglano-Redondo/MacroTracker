import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_card.dart';
import 'package:macrotracker/core/presentation/widgets/placeholder_card.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_activity/presentation/add_activity_screen.dart';

class ActivityVerticalList extends StatelessWidget {
  final bool compact;
  final bool showHeader;
  final DateTime day;
  final String title;
  final List<UserActivityEntity> userActivityList;
  final Function(BuildContext, UserActivityEntity) onItemLongPressedCallback;

  const ActivityVerticalList(
      {super.key,
      this.compact = false,
      this.showHeader = true,
      required this.day,
      required this.title,
      required this.userActivityList,
      required this.onItemLongPressedCallback});

  @override
  Widget build(BuildContext context) {
    final sectionHeight = compact ? 136.0 : 160.0;
    final titleStyle = compact
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.titleLarge;
    return Column(
      children: [
        if (showHeader)
          Container(
            padding: EdgeInsets.fromLTRB(16, compact ? 10 : 16, 16, 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(UserActivityEntity.getIconData(),
                    size: 24, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 4.0),
                Text(
                  title,
                  style: titleStyle?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                if (userActivityList.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_view_rounded, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${userActivityList.length}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: sectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                userActivityList.length + 1, // List length + placeholder card
            itemBuilder: (BuildContext context, int index) {
              final firstListElement = index == 0 ? true : false;
              if (index == userActivityList.length) {
                return PlaceholderCard(
                    day: day,
                    onTap: () => _onPlaceholderCardTapped(context),
                    firstListElement: firstListElement,
                    compact: compact);
              } else {
                final userActivity = userActivityList[index];
                return ActivityCard(
                  activityEntity: userActivity,
                  onItemLongPressed: onItemLongPressedCallback,
                  firstListElement: firstListElement,
                  compact: compact,
                );
              }
            },
          ),
        )
      ],
    );
  }

  void _onPlaceholderCardTapped(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.addActivityRoute,
        arguments: AddActivityScreenArguments(day: day));
  }
}
