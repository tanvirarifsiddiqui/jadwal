
class UserNotificationModel{

  int adminId;
  int mosqueId;
  String adminName;
  String adminImage;
  String mosqueName;
  String mosqueImage;
  String notificationText;
  DateTime notificationDate;


  UserNotificationModel({
    required this.adminId,
    required this.mosqueId,
    required this.adminName,
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
      adminName: json['admin_name'],
      adminImage: json['admin_image'],
      mosqueName: json['mosque_name'],
      mosqueImage: json['mosque_image'],
      notificationText: json['message'],
      notificationDate: DateTime.parse(json['created_at']),
    );
  }

// Map<String,dynamic> toJson() =>{
//   // 'mosque_id': mosqueId.toString(),
//   'admin_id' : adminId.toString(),
//   'announcement_text' : announcementText,
// };

}
