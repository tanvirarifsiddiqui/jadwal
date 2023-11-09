import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';
import '../../api_connection/api_connection.dart';
import '../model/mosque.dart';
import 'package:http/http.dart' as http;

class UserMosqueProfile extends StatefulWidget {
  final int mosqueId;

  const UserMosqueProfile({
    required this.mosqueId,
    Key? key,
  }) : super(key: key);

  @override
  State<UserMosqueProfile> createState() => _UserMosqueProfileState();
}

//main portion
class _UserMosqueProfileState extends State<UserMosqueProfile> {
  Mosque? _currentMosque;
  final CurrentUser _currentUser = Get.put(CurrentUser());
  late List<String> listOfTokens;
  late bool isConnected = false;

  // Function to format TimeOfDay as AM/PM
  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final timeToFormat = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime = DateFormat.jm().format(timeToFormat);
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    getMosqueInfo();
    getMosqueConnectionStatus();
    _fetchAdminTokens();
  }

  //fetching admin tokens
  void _fetchAdminTokens() async {
    final res = await http.post(Uri.parse(API.fetchAdminToken),
        body: {
          "mosque_id": widget.mosqueId.toString(),
        });
    if (res.statusCode == 200) {
      print(res.body);
      final Map<String, dynamic> data = json.decode(res.body);
      List<String> tokens = (data["tokens"] as List).map((token) => token.toString()).toList();
      listOfTokens = tokens;
    } else {
      throw Exception('Failed to fetch tokens');
    }
  }

  ///sending notifications to the connected users
  Future<void> notifyAdmin() async {
    // Define the notification data
    var notification = {
      'title': 'A new person has connected to your mosque',
      'body': '${_currentUser.user.user_name} has been connected with this mosque',
      'image': '${API.userImage}${_currentUser.user.user_image}',
      'notification_count': 23,
    };

    var data = {
      'notification': notification,
      'data': {
        'type': 'connection',
        'id' : 'tanvir',
      }
    };

    // Define the FCM server URL
    var fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Define your FCM server key
    var fcmServerKey = 'AAAALPXowd4:APA91bGXQ7jXzw5KXMQ97gRCvslUfvuDGHQiDyCSa1HmlDSyvzw6abYLZFvcZ6n_E0kc3H-cFHL_L9A0i7hSK5BmaSjr7tzl6JQX7j_oUg3M7Ul7oDWnLjDyLVcol3NT-wzCv038oyW1';

    for (var token in listOfTokens) {
      // Send the notification to the current token
      try {
        final response = await http.post(
          fcmUrl,
          body: jsonEncode({
            'to': token,
            'notification': notification,
            'data': data['data'],
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=$fcmServerKey',
          },
        );
        if (kDebugMode) {
          print(response.body.toString());
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }

  //get Mosque Information
  getMosqueInfo() async {
    try {
      var res = await http.post(Uri.parse(API.getMosqueDataById), body: {
        'mosque_id': widget.mosqueId.toString(),
      });
      if (res.statusCode == 200) {
        //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if (resBodyOfMosqueData['success']) {
          setState(() {
            _currentMosque = Mosque.fromJson(resBodyOfMosqueData["mosqueData"]);
          });
        } else {
          Fluttertoast.showToast(msg: "Mosque Not found");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  getMosqueConnectionStatus() async {
    try {
      var res = await http.post(Uri.parse(API.getConnectionStatus), body: {
        'mosque_id': widget.mosqueId.toString(),
        'user_id': _currentUser.user.user_id.toString()
      });
      if (res.statusCode == 200) {
        //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if (resBodyOfMosqueData['success']) //Successfully Connected Or Disconnected
        {
          setState(() {
          isConnected = true;
          });
        } else {
          setState(() {
          isConnected = false;
          });
        }

      } else {
        Fluttertoast.showToast(msg: "Server Not Responding");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  sendMosqueConnectionStatus() async {
    try {
      var res = await http.post(Uri.parse(API.setConnectionStatus), body: {
        'connection_status': isConnected.toString(),
        'mosque_id': widget.mosqueId.toString(),
        'user_id': _currentUser.user.user_id.toString(),
        'user_name': _currentUser.user.user_name
      });
      if (res.statusCode == 200) {
        //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if (resBodyOfMosqueData['success']) //Successfully Connected Or Disconnected
        {
          setState(() {
            isConnected = !isConnected;
            getMosqueInfo();
          });
          if (isConnected) {
            // sending push notification to the admin
            notifyAdmin();
            Fluttertoast.showToast(msg: "Successfully Connected");
          } else {
            Fluttertoast.showToast(msg: "Successfully Disconnected");
          }
        } else {
          Fluttertoast.showToast(msg: resBodyOfMosqueData['message']);
        }
      } else {
        Fluttertoast.showToast(msg: "Server Not Responding");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //Card widget item for showing mosque information
  Widget mosqueInfoItemProfile(IconData iconData, String mosqueData) {
    return Card(
      elevation: 3, // Adjust the elevation for the shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.brown[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 30,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                mosqueData,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //prayer time widget item
  Widget prayerTimeItem(String prayerName, TimeOfDay prayerTime) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.brown[300],
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
          children: [
            Text(
              prayerName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Text(
              formatTime(prayerTime),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //inside row view of prayer time
  Widget _buildPrayerTimeWidgets() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Fajr', _currentMosque!.fajr)),
            const SizedBox(
              width: 4,
            ),
            Flexible(child: prayerTimeItem('Zuhr', _currentMosque!.zuhr)),
          ],
        ),

        const SizedBox(
          height: 4,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Asr', _currentMosque!.asr)),
            const SizedBox(
              width: 4,
            ),
            Flexible(child: prayerTimeItem('Maghrib', _currentMosque!.maghrib)),
          ],
        ),

        const SizedBox(
          height: 4,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Isha', _currentMosque!.isha)),
            const SizedBox(
              width: 4,
            ),
            Flexible(child: prayerTimeItem('Jumuah', _currentMosque!.jumuah)),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        // Add more widget boxes as needed
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _currentMosque != null
        ? Material(
            color: Colors.brown.shade800,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                //profile image
                Center(
                    child: ClipOval(
                      child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                "${API.mosqueImage}${_currentMosque!.mosque_image}")),
                      )),
                )),

                const SizedBox(
                  height: 20,
                ),

                //mosque name and connectors
                mosqueInfoItemProfile(
                    Icons.mosque, _currentMosque!.mosque_name),
                const SizedBox(
                  height: 10,
                ),
                mosqueInfoItemProfile(Icons.connect_without_contact,
                    "${_currentMosque!.connectors} connectors"),
                const SizedBox(
                  height: 10,
                ),

                //connect button
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        //sending connection states to the database
                        sendMosqueConnectionStatus();
                      });
                    },
                    child: AnimatedContainer(
                        height: 45,
                        width: 100,
                        duration: const Duration(milliseconds: 80),
                        decoration: BoxDecoration(
                            color: isConnected
                                ? Colors.brown[900]
                                : Color(0xffffff),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isConnected
                                  ? Colors.brown
                                  : Colors.brown.shade200,
                            )),
                        child: Center(
                            child: Text(isConnected ? 'Disconnect' : 'Connect',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: isConnected
                                        ? Colors.white
                                        : Colors.brown[50])))),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                const Center(child: Text("Prayer Schedule",style: TextStyle(fontSize: 28,color: Colors.white70),)),
                const Divider(color: Colors.white,),
                const SizedBox(height: 10,),
                _buildPrayerTimeWidgets(),

                mosqueInfoItemProfile(
                    Icons.email, _currentMosque!.mosque_email),
                const SizedBox(
                  height: 10,
                ),

                mosqueInfoItemProfile(
                    Icons.flag, _currentMosque!.mosque_country),
                const SizedBox(
                  height: 10,
                ),

                mosqueInfoItemProfile(
                    Icons.location_city, _currentMosque!.mosque_state),
                const SizedBox(
                  height: 10,
                ),

                mosqueInfoItemProfile(Icons.house, _currentMosque!.mosque_city),
                const SizedBox(
                  height: 10,
                ),

                mosqueInfoItemProfile(
                    Icons.location_pin, _currentMosque!.mosque_address),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
