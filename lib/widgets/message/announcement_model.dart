
class AnnouncementModel{

  int announcementId;
  int adminId;
  String adminName;
  String adminImage;
  String announcementText;
  DateTime? announcementDate;


  AnnouncementModel({
    this.announcementId=0,
    required this.adminId,
    required this.adminName,
    required this.adminImage,
    required this.announcementText,
    this.announcementDate,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementId: int.parse(json['announcement_id']),
      adminId: int.parse(json['admin_id']),
      adminName: json['admin_name'],
      adminImage: json['admin_image'],
      announcementText: json['announcement_text'],
      announcementDate: DateTime.parse(json['announcement_date']),
    );
  }

  // Map<String,dynamic> toJson() =>{
  //   // 'mosque_id': mosqueId.toString(),
  //   'admin_id' : adminId.toString(),
  //   'announcement_text' : announcementText,
  // };

}
