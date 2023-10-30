class MosqueChatModel {
  int mosque_id;
  String mosque_name;
  String mosque_image;
  String last_admin_name;
  String last_announcement_text;
  DateTime announcementDate;


  MosqueChatModel({
    required this.mosque_id,
    required this.mosque_name,
    required this.mosque_image,
    required this.last_admin_name,
    required this.last_announcement_text,
    required this.announcementDate,

  });

  factory MosqueChatModel.fromJson(Map<String, dynamic> json) {
    return MosqueChatModel(
        mosque_id: int.parse(json['mosque_id']),
        mosque_name: json['mosque_name'],
        mosque_image: json['mosque_image'],
        last_admin_name: json['admin_name'] ?? "",
        last_announcement_text: json['announcement_text'] ?? "",
        announcementDate: DateTime.parse(json['announcement_date'] ?? '0000-00-00 00:00:00')
    );
  }
}
