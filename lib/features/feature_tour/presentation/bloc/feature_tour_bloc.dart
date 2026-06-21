import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'feature_tour_event.dart';
part 'feature_tour_state.dart';

class FeatureTourBloc extends Bloc<FeatureTourEvent, FeatureTourState> {
  final Box<dynamic> _monetizationBox;

  FeatureTourBloc(this._monetizationBox) : super(FeatureTourState.initial()) {
    on<LoadFeatureTourEvent>((event, emit) async {
      final isCompleted = event.force
          ? false
          : (_monetizationBox.get('has_completed_feature_tour', defaultValue: false) as bool);
      if (event.force) {
        await _monetizationBox.put('has_completed_feature_tour', false);
      }
      emit(state.copyWith(isCompleted: isCompleted, currentSlideIndex: 0));
    });

    on<NextSlideEvent>((event, emit) async {
      if (state.currentSlideIndex < 12) {
        emit(state.copyWith(currentSlideIndex: state.currentSlideIndex + 1));
      } else {
        await _monetizationBox.put('has_completed_feature_tour', true);
        emit(state.copyWith(isCompleted: true));
      }
    });

    on<PrevSlideEvent>((event, emit) {
      if (state.currentSlideIndex > 0) {
        emit(state.copyWith(currentSlideIndex: state.currentSlideIndex - 1));
      }
    });

    on<SkipTourEvent>((event, emit) async {
      await _monetizationBox.put('has_completed_feature_tour', true);
      emit(state.copyWith(isCompleted: true, currentSlideIndex: 12));
    });
  }
}
