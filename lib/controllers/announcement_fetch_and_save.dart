import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/widgets/message/announcement_model.dart';

class AnnouncementOperation{

//Function to fetch Mosques for user Home Screen
  static Future<List<AnnouncementModel>> fetchAnnouncements(int mosqueId, {int page = 1}) async {
    List<AnnouncementModel> announcements = [];
    try {
      var res = await http.post(Uri.parse(API.getAnnouncements), body: {
        'mosque_id': mosqueId.toString(),
        'page': page.toString(), // Include the page parameter
      });
      // Fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        if (data['success']) {
          // Parse the list of announcements
          List<dynamic> announcementList = data['announcements'];
          announcements = announcementList.map((announcementData) {
            return AnnouncementModel.fromJson(announcementData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return announcements;
  }


  //send Announcement
  static sendAnnouncement(int adminId, String announcementText) async {
    try {
      final res = await http.post(
        Uri.parse(API.sendAnnouncements),
        body: {
            'admin_id' : adminId.toString(),
            'announcement_text' : announcementText,
        },
      );
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          Fluttertoast.showToast(msg: "Successfully Sent Announcement");
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to send Announcement");
      }

    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


}
