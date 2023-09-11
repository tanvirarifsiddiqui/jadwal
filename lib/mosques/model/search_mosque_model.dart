class SearchedMosque {
  String mosque_name;
  String mosque_address;
  String mosque_image;

  SearchedMosque({
    required this.mosque_name,
    required this.mosque_address,
    required this.mosque_image
  });

  factory SearchedMosque.fromJson(Map<String, dynamic> json) {
    return SearchedMosque(
        mosque_name: json['mosque_name'],
        mosque_address: json['mosque_address'],
        mosque_image: json['mosque_image']);
  }
}
