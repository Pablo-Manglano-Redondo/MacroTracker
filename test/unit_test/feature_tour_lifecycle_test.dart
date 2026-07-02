import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:macrotracker/features/feature_tour/presentation/bloc/feature_tour_bloc.dart';
import 'package:hive/hive.dart';

class _FakeBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _values = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    return _values[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final getIt = GetIt.asNewInstance();

  setUp(() {
    getIt.registerLazySingleton<FeatureTourBloc>(
      () => FeatureTourBloc(_FakeBox()),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('FeatureTourBloc remains open when resolved multiple times (singleton lifecycle)', () async {
    // First resolution, verify it is open
    final bloc1 = getIt<FeatureTourBloc>();
    expect(bloc1.isClosed, false);

    // Add an event to ensure it receives events
    bloc1.add(const LoadFeatureTourEvent());
    await Future.delayed(Duration.zero);
    expect(bloc1.state.currentSlideIndex, 0);

    // Second resolution (simulating a screen recreation/re-resolution from locator)
    final bloc2 = getIt<FeatureTourBloc>();
    expect(bloc2.isClosed, false);
    expect(bloc2, same(bloc1)); // verify it's the exact same singleton instance

    // Verify it still responds to events successfully
    bloc2.add(NextSlideEvent());
    await Future.delayed(Duration.zero);
    expect(bloc2.state.currentSlideIndex, 1);
  });
}
