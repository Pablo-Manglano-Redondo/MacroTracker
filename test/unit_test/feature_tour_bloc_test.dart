import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/features/feature_tour/presentation/bloc/feature_tour_bloc.dart';

void main() {
  late FeatureTourBloc bloc;
  late _FakeBox fakeBox;

  setUp(() {
    fakeBox = _FakeBox();
    bloc = FeatureTourBloc(fakeBox);
  });

  test('initial state has currentSlideIndex = 0 and isCompleted = false', () {
    expect(bloc.state.currentSlideIndex, 0);
    expect(bloc.state.isCompleted, false);
  });

  group('LoadFeatureTourEvent', () {
    test('loads completion state from box', () {
      fakeBox.put('has_completed_feature_tour', true);
      bloc.add(LoadFeatureTourEvent());

      // We wait for microtasks to run
      expect(bloc.state.isCompleted, false); // initial before processing event
      
      // Let bloc process
      expect(
        bloc.stream,
        emitsInOrder([
          const FeatureTourState(currentSlideIndex: 0, isCompleted: true),
        ]),
      );
    });
  });

  group('NextSlideEvent and PrevSlideEvent', () {
    test('increments slide index on NextSlideEvent and decrements on PrevSlideEvent', () async {
      final states = <FeatureTourState>[];
      bloc.stream.listen(states.add);

      bloc.add(NextSlideEvent()); // 0 -> 1
      await Future.delayed(Duration.zero);
      bloc.add(NextSlideEvent()); // 1 -> 2
      await Future.delayed(Duration.zero);
      bloc.add(PrevSlideEvent()); // 2 -> 1
      await Future.delayed(Duration.zero);

      expect(states, [
        const FeatureTourState(currentSlideIndex: 1, isCompleted: false),
        const FeatureTourState(currentSlideIndex: 2, isCompleted: false),
        const FeatureTourState(currentSlideIndex: 1, isCompleted: false),
      ]);
    });

    test('completes and writes to Box on NextSlideEvent from slide 12', () async {
      // Set state index to 12
      for (int i = 0; i < 12; i++) {
        bloc.add(NextSlideEvent());
        await Future.delayed(Duration.zero);
      }
      expect(bloc.state.currentSlideIndex, 12);

      final states = <FeatureTourState>[];
      bloc.stream.listen(states.add);

      bloc.add(NextSlideEvent()); // 12 -> complete
      await Future.delayed(Duration.zero);

      expect(states, [
        const FeatureTourState(currentSlideIndex: 12, isCompleted: true),
      ]);
      expect(fakeBox.get('has_completed_feature_tour'), true);
    });
  });

  group('SkipTourEvent', () {
    test('sets index to 12, writes completed flag, and completes tour', () async {
      final states = <FeatureTourState>[];
      bloc.stream.listen(states.add);

      bloc.add(SkipTourEvent());
      await Future.delayed(Duration.zero);

      expect(states, [
        const FeatureTourState(currentSlideIndex: 12, isCompleted: true),
      ]);
      expect(fakeBox.get('has_completed_feature_tour'), true);
    });
  });

  group('LoadFeatureTourEvent with force', () {
    test('resets completed state when force is true', () async {
      fakeBox.put('has_completed_feature_tour', true);
      bloc.add(const LoadFeatureTourEvent(force: true));

      expect(
        bloc.stream,
        emitsInOrder([
          const FeatureTourState(currentSlideIndex: 0, isCompleted: false),
        ]),
      );
      await Future.delayed(Duration.zero);
      expect(fakeBox.get('has_completed_feature_tour'), false);
    });
  });
}

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
