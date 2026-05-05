import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final bool compact;
  final DateTime day;
  final VoidCallback onTap;
  final bool firstListElement;

  const PlaceholderCard({
    super.key,
    this.compact = false,
    required this.day,
    required this.onTap,
    required this.firstListElement,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = compact ? 104.0 : 120.0;
    final borderRadius = compact ? 14.0 : 16.0;
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          SizedBox(
            width: firstListElement ? 16 : 8, // Add leading padding
          ),
          Container(
            width: cardSize,
            height: cardSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).colorScheme.brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: InkWell(
                onTap: onTap,
                child: Icon(Icons.add,
                    size: compact ? 28 : 36,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.6)),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
