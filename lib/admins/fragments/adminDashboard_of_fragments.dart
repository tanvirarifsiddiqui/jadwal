import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/admins/fragments/admin_home_fragment_screen.dart';
import 'package:jadwal/admins/fragments/mosque_fragment_screen.dart';
import 'package:jadwal/admins/fragments/admin_notification_fragment_screen.dart';
import 'package:jadwal/admins/fragments/admin_announcement_fragment_screen.dart';
import 'package:jadwal/admins/fragments/admin_profile_fragment_screen.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:http/http.dart' as http;
import '../../api_connection/api_connection.dart';
import '../../controllers/notification_services(class).dart';

class AdminDashboardOfFragments extends StatelessWidget {
  NotificationServices notificationServices = NotificationServices();
  final CurrentAdmin _rememberCurrentAdmin = Get.put(CurrentAdmin());
  final CurrentMosque _rememberCurrentMosque = Get.put(CurrentMosque());

  final List<Widget> _fragmentScreens = [
    AdminHomeFragmentScreen(),
    AdminAnnouncementFragmentScreen(),
    MosqueFragmentScreen(),
    AdminNotificationFragmentScreen(),
    AdminProfileFragmentScreen()
  ];

  final List _navigationButtonsProperties = [
    {
      "active_icon": Icons.home,
      "non_active_icon": Icons.home_outlined,
      "label": "Home"
    },

    {
      "active_icon": Icons.message,
      "non_active_icon": Icons.message_outlined,
      "label": "Message"
    },

    {
      "active_icon": Icons.mosque,
      "non_active_icon": Icons.mosque_outlined,
      "label": "Mosque"
    },

    {
      "active_icon": Icons.notifications_active,
      "non_active_icon": Icons.notifications_active_outlined,
      "label": "Notification"
    },

    {
      "active_icon": Icons.person,
      "non_active_icon": Icons.person_outline,
      "label": "Profile"
    },
  ];

  final RxInt _indexNumber = 0.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CurrentAdmin(),
      initState: (currentState){
        //for notification
        notificationServices.requestNotificationPermission();
        notificationServices.firebaseInit(context);
        notificationServices.setupInteractMessage(context);
        //getting and storing admin token for push notification
        notificationServices.getDeviceToken().then((value) async {
          var res = await http.post(Uri.parse(API.storeAdminToken),
              body: {
                "admin_id": _rememberCurrentAdmin.admin.admin_id.toString(),
                "token": value,
              });
          if(res.statusCode == 200){ //connection with api to server - Successful
            var resBody = jsonDecode(res.body);
            if(resBody['success']){
              print(resBody['message']);
            }
          }
        });
        _rememberCurrentAdmin.getAdminInfo();
        _rememberCurrentMosque.getMosqueInfo();
      },
      builder: (controller){
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Obx(() => _fragmentScreens[_indexNumber.value]),
          ),
          bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: _indexNumber.value,
            onTap: (value){
              _indexNumber.value = value;
            },
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Colors.brown[50],
            unselectedItemColor: Colors.brown[500],
            items: List.generate(5, (index){
              var navBtnProperty = _navigationButtonsProperties[index];
              return BottomNavigationBarItem(
                backgroundColor: Colors.black87,
                icon: Icon(navBtnProperty["non_active_icon"]),
                activeIcon: Icon(navBtnProperty["active_icon"]),
                label: navBtnProperty["label"],
              );
            }),
          )),
        );
      },
    );
  }
}
