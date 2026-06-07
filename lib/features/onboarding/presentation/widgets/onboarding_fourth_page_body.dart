import 'package:flutter/material.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class OnboardingFourthPageBody extends StatefulWidget {
  final Function(bool active, UserGoalSelectionEntity? selectedGoal)
      setButtonContent;

  const OnboardingFourthPageBody({super.key, required this.setButtonContent});

  @override
  State<OnboardingFourthPageBody> createState() =>
      _OnboardingFourthPageBodyState();
}

class _OnboardingFourthPageBodyState extends State<OnboardingFourthPageBody> {
  bool _looseWeightSelected = false;
  bool _maintainWeightSelected = false;
  bool _gainWeightSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).goalLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingGoalQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          _buildGoalCard(
            context: context,
            title: S.of(context).goalLoseWeight,
            description: S.of(context).profileGoalLoseDesc,
            icon: Icons.trending_down_rounded,
            color: const Color(0xFFE15A5A), // Coral/Red
            isSelected: _looseWeightSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(looseWeight: true);
                _checkCorrectInput();
              });
            },
          ),
          _buildGoalCard(
            context: context,
            title: S.of(context).goalMaintainWeight,
            description: S.of(context).profileGoalMaintainDesc,
            icon: Icons.trending_flat_rounded,
            color: const Color(0xFFE7A83B), // Amber/Yellow
            isSelected: _maintainWeightSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(maintainWeigh: true);
                _checkCorrectInput();
              });
            },
          ),
          _buildGoalCard(
            context: context,
            title: S.of(context).goalGainWeight,
            description: S.of(context).profileGoalGainDesc,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF33E36A), // Emerald/Green
            isSelected: _gainWeightSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(gainWeight: true);
                _checkCorrectInput();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12.0),
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.18)
          : colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setSelectedChoiceChip(
      {looseWeight = false, maintainWeigh = false, gainWeight = false}) {
    _looseWeightSelected = looseWeight;
    _maintainWeightSelected = maintainWeigh;
    _gainWeightSelected = gainWeight;
  }

  void _checkCorrectInput() {
    UserGoalSelectionEntity? selectedGoal;
    if (_looseWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.loseWeight;
    } else if (_maintainWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.maintainWeight;
    } else if (_gainWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.gainWeigh;
    }

    if (selectedGoal != null) {
      widget.setButtonContent(true, selectedGoal);
    } else {
      widget.setButtonContent(false, null);
    }
  }
}
