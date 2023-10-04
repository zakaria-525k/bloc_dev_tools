import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_dev_tools/src/mappable.dart';

part 'counter_event.dart';

part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(counter: 0)) {
    on<IncrementCounterEvent>((event, emit) => emit(state.copyWith(counter: state.counter + 1)));
    on<DecrementCounterEvent>((event, emit) => emit(state.copyWith(counter: state.counter - 1)));
  }
}
