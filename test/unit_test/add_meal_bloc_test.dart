import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/add_meal_bloc.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';

void main() {
  late AddMealBloc bloc;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;

  setUp(() {
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    bloc = AddMealBloc(fakeGetConfigUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is AddMealInitialState', () {
    expect(bloc.state, isA<AddMealInitialState>());
  });

  group('InitializeAddMealEvent', () {
    test('emits AddMealLoadingState and AddMealLoadedState with correct config properties', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: true,
      );

      final states = <AddMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const InitializeAddMealEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<AddMealLoadingState>(),
        const AddMealLoadedState(usesImperialUnits: true),
      ]);
    });
  });
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
    usesImperialUnits: false,
  );

  @override
  Future<ConfigEntity> getConfig() async => config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
