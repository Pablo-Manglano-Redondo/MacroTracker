import 'package:flutter/material.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_activity_selection_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class OnboardingThirdPageBody extends StatefulWidget {
  final Function(bool active, UserActivitySelectionEntity? selectedActivity)
      setButtonContent;

  const OnboardingThirdPageBody({super.key, required this.setButtonContent});

  @override
  State<OnboardingThirdPageBody> createState() =>
      _OnboardingThirdPageBodyState();
}

class _OnboardingThirdPageBodyState extends State<OnboardingThirdPageBody> {
  bool _sedentarySelected = false;
  bool _lowActiveSelected = false;
  bool _activeSelected = false;
  bool _veryActiveSelected = false;

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
          Text(S.of(context).activityLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingActivityQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          _buildActivityCard(
            context: context,
            title: S.of(context).palSedentaryLabel,
            description: S.of(context).palSedentaryDescriptionLabel,
            isSelected: _sedentarySelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(sedentary: true);
                checkCorrectInput();
              });
            },
          ),
          _buildActivityCard(
            context: context,
            title: S.of(context).palLowLActiveLabel,
            description: S.of(context).palLowActiveDescriptionLabel,
            isSelected: _lowActiveSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(lowActive: true);
                checkCorrectInput();
              });
            },
          ),
          _buildActivityCard(
            context: context,
            title: S.of(context).palActiveLabel,
            description: S.of(context).palActiveDescriptionLabel,
            isSelected: _activeSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(active: true);
                checkCorrectInput();
              });
            },
          ),
          _buildActivityCard(
            context: context,
            title: S.of(context).palVeryActiveLabel,
            description: S.of(context).palVeryActiveDescriptionLabel,
            isSelected: _veryActiveSelected,
            onTap: () {
              setState(() {
                _setSelectedChoiceChip(veryActive: true);
                checkCorrectInput();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required String title,
    required String description,
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
                margin: const EdgeInsets.only(top: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 2.0,
                  ),
                ),
                width: 20,
                height: 20,
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.white,
                        ),
                      )
                    : null,
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
      {sedentary = false,
      lowActive = false,
      active = false,
      veryActive = false}) {
    _sedentarySelected = sedentary;
    _lowActiveSelected = lowActive;
    _activeSelected = active;
    _veryActiveSelected = veryActive;
  }

  void checkCorrectInput() {
    UserActivitySelectionEntity? selectedActivity;
    if (_sedentarySelected) {
      selectedActivity = UserActivitySelectionEntity.sedentary;
    } else if (_lowActiveSelected) {
      selectedActivity = UserActivitySelectionEntity.lowActive;
    } else if (_activeSelected) {
      selectedActivity = UserActivitySelectionEntity.active;
    } else if (_veryActiveSelected) {
      selectedActivity = UserActivitySelectionEntity.veryActive;
    }

    if (selectedActivity != null) {
      widget.setButtonContent(true, selectedActivity);
    } else {
      widget.setButtonContent(false, null);
    }
  }
}
