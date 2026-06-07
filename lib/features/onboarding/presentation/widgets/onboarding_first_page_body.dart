import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_gender_selection_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class OnboardingFirstPageBody extends StatefulWidget {
  final Function(
          bool active, UserGenderSelectionEntity? gender, DateTime? birthday)
      setPageContent;

  const OnboardingFirstPageBody({super.key, required this.setPageContent});

  @override
  State<OnboardingFirstPageBody> createState() =>
      _OnboardingFirstPageBodyState();
}

class _OnboardingFirstPageBodyState extends State<OnboardingFirstPageBody> {
  final _dateInput = TextEditingController();
  DateTime? _selectedDate;

  bool _maleSelected = false;
  bool _femaleSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).genderLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingGenderQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  label: S.of(context).genderMaleLabel,
                  icon: Icons.male_rounded,
                  isSelected: _maleSelected,
                  onTap: () {
                    setState(() {
                      _maleSelected = true;
                      _femaleSelected = false;
                      checkCorrectInput();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _buildGenderCard(
                  context: context,
                  label: S.of(context).genderFemaleLabel,
                  icon: Icons.female_rounded,
                  isSelected: _femaleSelected,
                  onTap: () {
                    setState(() {
                      _maleSelected = false;
                      _femaleSelected = true;
                      checkCorrectInput();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          Text(S.of(context).ageLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingBirthdayQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _dateInput,
            readOnly: true,
            decoration: InputDecoration(
              hintText: S.of(context).onboardingEnterBirthdayLabel,
              labelText: S.of(context).onboardingEnterBirthdayLabel,
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onTap: onDateInputClicked,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 38,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDateInputClicked() async {
    final now = DateTime.now();
    final latestBirthDate = DateTime(now.year - 13, now.month, now.day);
    final initialDate = _selectedDate ?? DateTime(now.year - 25, now.month, now.day);
    
    DateTime tempDate = initialDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        S.of(context).dialogCancelLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempDate;
                          _dateInput.text = DateFormat('yyyy-MM-dd').format(tempDate);
                          checkCorrectInput();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.of(context).dialogOKLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate.isAfter(latestBirthDate) ? latestBirthDate : tempDate,
                    minimumDate: DateTime(now.year - 100, now.month, now.day),
                    maximumDate: latestBirthDate,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempDate = newDateTime;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkCorrectInput() {
    UserGenderSelectionEntity? selectedGender;
    if (_maleSelected) {
      selectedGender = UserGenderSelectionEntity.genderMale;
    } else if (_femaleSelected) {
      selectedGender = UserGenderSelectionEntity.genderFemale;
    }

    if (selectedGender != null && _selectedDate != null) {
      widget.setPageContent(true, selectedGender, _selectedDate);
    } else {
      widget.setPageContent(false, null, null);
    }
  }
}
