
class AdminNotificationModel{

  int userId;
  String userImage;
  String notificationText;
  DateTime notificationDate;


  AdminNotificationModel({
    required this.userId,
    required this.userImage,
    required this.notificationText,
    required this.notificationDate,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      userId: int.parse(json['user_id']),
      userImage: json['user_image'],
      notificationText: json['message'],
      notificationDate: DateTime.parse(json['created_at']),
    );
  }


}
