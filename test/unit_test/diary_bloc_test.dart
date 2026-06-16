import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';

void main() {
  late DiaryBloc bloc;
  late _FakeGetTrackedDayUsecase fakeGetTrackedDayUsecase;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;
  late _FakeHomeBloc fakeHomeBloc;

  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
  });

  setUp(() {
    fakeGetTrackedDayUsecase = _FakeGetTrackedDayUsecase();
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    fakeHomeBloc = _FakeHomeBloc();

    bloc = DiaryBloc(fakeGetTrackedDayUsecase, fakeGetConfigUsecase);

    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
  });

  tearDown(() async {
    await bloc.close();
    await fakeHomeBloc.close();
    await locator.reset();
  });

  test('initial state is DiaryInitial', () {
    expect(bloc.state, isA<DiaryInitial>());
  });

  group('LoadDiaryYearEvent', () {
    test('emits DiaryLoadingState and DiaryLoadedState with correct data map', () async {
      final now = DateTime.now();
      final day1 = now.subtract(const Duration(days: 2));
      final day2 = now.add(const Duration(days: 2));

      final mockDay1 = TrackedDayEntity(
        day: day1,
        calorieGoal: 2000,
        caloriesTracked: 1800,
      );
      final mockDay2 = TrackedDayEntity(
        day: day2,
        calorieGoal: 2200,
        caloriesTracked: 2100,
      );

      fakeGetTrackedDayUsecase.returnedDays = [mockDay1, mockDay2];
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: true,
      );

      final states = <DiaryState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadDiaryYearEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<DiaryLoadingState>(),
        isA<DiaryLoadedState>(),
      ]);

      final loadedState = states.last as DiaryLoadedState;
      expect(loadedState.usesImperialUnits, true);
      expect(loadedState.trackedDayMap.length, 2);
      expect(loadedState.trackedDayMap[day1.toParsedDay()], mockDay1);
      expect(loadedState.trackedDayMap[day2.toParsedDay()], mockDay2);
    });
  });

  group('updateHomePage', () {
    test('sends LoadItemsEvent to HomeBloc', () {
      bloc.updateHomePage();

      expect(fakeHomeBloc.addedEvents, [const LoadItemsEvent()]);
    });
  });
}

class _FakeGetTrackedDayUsecase implements GetTrackedDayUsecase {
  List<TrackedDayEntity> returnedDays = [];

  @override
  Future<List<TrackedDayEntity>> getTrackedDaysByRange(DateTime start, DateTime end) async {
    return returnedDays;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
  );

  @override
  Future<ConfigEntity> getConfig() async => config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  final List<HomeEvent> addedEvents = [];

  _FakeHomeBloc() : super(HomeInitial());

  @override
  void add(HomeEvent event) {
    addedEvents.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
