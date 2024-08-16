part of 'counter_bloc.dart';

abstract class CounterEvent extends Equatable implements MappableToJson<CounterEvent> {
  const CounterEvent();

  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() => {};
}

class IncrementCounterEvent extends CounterEvent {}

class DecrementCounterEvent extends CounterEvent {}
