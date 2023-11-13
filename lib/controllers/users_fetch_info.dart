import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:jadwal/mosques/model/connectors_model.dart';
import 'package:jadwal/mosques/model/search_mosque_model.dart';
import 'package:jadwal/mosques/model/user_announcement_mosque_model.dart';
import 'package:jadwal/mosques/model/user_home_mosque_model.dart';
import 'package:jadwal/widgets/notifications/user_notification_model.dart';

import '../widgets/notifications/admin_notification_model.dart';

class UsersServerOperation{
  // Function to fetch mosques for user search
  static Future<List<SearchedMosque>> fetchMosquesForSearch() async {
    List<SearchedMosque> mosques = [];
    try {
      var res = await http.get(Uri.parse(API.getSearchedMosqueData));//fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of mosques
          List<dynamic> mosqueList = data['mosques'];
          mosques = mosqueList.map((mosqueData) {
            return SearchedMosque.fromJson(mosqueData);
          }).toList();
        } else {
          Fluttertoast.showToast(msg: "Failed to fetch mosques");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return mosques;
  }

//Function to fetch Mosques for user Home Screen
  static Future<List<MosqueUserHome>> fetchMosquesForHome(int userId) async {
    List<MosqueUserHome> mosques = [];
    try {
      var res = await http.post(Uri.parse(API.getUserHomeMosqueData),body: {
        'user_id': userId.toString()
      });
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of mosques
          List<dynamic> mosqueList = data['mosques'];
          mosques = mosqueList.map((mosqueData) {
            return MosqueUserHome.fromJson(mosqueData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return mosques;
  }

  static Future<List<MosqueChatModel>> fetchMosquesForAnnouncement(int userId) async {
    List<MosqueChatModel> mosques = [];
    try {
      var res = await http.post(Uri.parse(API.getUserChatMosqueData),body: {
        'user_id': userId.toString()
      });
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of mosques
          List<dynamic> mosqueList = data['mosques'];
          mosques = mosqueList.map((mosqueData) {
            return MosqueChatModel.fromJson(mosqueData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return mosques;
  }

  static Future<List<UserNotificationModel>> fetchUserNotifications(int userId, {int page = 1}) async {
    List<UserNotificationModel> notifications = [];
    try {
      var res = await http.post(Uri.parse(API.getNotifications),body: {
        'user_id': userId.toString(),
        'page':page.toString(),
      });
      //fetching notification data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of notifications
          List<dynamic> notificationList = data['notifications'];
          notifications = notificationList.map((notificationData) {
            return UserNotificationModel.fromJson(notificationData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return notifications;
  }

  static Future<List<AdminNotificationModel>> fetchAdminNotifications(int adminId,int mosqueId, {int page = 1}) async {
    List<AdminNotificationModel> notifications = [];
    try {
      var res = await http.post(Uri.parse(API.getAdminNotifications),body: {
        'mosque_id': mosqueId.toString(),
        'admin_id': adminId.toString(),
        'page':page.toString(),
      });
      //fetching notification data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of notifications
          List<dynamic> notificationList = data['notifications'];
          notifications = notificationList.map((notificationData) {
            return AdminNotificationModel.fromJson(notificationData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return notifications;
  }

  static Future<List<ConnectorsModel>> fetchTotalConnectors(int mosqueId, {int page = 1}) async {
    List<ConnectorsModel> notifications = [];
    try {
      var res = await http.post(Uri.parse(API.getTotalConnectors),body: {
        'mosque_id': mosqueId.toString(),
        'page':page.toString(),
      });
      //fetching notification data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          // Parse the list of notifications
          List<dynamic> connectorList = data['connectedUsers'];
          notifications = connectorList.map((notificationData) {
            return ConnectorsModel.fromJson(notificationData);
          }).toList();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return notifications;
  }

  //sending reordered data to the server
  static sendMosqueOrder(String mosqueOrder) async {
    try {
      final res = await http.post(
        Uri.parse(API.setUserHomeMosqueOrder),
        body: mosqueOrder,
        headers: {'Content-Type': 'application/json'},
      );
      //fetching mosque data
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success']) {
          }
        } else {
          Fluttertoast.showToast(msg: "Failed send new mosque order to database");
        }

    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

}
