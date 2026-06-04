import 'package:flutter/material.dart';
import 'package:macrotracker/core/presentation/widgets/meal_entry_action_sheet.dart';

class AddItemBottomSheet extends StatelessWidget {
  final DateTime day;

  const AddItemBottomSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return MealEntryActionSheet(day: day);
  }
}
