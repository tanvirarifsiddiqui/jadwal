
class ConnectorsModel{

  int userId;
  String userName;
  String userImage;
  String userAddress;
  DateTime connectedAt;


  ConnectorsModel({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.userAddress,
    required this.connectedAt,
  });

  factory ConnectorsModel.fromJson(Map<String, dynamic> json) {
    return ConnectorsModel(
      userId: int.parse(json['user_id']),
      userImage: json['user_image'],
      userName: json['user_name'],
      userAddress: json['user_address'],
      connectedAt: DateTime.parse(json['connected_at']),
    );
  }

}
