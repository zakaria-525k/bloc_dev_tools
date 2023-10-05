// ignore_for_file: implementation_imports, depend_on_referenced_packages, invalid_use_of_visible_for_testing_member

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_dev_tools/src/mappable.dart';

part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(counter: 0)) {
    on<IncrementCounterEvent>((event, emit) => emit(state.copyWith(counter: state.counter + 1)));
    on<DecrementCounterEvent>((event, emit) => emit(state.copyWith(counter: state.counter - 1)));
  }
}
