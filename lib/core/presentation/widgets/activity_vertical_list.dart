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
  final Function(BuildContext, UserActivityEntity)? onItemTappedCallback;

  const ActivityVerticalList(
      {super.key,
      this.compact = false,
      this.showHeader = true,
      required this.day,
      required this.title,
      required this.userActivityList,
      required this.onItemLongPressedCallback,
      this.onItemTappedCallback});

  @override
  Widget build(BuildContext context) {
    final sectionHeight = compact ? 104.0 : 120.0;
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
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: sectionHeight + 24,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(userActivityList.length, (index) {
                    final userActivity = userActivityList[index];
                    return ActivityCard(
                      activityEntity: userActivity,
                      onItemLongPressed: onItemLongPressedCallback,
                      onItemTapped: onItemTappedCallback,
                      firstListElement: index == 0,
                      compact: compact,
                    );
                  }),
                  PlaceholderCard(
                    day: day,
                    onTap: () => _onPlaceholderCardTapped(context),
                    firstListElement: userActivityList.isEmpty,
                    compact: compact,
                  ),
                ],
              ),
            ),
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
