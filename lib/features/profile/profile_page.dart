import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return _getLoadedContent(context, state.userBMI, state.userEntity,
              state.usesImperialUnits);
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
      UserEntity user, bool usesImperialUnits) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ProfileAvatar(imagePath: user.profileImagePath),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile photo',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set your own avatar for a more personal dashboard.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                _showSetProfilePhotoDialog(context, user),
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Choose photo'),
                          ),
                          if (user.profileImagePath != null &&
                              user.profileImagePath!.trim().isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => _removeProfilePhoto(user),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        BMIOverview(
          bmiValue: userBMIEntity.bmiValue,
          nutritionalStatus: userBMIEntity.nutritionalStatus,
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: 'Targets',
          subtitle: 'Set the intake strategy that drives the rest of the app.',
          children: [
            _ProfileActionTile(
              title: S.of(context).activityLabel,
              subtitle: user.pal.getName(context),
              icon: Icons.directions_walk_outlined,
              onTap: () => _showSetPALCategoryDialog(context, user),
            ),
            _ProfileActionTile(
              title: S.of(context).goalLabel,
              subtitle: user.goal.getName(context),
              icon: Icons.flag_outlined,
              onTap: () => _showSetGoalDialog(context, user),
            ),
            _ProfileActionTile(
              title: 'Body progress',
              subtitle: 'Weight trend, 7d average and waist check-ins',
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
          title: 'Body stats',
          subtitle: 'Keep the baseline numbers current so targets stay usable.',
          children: [
            _ProfileActionTile(
              title: S.of(context).weightLabel,
              subtitle:
                  '${_profileBloc.getDisplayWeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}',
              icon: Icons.monitor_weight_outlined,
              onTap: () {
                _showSetWeightDialog(context, user, usesImperialUnits);
              },
            ),
            _ProfileActionTile(
              title: S.of(context).heightLabel,
              subtitle:
                  '${_profileBloc.getDisplayHeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).ftLabel : S.of(context).cmLabel}',
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
          ],
        ),
        const SizedBox(height: 16),
        _ProfileSectionCard(
          title: 'Profile',
          subtitle: 'Keep personal context aligned with the formulas.',
          children: [
            _ProfileActionTile(
              title: S.of(context).genderLabel,
              subtitle: user.gender.getName(context),
              icon: user.gender.getIcon(),
              onTap: () {
                _showSetGenderDialog(context, user);
              },
            ),
          ],
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
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasValidImage
          ? Image.file(file, fit: BoxFit.cover)
          : Icon(
              Icons.account_circle_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _ProfileSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.surfaceContainerHigh,
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
