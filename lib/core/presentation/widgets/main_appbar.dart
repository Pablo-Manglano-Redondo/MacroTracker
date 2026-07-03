import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/feature_tour/presentation/widgets/product_tour_overlay.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_library_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;

  const MainAppbar({super.key, required this.title, required this.iconData});

  @override
  Widget build(BuildContext context) {
    final isDiary = title == S.of(context).diaryLabel;
    final isProfile = title == S.of(context).profileLabel;

    final Color iconColor;
    final Color bgColor;

    if (isDiary || isProfile) {
      iconColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
    } else {
      iconColor = const Color(0xFF0D9488);
      bgColor = const Color(0xFF0D9488).withValues(alpha: 0.12);
    }

    return AppBar(
      titleSpacing: 16,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: bgColor,
            ),
            alignment: Alignment.center,
            child: Icon(iconData, color: iconColor, size: 20),
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              await Navigator.of(context)
                  .pushNamed(NavigationOptions.settingsRoute);
              locator<HomeBloc>().add(const LoadItemsEvent());
              locator<DiaryBloc>().add(const LoadDiaryYearEvent());
              locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
            },
            icon: const Icon(Icons.settings_outlined))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
