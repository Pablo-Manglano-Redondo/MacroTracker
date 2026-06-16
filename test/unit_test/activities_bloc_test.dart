import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_activity/presentation/bloc/activities_bloc.dart';
import 'package:macrotracker/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';

void main() {
  late ActivitiesBloc bloc;
  late _FakeGetPhysicalActivityUsecase fakeGetPhysicalActivityUsecase;
  late _FakeBuildContext fakeContext;

  final activity1 = const PhysicalActivityEntity(
    'hc:1',
    'Cycling moderate',
    'Moderate cycling on flat road',
    8.0,
    [],
    PhysicalActivityTypeEntity.bicycling,
  );

  final activity2 = const PhysicalActivityEntity(
    'hc:2',
    'Running fast',
    'Vigorous pace running',
    12.0,
    [],
    PhysicalActivityTypeEntity.running,
  );

  setUp(() {
    fakeGetPhysicalActivityUsecase = _FakeGetPhysicalActivityUsecase();
    fakeContext = _FakeBuildContext();
    bloc = ActivitiesBloc(fakeGetPhysicalActivityUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is ActivitiesInitial', () {
    expect(bloc.state, isA<ActivitiesInitial>());
  });

  group('LoadActivitiesEvent', () {
    test('emits ActivitiesLoadingState and ActivitiesLoadedState with list of activities', () async {
      fakeGetPhysicalActivityUsecase.activities = [activity1, activity2];

      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadActivitiesEvent(context: fakeContext));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        ActivitiesLoadedState(activities: [activity1, activity2]),
      ]);
      expect(bloc.physicalActivities, [activity1, activity2]);
    });

    test('emits ActivitiesLoadingState and ActivitiesFailedState on exception', () async {
      fakeGetPhysicalActivityUsecase.shouldThrow = true;

      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadActivitiesEvent(context: fakeContext));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        isA<ActivitiesFailedState>(),
      ]);
    });
  });

  group('SearchActivitiesEvent', () {
    setUp(() async {
      // First populate physicalActivities list inside the bloc
      fakeGetPhysicalActivityUsecase.activities = [activity1, activity2];
      bloc.add(LoadActivitiesEvent(context: fakeContext));
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('returns all activities if search query is empty', () async {
      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(SearchActivitiesEvent(context: fakeContext, searchString: ''));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        ActivitiesLoadedState(activities: [activity1, activity2]),
      ]);
    });

    test('filters activities by matching specificActivity name (case-insensitive)', () async {
      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(SearchActivitiesEvent(context: fakeContext, searchString: 'cycling'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        ActivitiesLoadedState(activities: [activity1]),
      ]);
    });

    test('filters activities by matching description (case-insensitive)', () async {
      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(SearchActivitiesEvent(context: fakeContext, searchString: 'vigorous'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        ActivitiesLoadedState(activities: [activity2]),
      ]);
    });

    test('emits ActivitiesLoadingState and ActivitiesFailedState on exception', () async {
      // We can trigger an exception by making event.context fail during getName/getDescription calls
      // since our fakeContext's noSuchMethod throws, if we pass a context that fails or trigger an error by other means.
      // Wait, let's see. In ActivitiesBloc, SearchActivitiesEvent does:
      // activity.getName(event.context)
      // Since event.context in this test is _FakeBuildContext, if we pass a custom context that throws on getName, it will catch the error.
      // Wait, _FakeBuildContext implements BuildContext, but if any method is called on it, noSuchMethod gets called, which throws NoSuchMethodError by default!
      // But for activity1 (which code starts with 'hc:'), activity1.getName(context) does NOT call any methods on the context! It returns specificActivity directly.
      // However, if we use a non-'hc:' code (like '01015'), getName will call S.of(context) which calls Localizations.of(...) on context, which calls methods on context, thus triggering a NoSuchMethodError!
      // Let's create an activity with non-'hc:' code to verify exception handling!
      final nonHcActivity = const PhysicalActivityEntity(
        '01015',
        'Moderate bicycling',
        'Description',
        8.0,
        [],
        PhysicalActivityTypeEntity.bicycling,
      );

      // Re-populate with non-hc activity
      fakeGetPhysicalActivityUsecase.activities = [nonHcActivity];
      bloc.add(LoadActivitiesEvent(context: fakeContext));
      await Future.delayed(const Duration(milliseconds: 10));

      final states = <ActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(SearchActivitiesEvent(context: fakeContext, searchString: 'test'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ActivitiesLoadingState>(),
        isA<ActivitiesFailedState>(),
      ]);
    });
  });
}

class _FakeGetPhysicalActivityUsecase implements GetPhysicalActivityUsecase {
  List<PhysicalActivityEntity> activities = [];
  bool shouldThrow = false;

  @override
  Future<List<PhysicalActivityEntity>> getAllPhysicalActivities() async {
    if (shouldThrow) {
      throw Exception('Failed to load activities');
    }
    return activities;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
