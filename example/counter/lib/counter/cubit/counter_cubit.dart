// ignore_for_file: implementation_imports, depend_on_referenced_packages, invalid_use_of_visible_for_testing_member

import 'package:bloc/bloc.dart';

import '../bloc/counter_bloc.dart';

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(counter: 0));

  void increment() => emit(CounterState(counter: state.counter + 1));
  void decrement() => emit(CounterState(counter: state.counter - 1));
}
