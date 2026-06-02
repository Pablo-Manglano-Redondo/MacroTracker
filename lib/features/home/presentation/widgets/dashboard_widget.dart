import 'dart:ui';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/presentation/widgets/food_quality_score_card.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

class DashboardWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final UserWeightGoalEntity nutritionPhase;
  final ValueChanged<UserWeightGoalEntity> onNutritionPhaseChanged;
  final DailyFocusEntity dailyFocus;
  final ValueChanged<DailyFocusEntity> onDailyFocusChanged;
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;
  final double dailyFoodQualityScore;
  final FoodQualityBandEntity dailyFoodQualityBand;
  final int dailyFoodQualityMealsCount;
  final int mealsLogged;
  final int sessionsLogged;

  const DashboardWidget({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.nutritionPhase,
    required this.onNutritionPhaseChanged,
    required this.dailyFocus,
    required this.onDailyFocusChanged,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
    required this.dailyFoodQualityScore,
    required this.dailyFoodQualityBand,
    required this.dailyFoodQualityMealsCount,
    required this.mealsLogged,
    required this.sessionsLogged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 390;
    final surfaceColor = isDark ? const Color(0xFF121212) : Colors.white;
    final subtleSurface = isDark
        ? const Color(0xFF1C1C1C)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.36);
    final bodyColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    final proteinRemaining =
        _positiveRemaining(totalProteinsGoal - totalProteinsIntake);
    final carbsRemaining =
        _positiveRemaining(totalCarbsGoal - totalCarbsIntake);
    final fatRemaining = _positiveRemaining(totalFatsGoal - totalFatsIntake);

    return Padding(
      padding: padding,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: isDark ? surfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
          border: Border.all(
            color: isDark
                ? colorScheme.outlineVariant.withValues(alpha: 0.22)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isCompact ? 40 : 44,
                  height: isCompact ? 40 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dashboardTitle(context),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: bodyColor,
                              fontWeight: FontWeight.w900,
                              fontSize: isCompact ? 20 : 22,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dashboardSubtitle(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  icon: Icons.restaurant_outlined,
                  label: _mealsChip(context, mealsLogged),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.local_fire_department_outlined,
                  label: _burnedChip(context, totalKcalBurned.toInt()),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.fitness_center_outlined,
                  label: _sessionsChip(context, sessionsLogged),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
              ],
            ),
            if (totalKcalSupplied == 0) ...[
              const SizedBox(height: 14),
              _DashboardEmptyState(isEs: _isEs(context)),
            ],
            const SizedBox(height: 18),
            _PrimaryMetric(
              label: totalKcalLeft >= 0
                  ? _kcalRemainingLabel(context)
                  : _overGoalLabel(context),
              value: totalKcalLeft.abs().toInt(),
              suffix: 'kcal',
              textColor: bodyColor,
              accentColor:
                  totalKcalLeft >= 0 ? colorScheme.tertiary : colorScheme.error,
              background: totalKcalLeft >= 0
                  ? colorScheme.tertiary.withValues(alpha: 0.14)
                  : colorScheme.error.withValues(alpha: 0.14),
              compact: isCompact,
            ),
            const SizedBox(height: 18),
            _MacroTrackCircles(
              totalKcalDaily: totalKcalDaily,
              totalKcalLeft: totalKcalLeft,
              proteinIntake: totalProteinsIntake,
              proteinGoal: totalProteinsGoal,
              proteinRemaining: proteinRemaining,
              carbsIntake: totalCarbsIntake,
              carbsGoal: totalCarbsGoal,
              carbsRemaining: carbsRemaining,
              fatIntake: totalFatsIntake,
              fatGoal: totalFatsGoal,
              fatRemaining: fatRemaining,
            ),
            const SizedBox(height: 16),
            _FoodQualityDailyStrip(
              score: dailyFoodQualityScore,
              band: dailyFoodQualityBand,
              mealsCount: dailyFoodQualityMealsCount,
            ),
          ],
        ),
      ),
    );
  }

  double _positiveRemaining(double value) {
    if (value <= 0) {
      return 0;
    }
    return value;
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _dashboardTitle(BuildContext context) =>
      _isEs(context) ? 'Nutrición de gimnasio' : 'Gym nutrition';

  String _dashboardSubtitle(BuildContext context) =>
      _isEs(context) ? 'Lo importante de hoy.' : 'Today at a glance.';

  String _mealsChip(BuildContext context, int count) {
    if (_isEs(context)) {
      return count == 1 ? '1 comida' : '$count comidas';
    }
    return count == 1 ? '1 meal' : '$count meals';
  }

  String _sessionsChip(BuildContext context, int count) {
    if (_isEs(context)) {
      return count == 1 ? '1 sesión' : '$count sesiones';
    }
    return count == 1 ? '1 session' : '$count sessions';
  }

  String _burnedChip(BuildContext context, int count) =>
      _isEs(context) ? '$count kcals' : '$count burned';

  String _kcalRemainingLabel(BuildContext context) =>
      _isEs(context) ? 'Kcal restantes' : 'Kcal left';

  String _overGoalLabel(BuildContext context) =>
      _isEs(context) ? 'Sobre objetivo' : 'Over goal';
}

class _FoodQualityDailyStrip extends StatelessWidget {
  final double score;
  final FoodQualityBandEntity band;
  final int mealsCount;

  const _FoodQualityDailyStrip({
    required this.score,
    required this.band,
    required this.mealsCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = FoodQualityUiMeta.bandColor(context, band);
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accentColor.withValues(alpha: 0.08),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
        ),
      ),
      child: mealsCount == 0
          ? Text(
              isEs
                  ? 'Aun no hay datos suficientes de calidad.'
                  : 'No food quality data yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: accentColor.withValues(alpha: 0.14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.eco_outlined, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FoodQualityUiMeta.title(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEs
                            ? 'Media diaria basada en $mealsCount comidas'
                            : 'Daily average across $mealsCount meals',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.round().toString(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    Text(
                      FoodQualityUiMeta.bandLabel(context, band),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _PrimaryMetric extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final Color textColor;
  final Color accentColor;
  final Color background;
  final bool compact;

  const _PrimaryMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.textColor,
    required this.accentColor,
    required this.background,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF0D0D0D)
        : Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.30);
    final barColor = const Color(0xFF10B981); // Menthe green for both

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cardBg,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 4,
                height: compact ? 24 : 28,
                margin: const EdgeInsets.only(right: 10, bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: barColor,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedFlipCounter(
                        duration: const Duration(milliseconds: 700),
                        value: value,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 28 : null,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          suffix,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final Color color;
  final Color background;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.compact,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final chipBg = isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6);
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB);
    final textIconColor = isDark
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.85)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.80);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: chipBg,
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 14, color: textIconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textIconColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _MacroTrackCircles extends StatelessWidget {
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double proteinIntake;
  final double proteinGoal;
  final double proteinRemaining;
  final double carbsIntake;
  final double carbsGoal;
  final double carbsRemaining;
  final double fatIntake;
  final double fatGoal;
  final double fatRemaining;

  const _MacroTrackCircles({
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.proteinIntake,
    required this.proteinGoal,
    required this.proteinRemaining,
    required this.carbsIntake,
    required this.carbsGoal,
    required this.carbsRemaining,
    required this.fatIntake,
    required this.fatGoal,
    required this.fatRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _MacroCircleItem(
                label: isEs ? 'Proteínas' : 'Protein',
                intake: proteinIntake,
                goal: proteinGoal,
                remaining: proteinRemaining,
                color: const Color(0xFF10B981),
              ),
            ),
            Expanded(
              child: _MacroCircleItem(
                label: isEs ? 'Carbohidratos' : 'Carbs',
                intake: carbsIntake,
                goal: carbsGoal,
                remaining: carbsRemaining,
                color: const Color(0xFFE7A83B),
              ),
            ),
            Expanded(
              child: _MacroCircleItem(
                label: isEs ? 'Grasas' : 'Fats',
                intake: fatIntake,
                goal: fatGoal,
                remaining: fatRemaining,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroCircleItem extends StatelessWidget {
  final String label;
  final double intake;
  final double goal;
  final double remaining;
  final Color color;

  const _MacroCircleItem({
    required this.label,
    required this.intake,
    required this.goal,
    required this.remaining,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (intake / goal).clamp(0.0, 1.0);
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Track ring: visible in both themes — white at 10% in dark, black at 8% in light
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

    return Column(
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 7,
                  valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                ),
              ),
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${intake.toInt()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    'g',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          isEs
              ? '${remaining.toInt()}g restantes'
              : '${remaining.toInt()}g left',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dash = 5.0,
    this.radius = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      gap != oldDelegate.gap ||
      dash != oldDelegate.dash ||
      radius != oldDelegate.radius;
}

class _DashboardEmptyState extends StatefulWidget {
  final bool isEs;
  const _DashboardEmptyState({required this.isEs});

  @override
  State<_DashboardEmptyState> createState() => _DashboardEmptyStateState();
}

class _DashboardEmptyStateState extends State<_DashboardEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final dashedColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.25)
        : const Color(0xFFD1D5DB);
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.015);
    final iconCircleColor = isDark
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.08)
        : const Color(0xFF10B981).withValues(alpha: 0.08);
    final iconColor = isDark
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : const Color(0xFF10B981);

    return CustomPaint(
      painter: DashedRectPainter(
        color: dashedColor,
        radius: 18,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: bgColor,
        ),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconCircleColor,
                ),
                child: Icon(
                  Icons.no_meals_outlined,
                  size: 26,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isEs ? '¡Empieza a registrar!' : 'Start logging your day!',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isEs
                  ? 'Haz una foto a tu comida y la IA lo calcula todo.'
                  : 'Take a photo of your meal and AI does the rest.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
