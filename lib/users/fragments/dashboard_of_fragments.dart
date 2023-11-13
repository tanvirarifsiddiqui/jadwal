import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/users/fragments/announcement_fragment_screen.dart';
import 'package:jadwal/users/fragments/home_fragment_screen.dart';
import 'package:jadwal/users/fragments/notification_fragment_screen.dart';
import 'package:jadwal/users/fragments/profile_fragment_screen.dart';
import 'package:jadwal/users/fragments/search_fragment_screen.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;
import '../../api_connection/api_connection.dart';
import '../../controllers/notification_services(class).dart';

class DashboardOfFragments extends StatelessWidget {

  final CurrentUser _rememberCurrentUser = Get.put(CurrentUser());
  NotificationServices notificationServices = NotificationServices();

  final List<Widget> _fragmentScreens = [
    HomeFragmentScreen(),
    AnnouncementFragmentScreen(),
    MapAndSearchFragmentScreen(),
    NotificationFragmentScreen(),
    ProfileFragmentScreen()
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
      "label": "Messages"
    },

    {
      "active_icon": Icons.location_on,
      "non_active_icon": Icons.location_on_outlined,
      "label": "Map"
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
      init: CurrentUser(),
      initState: (currentState){
        //for notification
        notificationServices.requestNotificationPermission();
        notificationServices.firebaseInit(context);
        notificationServices.setupInteractMessage(context);
        //getting and storing user token for push notification
        notificationServices.getDeviceToken().then((value) async {
          var res = await http.post(Uri.parse(API.storeUserToken),
              body: {
              "user_id": _rememberCurrentUser.user.user_id.toString(),
              "token": value,
              });
          if(res.statusCode == 200){ //connection with api to server - Successful
            var resBody = jsonDecode(res.body);
            if(resBody['success']){
              print(resBody['message']);
            }
          }
        });

        _rememberCurrentUser.getUserInfo();
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
            unselectedItemColor: Colors.brown[400],
            items: List.generate(5, (index){
              var navBtnProperty = _navigationButtonsProperties[index];
              return BottomNavigationBarItem(
                backgroundColor: const Color(0xff2b0c0d),
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
