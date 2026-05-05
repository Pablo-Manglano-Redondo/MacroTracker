import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';

class DefaultsResultsWidget extends StatelessWidget {
  final String? message;

  const DefaultsResultsWidget({super.key}) : message = null;
  const DefaultsResultsWidget.message(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(message ?? S.of(context).searchDefaultLabel),
    );
  }
}
