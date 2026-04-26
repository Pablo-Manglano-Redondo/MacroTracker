import 'package:flutter/material.dart';
import 'package:macrotracker/core/presentation/widgets/dynamic_ont_logo.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/generated/l10n.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const SizedBox(width: 40, child: DynamicOntLogo()),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: S.of(context).appTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface),
          tooltip: S.of(context).settingsLabel,
          onPressed: () {
            Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
