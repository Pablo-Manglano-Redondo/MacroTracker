import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/generated/l10n.dart';

class AddItemBottomSheet extends StatelessWidget {
  final DateTime day;

  const AddItemBottomSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final localizations = S.of(context);

    final items = [
      _GridItem(
        icon: Icons.wb_sunny_outlined,
        label: localizations.breakfastLabel,
        example: localizations.breakfastExample,
        color: const Color(0xFFF59E0B),
        onTap: () => _showAddItemScreen(context, AddMealType.breakfastType),
      ),
      _GridItem(
        icon: Icons.restaurant_outlined,
        label: localizations.lunchLabel,
        example: localizations.lunchExample,
        color: const Color(0xFF10B981),
        onTap: () => _showAddItemScreen(context, AddMealType.lunchType),
      ),
      _GridItem(
        icon: Icons.nights_stay_outlined,
        label: localizations.dinnerLabel,
        example: localizations.dinnerExample,
        color: const Color(0xFF6366F1),
        onTap: () => _showAddItemScreen(context, AddMealType.dinnerType),
      ),
      _GridItem(
        icon: IntakeTypeEntity.snack.getIconData(),
        label: localizations.snackLabel,
        example: localizations.snackExample,
        color: const Color(0xFFEC4899),
        onTap: () => _showAddItemScreen(context, AddMealType.snackType),
      ),
      _GridItem(
        icon: UserActivityEntity.getIconData(),
        label: localizations.activityLabel,
        example: localizations.activityExample,
        color: const Color(0xFFEF4444),
        onTap: () => _showAddActivityScreen(context),
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEs ? '¿Qué quieres registrar?' : 'What do you want to log?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.88,
              children: items
                  .map((item) => _GridCard(item: item))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddItemScreen(BuildContext context, AddMealType itemType) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(NavigationOptions.addMealRoute,
        arguments: AddMealScreenArguments(
          itemType,
          day,
        ));
  }

  void _showAddActivityScreen(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(NavigationOptions.addActivityRoute,
        arguments: AddActivityScreenArguments(day: day));
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String example;
  final Color color;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.example,
    required this.color,
    required this.onTap,
  });
}

class _GridCard extends StatelessWidget {
  final _GridItem item;

  const _GridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          item.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color.withValues(alpha: 0.14),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.example,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
