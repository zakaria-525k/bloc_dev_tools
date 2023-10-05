abstract class MappableToJson<State> {
  Map<String, dynamic> toJson();
}

abstract class MappableFromJson<State> {
  State fromJson(Map<String, dynamic> json);
}
