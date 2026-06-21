import 'package:flutter/material.dart';

class SegmentedProgressIndicator extends StatelessWidget {
  final int totalSegments;
  final int activeSegment;

  const SegmentedProgressIndicator({
    super.key,
    required this.totalSegments,
    required this.activeSegment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index == activeSegment;
        final isPassed = index < activeSegment;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isActive ? 6.0 : 4.0,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : isPassed
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }),
    );
  }
}
