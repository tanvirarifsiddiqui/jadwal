
class SearchedMosque {
  String mosque_name;
  String mosque_address;
  String mosque_image;
  bool isConnectedByUser;

  SearchedMosque({
    required this.mosque_name,
    required this.mosque_address,
    required this.mosque_image,
    required this.isConnectedByUser
  });

  factory SearchedMosque.fromJson(Map<String, dynamic> json) {
    return SearchedMosque(
        mosque_name: json['mosque_name'],
        mosque_address: json['mosque_address'],
        mosque_image: json['mosque_image'],
        isConnectedByUser: false);
  }
}
