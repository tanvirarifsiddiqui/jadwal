
class UserNotificationModel{

  int adminId;
  int mosqueId;
  String adminImage;
  String mosqueName;
  String mosqueImage;
  String notificationText;
  DateTime notificationDate;


  UserNotificationModel({
    required this.adminId,
    required this.mosqueId,
    required this.adminImage,
    required this.mosqueName,
    required this.mosqueImage,
    required this.notificationText,
    required this.notificationDate,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationModel(
      adminId: int.parse(json['admin_id']),
      mosqueId: int.parse(json['mosque_id']),
      adminImage: json['admin_image'],
      mosqueName: json['mosque_name'],
      mosqueImage: json['mosque_image'],
      notificationText: json['message'],
      notificationDate: DateTime.parse(json['created_at']),
    );
  }

}
