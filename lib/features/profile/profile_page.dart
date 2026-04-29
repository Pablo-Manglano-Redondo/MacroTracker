import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/features/profile/presentation/widgets/bmi_overview.dart';
import 'package:macrotracker/features/profile/presentation/widgets/set_gender_dialog.dart';
import 'package:macrotracker/features/profile/presentation/widgets/set_goal_dialog.dart';
import 'package:macrotracker/features/profile/presentation/widgets/set_height_dialog.dart';
import 'package:macrotracker/features/profile/presentation/widgets/set_pal_category_dialog.dart';
import 'package:macrotracker/features/profile/presentation/widgets/set_weight_dialog.dart';
import 'package:macrotracker/generated/l10n.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    _profileBloc = locator<ProfileBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _profileBloc,
      builder: (context, state) {
        if (state is ProfileInitial) {
          _profileBloc.add(LoadProfileEvent());
          return _getLoadingContent();
        } else if (state is ProfileLoadingState) {
          return _getLoadingContent();
        } else if (state is ProfileLoadedState) {
          return _getLoadedContent(
            context,
            state.userBMI,
            state.userEntity,
            state.usesImperialUnits,
            state.dailyFocus,
            state.currentTargets,
          );
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(BuildContext context, UserBMIEntity userBMIEntity,
      UserEntity user,
      bool usesImperialUnits,
      DailyFocusEntity dailyFocus,
      GymTargetsEntity currentTargets) {
    final colorScheme = Theme.of(context).colorScheme;
    final weightLabel =
        '${_profileBloc.getDisplayWeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}';
    final heightLabel =
        '${_profileBloc.getDisplayHeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).ftLabel : S.of(context).cmLabel}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colorScheme.primaryContainer,
                  ),
                  child: Text(
                    S.of(context).profileSportsProfile,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileAvatar(imagePath: user.profileImagePath),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).profileYourProfile,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context).profileYourProfileSubtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).profileCalculationBase,
                            style:
                                Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    _ProfilePhotoMenu(
                      hasPhoto: user.profileImagePath != null &&
                          user.profileImagePath!.trim().isNotEmpty,
                      onSelected: (action) {
                        switch (action) {
                          case _ProfilePhotoAction.change:
                            _showSetProfilePhotoDialog(context, user);
                            break;
                          case _ProfilePhotoAction.remove:
                            _removeProfilePhoto(user);
                            break;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProfileSummaryChip(
                      icon: Icons.flag_outlined,
                      label: _goalChipLabel(context, user.goal),
                    ),
                    _ProfileSummaryChip(
                      icon: Icons.monitor_weight_outlined,
                      label: weightLabel,
                    ),
                    _ProfileSummaryChip(
                      icon: Icons.height_outlined,
                      label: heightLabel,
                    ),
                    _ProfileSummaryChip(
                      icon: Icons.directions_walk_outlined,
                      label: user.pal.getName(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _CurrentTargetsCard(
          goalLabel: _goalCardTitle(context, user.goal),
          goalHeadline: _goalHeadline(context, user.goal),
          macroHint: _focusHint(context, dailyFocus),
          focusLabel: dailyFocus.label,
          targets: currentTargets,
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: S.of(context).profileGoalAndStrategy,
          subtitle: S.of(context).profileGoalAndStrategySubtitle,
          icon: Icons.tune_outlined,
          children: [
            _ProfileActionTile(
              title: S.of(context).goalLabel,
              subtitle: user.goal.getName(context),
              icon: Icons.flag_outlined,
              onTap: () => _showSetGoalDialog(context, user),
            ),
            _ProfileActionTile(
              title: S.of(context).activityLabel,
              subtitle: user.pal.getName(context),
              icon: Icons.directions_walk_outlined,
              onTap: () => _showSetPALCategoryDialog(context, user),
            ),
            _ProfileActionTile(
              title: S.of(context).profileBodyProgress,
              subtitle: S.of(context).profileBodyProgressSubtitle,
              icon: Icons.show_chart_outlined,
              onTap: () {
                Navigator.of(context)
                    .pushNamed(NavigationOptions.bodyProgressRoute);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: S.of(context).profileBodyData,
          subtitle: S.of(context).profileBodyDataSubtitle,
          icon: Icons.straighten_outlined,
          children: [
            _ProfileActionTile(
              title: S.of(context).weightLabel,
              subtitle: weightLabel,
              icon: Icons.monitor_weight_outlined,
              onTap: () {
                _showSetWeightDialog(context, user, usesImperialUnits);
              },
            ),
            _ProfileActionTile(
              title: S.of(context).heightLabel,
              subtitle: heightLabel,
              icon: Icons.height_outlined,
              onTap: () {
                _showSetHeightDialog(context, user, usesImperialUnits);
              },
            ),
            _ProfileActionTile(
              title: S.of(context).ageLabel,
              subtitle: S.of(context).yearsLabel(user.age),
              icon: Icons.cake_outlined,
              onTap: () {
                _showSetBirthdayDialog(context, user);
              },
            ),
            _ProfileActionTile(
              title: S.of(context).profileGenderLabel,
              subtitle: user.gender.getName(context),
              icon: user.gender.getIcon(),
              onTap: () {
                _showSetGenderDialog(context, user);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        BMIOverview(
          bmiValue: userBMIEntity.bmiValue,
          nutritionalStatus: userBMIEntity.nutritionalStatus,
        ),
      ],
    );
  }

  Future<void> _showSetPALCategoryDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedPalCategory = await showDialog<UserPALEntity>(
        context: context,
        builder: (BuildContext context) => const SetPALCategoryDialog());
    if (selectedPalCategory != null) {
      userEntity.pal = selectedPalCategory;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetGoalDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedGoal = await showDialog<UserWeightGoalEntity>(
        context: context,
        builder: (BuildContext context) => const SetWeightGoalDialog());
    if (selectedGoal != null) {
      userEntity.goal = selectedGoal;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetHeightDialog(BuildContext context, UserEntity userEntity,
      bool usesImperialUnits) async {
    final selectedHeight = await showDialog<double>(
        context: context,
        builder: (context) => SetHeightDialog(
              userHeight: usesImperialUnits
                  ? UnitCalc.cmToFeet(userEntity.heightCM)
                  : userEntity.heightCM,
              usesImperialUnits: usesImperialUnits,
            ));
    if (selectedHeight != null) {
      if (usesImperialUnits) {
        userEntity.heightCM = UnitCalc.feetToCm(selectedHeight);
      } else {
        userEntity.heightCM = selectedHeight;
      }

      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetWeightDialog(BuildContext context, UserEntity userEntity,
      bool usesImperialSystem) async {
    final selectedWeight = await showDialog<double>(
        context: context,
        builder: (context) => SetWeightDialog(
              userWeight: usesImperialSystem
                  ? UnitCalc.kgToLbs(userEntity.weightKG)
                  : userEntity.weightKG,
              usesImperialUnits: usesImperialSystem,
            ));
    if (selectedWeight != null) {
      if (usesImperialSystem) {
        userEntity.weightKG = UnitCalc.lbsToKg(selectedWeight);
      } else {
        userEntity.weightKG = selectedWeight;
      }
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetBirthdayDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedDate = await showDatePicker(
        context: context,
        initialDate: userEntity.birthday,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (selectedDate != null) {
      userEntity.birthday = selectedDate;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetGenderDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedGender = await showDialog<UserGenderEntity>(
        context: context,
        builder: (BuildContext context) => const SetGenderDialog());
    if (selectedGender != null) {
      userEntity.gender = selectedGender;

      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetProfilePhotoDialog(
      BuildContext context, UserEntity userEntity) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }
    final path = picked.files.single.path;
    if (path == null || path.trim().isEmpty) {
      return;
    }
    userEntity.profileImagePath = path;
    _profileBloc.updateUser(userEntity);
  }

  void _removeProfilePhoto(UserEntity userEntity) {
    userEntity.profileImagePath = null;
    _profileBloc.updateUser(userEntity);
  }

  String _goalChipLabel(BuildContext context, UserWeightGoalEntity goal) {
    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        return S.of(context).profileGoalLose;
      case UserWeightGoalEntity.maintainWeight:
        return S.of(context).profileGoalMaintain;
      case UserWeightGoalEntity.gainWeight:
        return S.of(context).profileGoalGain;
    }
  }

  String _goalCardTitle(BuildContext context, UserWeightGoalEntity goal) {
    String label;
    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        label = S.of(context).profileGoalLose;
        break;
      case UserWeightGoalEntity.maintainWeight:
        label = S.of(context).profileGoalMaintain;
        break;
      case UserWeightGoalEntity.gainWeight:
        label = S.of(context).profileGoalGain;
        break;
    }
    return S.of(context).profileCurrentPhase(label);
  }

  String _goalHeadline(BuildContext context, UserWeightGoalEntity goal) {
    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        return S.of(context).profileGoalLoseDesc;
      case UserWeightGoalEntity.maintainWeight:
        return S.of(context).profileGoalMaintainDesc;
      case UserWeightGoalEntity.gainWeight:
        return S.of(context).profileGoalGainDesc;
    }
  }

  String _focusHint(BuildContext context, DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return S.of(context).profileFocusLowerBody;
      case DailyFocusEntity.upperBody:
        return S.of(context).profileFocusUpperBody;
      case DailyFocusEntity.cardio:
        return S.of(context).profileFocusCardio;
      case DailyFocusEntity.rest:
        return S.of(context).profileFocusRest;
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imagePath;

  const _ProfileAvatar({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final file = path == null || path.trim().isEmpty ? null : File(path);
    final hasValidImage = file != null && file.existsSync();

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasValidImage
          ? Image.file(file, fit: BoxFit.cover)
          : Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
                ),
                Icon(
                  Icons.account_circle_outlined,
                  size: 58,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
    );
  }
}

enum _ProfilePhotoAction {
  change,
  remove,
}

class _ProfilePhotoMenu extends StatelessWidget {
  final bool hasPhoto;
  final ValueChanged<_ProfilePhotoAction> onSelected;

  const _ProfilePhotoMenu({
    required this.hasPhoto,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_ProfilePhotoAction>(
      tooltip: S.of(context).profilePhotoOptions,
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: _ProfilePhotoAction.change,
            child: Text(S.of(context).profileChangePhoto),
          ),
          if (hasPhoto)
            PopupMenuItem(
              value: _ProfilePhotoAction.remove,
              child: Text(S.of(context).profileRemovePhoto),
            ),
        ];
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.more_horiz,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProfileSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileSummaryChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final IconData? icon;

  const _ProfileSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 18, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CurrentTargetsCard extends StatelessWidget {
  final String goalLabel;
  final String goalHeadline;
  final String macroHint;
  final String focusLabel;
  final GymTargetsEntity targets;

  const _CurrentTargetsCard({
    required this.goalLabel,
    required this.goalHeadline,
    required this.macroHint,
    required this.focusLabel,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goalHeadline,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colorScheme.tertiaryContainer,
                  ),
                  child: Text(
                    focusLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MacroMetricTile(
                    label: 'Kcal',
                    value: '${targets.kcalGoal.round()}',
                    accent: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroMetricTile(
                    label: S.of(context).proteinLabel,
                    value: '${targets.proteinGoal.round()} g',
                    accent: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MacroMetricTile(
                    label: S.of(context).carbsLabel,
                    value: '${targets.carbsGoal.round()} g',
                    accent: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroMetricTile(
                    label: S.of(context).fatLabel,
                    value: '${targets.fatGoal.round()} g',
                    accent: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.surfaceContainerHigh,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      macroHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FooterBadge(
                    icon: Icons.flag_outlined,
                    label: goalLabel.replaceFirst(S.of(context).profileCurrentPhase('').split(':')[0], '').replaceFirst(': ', ''),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FooterBadge(
                    icon: Icons.today_outlined,
                    label: focusLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MacroMetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.surfaceContainerHighest,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
