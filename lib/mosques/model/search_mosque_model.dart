
class SearchedMosque {
  int mosque_id;
  String mosque_name;
  String mosque_address;
  String mosque_image;
  String connectors;

  SearchedMosque({
    required this.mosque_id,
    required this.mosque_name,
    required this.mosque_address,
    required this.mosque_image,
    required this.connectors
  });

  factory SearchedMosque.fromJson(Map<String, dynamic> json) {
    return SearchedMosque(
        mosque_id: int.parse(json['mosque_id']),
        mosque_name: json['mosque_name'],
        mosque_address: json['mosque_address'],
        mosque_image: json['mosque_image'],
        connectors: json['connectors']);
  }
}
