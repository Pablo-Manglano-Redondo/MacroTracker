import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:macrotracker/features/activity_detail/presentation/widgets/activity_detail_bottom_sheet.dart';
import 'package:macrotracker/features/activity_detail/presentation/widgets/activity_title_expanded.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/generated/l10n.dart';

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  static const _containerSize = 250.0;

  final log = Logger('ItemDetailScreen');
  final _scrollController = ScrollController();

  late PhysicalActivityEntity activityEntity;
  late DateTime _day;
  late TextEditingController quantityTextController;
  UserActivityEntity? _loggedActivity;

  late ActivityDetailBloc _activityDetailBloc;
  UserEntity? _currentUser;

  late double totalQuantity;
  late double totalKcal;

  @override
  void initState() {
    _activityDetailBloc = locator<ActivityDetailBloc>();
    quantityTextController = TextEditingController();
    quantityTextController.text = "60";
    totalQuantity = 60;
    totalKcal = 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments
        as ActivityDetailScreenArguments;
    activityEntity = args.activityEntity;
    _day = args.day;
    _loggedActivity = args.userActivityEntity;
    if (_loggedActivity != null) {
      quantityTextController.text =
          _formatInitialDuration(_loggedActivity!.duration);
      totalQuantity = _loggedActivity!.duration;
      totalKcal = _loggedActivity!.burnedKcal;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ActivityDetailBloc, ActivityDetailState>(
        bloc: _activityDetailBloc,
        builder: (context, state) {
          if (state is ActivityDetailInitial) {
            _activityDetailBloc
                .add(LoadActivityDetailEvent(context, activityEntity));
            return getLoadingContent();
          } else if (state is ActivityDetailLoadingState) {
            return getLoadingContent();
          } else if (state is ActivityDetailLoadedState) {
            _currentUser = state.userEntity;
            if (_loggedActivity == null && totalKcal == 0) {
              totalKcal = state.totalKcalBurned;
            }
            return getLoadedContent(state.totalKcalBurned, state.userEntity);
          } else {
            return const SizedBox();
          }
        },
      ),
      bottomSheet: _loggedActivity == null
          ? ActivityDetailBottomSheet(
              onAddButtonPressed: onAddButtonPressed,
              onQuantityChanged: (value) {
                final user = _currentUser;
                if (user == null) {
                  return;
                }
                _onQuantityChanged(value, user);
              },
              quantityTextController: quantityTextController,
              activityEntity: activityEntity,
              activityDetailBloc: _activityDetailBloc,
            )
          : null,
    );
  }

  Widget getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget getLoadedContent(double totalKcalBurned, UserEntity userEntity) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                final barsHeight =
                    MediaQuery.of(context).padding.top + kToolbarHeight;
                const offset = 10;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1, // don't scale title
                  background: ActivityTitleExpanded(activity: activityEntity),
                  title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(activityEntity.getName(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                            : const SizedBox(),
                  ),
                );
              },
            )),
        SliverList(
            delegate: SliverChildListDelegate([
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Container(
                width: _containerSize,
                height: _containerSize,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer),
                child: Icon(
                  activityEntity.displayIcon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loggedActivity != null) ...[
                  _LoggedActivitySummaryCard(activity: _loggedActivity!),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    // set Focus
                    Text('~${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(' / ${totalQuantity.toInt()} ${S.of(context).minutesLabel}')
                  ],
                ),
                const SizedBox(height: 8.0),
                const Divider(),
                const SizedBox(height: 16.0),
                _ActivityMetricsCard(
                  activityEntity: activityEntity,
                  durationMinutes: _loggedActivity?.duration ?? totalQuantity,
                  burnedKcal: _loggedActivity?.burnedKcal ?? totalKcal,
                ),
                const SizedBox(height: 200.0) // height added to scroll
              ],
            ),
          )
        ]))
      ],
    );
  }

  void _onQuantityChanged(String quantityString, UserEntity userEntity) async {
    try {
      final newQuantity = double.parse(quantityString);
      final newTotalKcal = _activityDetailBloc.getTotalKcalBurned(
          userEntity, activityEntity, newQuantity);
      setState(() {
        totalQuantity = newQuantity;
        totalKcal = newTotalKcal;
        scrollToCalorieText();
      });
    } on FormatException catch (_) {
      log.warning("Error while parsing: \"$quantityString\"");
    }
  }

  String _formatInitialDuration(double duration) {
    return duration % 1 == 0
        ? duration.toStringAsFixed(0)
        : duration.toString();
  }

  void scrollToCalorieText() {
    _scrollController.animateTo(_containerSize,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  void onAddButtonPressed(BuildContext context) {
    _activityDetailBloc.persistActivity(
        context, quantityTextController.text, totalKcal, activityEntity, _day);

    // Refresh Home Page
    locator<HomeBloc>().add(const LoadItemsEvent());

    // Refresh Diary Page
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    // Show snackbar and return to dashboard
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).infoAddedActivityLabel)));
    Navigator.of(context)
        .popUntil(ModalRoute.withName(NavigationOptions.mainRoute));
  }
}

class ActivityDetailScreenArguments {
  final PhysicalActivityEntity activityEntity;
  final DateTime day;
  final UserActivityEntity? userActivityEntity;

  ActivityDetailScreenArguments(this.activityEntity, this.day,
      {this.userActivityEntity});
}

class _LoggedActivitySummaryCard extends StatelessWidget {
  final UserActivityEntity activity;

  const _LoggedActivitySummaryCard({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).loggedEntryDetailsLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActivityDetailPill(
                icon: Icons.schedule_outlined,
                label: DateFormat.Hm().format(activity.date),
              ),
              _ActivityDetailPill(
                icon: Icons.timer_outlined,
                label: '${activity.duration.toStringAsFixed(0)} ${S.of(context).minutesLabel}',
              ),
              _ActivityDetailPill(
                icon: Icons.local_fire_department_outlined,
                label: '${activity.burnedKcal.toStringAsFixed(0)} kcal',
              ),
              _ActivityDetailPill(
                icon: activity.source == UserActivitySourceEntity.healthConnect
                    ? Icons.health_and_safety_outlined
                    : Icons.edit_outlined,
                label: activity.source == UserActivitySourceEntity.healthConnect
                    ? (Platform.isIOS
                        ? S.of(context).appleHealthLabel
                        : S.of(context).habitSourceHealthConnect)
                    : S.of(context).habitSourceManual,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityMetricsCard extends StatelessWidget {
  final PhysicalActivityEntity activityEntity;
  final double durationMinutes;
  final double burnedKcal;

  const _ActivityMetricsCard({
    required this.activityEntity,
    required this.durationMinutes,
    required this.burnedKcal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.38),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).activitySummaryLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricStat(
                  label: S.of(context).durationLabel,
                  value:
                      '${durationMinutes.toStringAsFixed(0)} ${S.of(context).minutesLabel}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricStat(
                  label: S.of(context).kcalLabel,
                  value: burnedKcal.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricStat(
                  label: S.of(context).activityMetLabel,
                  value: activityEntity.mets.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activityEntity.getDescription(context),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetricStat extends StatelessWidget {
  final String label;
  final String value;

  const _MetricStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDetailPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActivityDetailPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
