import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';

class NoResultsWidget extends StatelessWidget {
  final String? message;

  const NoResultsWidget({super.key}) : message = null;
  const NoResultsWidget.message(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          const Icon(Icons.search, size: 64),
          const SizedBox(height: 8),
          Text(message ?? S.of(context).noResultsFound,
              style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
  }
}
