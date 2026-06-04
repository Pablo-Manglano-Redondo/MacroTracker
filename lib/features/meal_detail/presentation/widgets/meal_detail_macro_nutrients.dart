import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/extensions.dart';

class MealDetailMacroNutrients extends StatelessWidget {
  final String typeString;
  final double? value;

  const MealDetailMacroNutrients(
      {super.key, required this.typeString, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    Color accentColor = colorScheme.primary;
    final typeLower = typeString.toLowerCase();
    if (typeLower.contains('carb') || typeLower.contains('hidad')) {
      accentColor = const Color(0xFF3B82F6); 
    } else if (typeLower.contains('fat') || typeLower.contains('gras')) {
      accentColor = const Color(0xFFF59E0B); 
    } else if (typeLower.contains('prot')) {
      accentColor = const Color(0xFF10B981); 
    }

    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${value?.roundToPrecision(1) ?? "?"}g',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            typeString,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          )
        ],
      ),
    );
  }
}
