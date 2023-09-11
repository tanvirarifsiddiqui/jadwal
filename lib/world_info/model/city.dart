class CityOfState {
  final int id;
  final String name;

  CityOfState({
    required this.id,
    required this.name,
  });

  factory CityOfState.fromJson(Map<String, dynamic> json) {
    return CityOfState(
      id: int.parse(json['id']),
      name: json['name'],
    );
  }
}