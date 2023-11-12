import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/users/authentication/login_screen.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';
import 'package:jadwal/users/userPreferences/userPreferences.dart';
import 'package:http/http.dart' as http;
import '../../controllers/notification_services(class).dart';

class ProfileFragmentScreen extends StatelessWidget {
  NotificationServices notificationServices = NotificationServices();

  Widget userInfoItemProfile(IconData iconData, String adminData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white54, // Adjust the border color
          width: 2, // Adjust the border width
        ),
        color: Colors.brown[300],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Text(
              adminData,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final CurrentUser _currentUser = Get.put(CurrentUser());

  logOutUser() async {
    var resultResponse = await Get.dialog(AlertDialog(
      backgroundColor: Colors.brown[300],
      title: const Text(
        "logout",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: const Text("Are you sure?\nYou want to logout from app?"),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "No",
              style: TextStyle(color: Colors.black),
            )),
        TextButton(
            onPressed: () {
              Get.back(result: "loggedOut");
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.black),
            ))
      ],
    ));
    if (resultResponse == "loggedOut") {
      //delete user data from local storage
      notificationServices.getDeviceToken().then((value) async {
        var res = await http.post(Uri.parse(API.deleteUserToken), body: {
          "token": value,
        });
        if (res.statusCode == 200) {
          //connection with api to server - Successful
          var resBody = jsonDecode(res.body);
          if (resBody['success']) {
            RememberUserPrefs.removeUserInfo().then((value) {
              Get.offAll(LoginScreen());
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade900,
      appBar: AppBar(
        backgroundColor: const Color(0xff2b0c0d),
        title: const Center(
          child: Text(
            "User's Profile",
            style: TextStyle(color: Colors.white70, fontSize: 32),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          //profile image
          Center(
              child: ClipOval(
            child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white60, // Adjust the border color
                    width: 4, // Adjust the border width
                  ),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          "${API.userImage}${_currentUser.user.user_image}")),
                )),
          )),

          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(Icons.person, _currentUser.user.user_name),
          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(Icons.email, _currentUser.user.user_email),
          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(Icons.flag, _currentUser.user.user_country),
          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(
              Icons.location_city, _currentUser.user.user_state),
          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(Icons.house, _currentUser.user.user_city),
          const SizedBox(
            height: 20,
          ),

          userInfoItemProfile(
              Icons.location_pin, _currentUser.user.user_address),
          const SizedBox(
            height: 20,
          ),

          Center(
            child: Material(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  logOutUser();
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
