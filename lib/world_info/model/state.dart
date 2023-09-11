class StateOfCountry {
  final int id;
  final String name;

  StateOfCountry({
    required this.id,
    required this.name,
  });

  factory StateOfCountry.fromJson(Map<String, dynamic> json) {
    return StateOfCountry(
      id: int.parse(json['id']),
      name: json['name'],
    );
  }
}
