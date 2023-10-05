part of 'counter_bloc.dart';

class CounterState extends Equatable implements MappableToJson, MappableFromJson {
  final int counter;

  const CounterState({
    required this.counter,
  });

  CounterState copyWith({
    int? counter,
  }) =>
      CounterState(
        counter: counter ?? this.counter,
      );

  @override
  List<Object> get props => [
        counter,
      ];

  @override
  Map<String, dynamic> toJson() => {
        'counter': counter,
      };

  @override
  CounterState fromJson(Map<String, dynamic> json) {
    return CounterState(counter: json['counter']);
  }
}
