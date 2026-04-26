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
            width: firstListElement ? 16 : 0, // Add leading padding
          ),
          SizedBox(
            width: cardSize,
            height: cardSize,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: InkWell(
                onTap: onTap,
                child: Icon(Icons.add,
                    size: compact ? 28 : 36,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
