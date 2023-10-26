import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jadwal/admins/adminPreferences/current_admin.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:jadwal/mosques/mosquePreferences/mosquePreferences.dart';
import 'package:http/http.dart' as http;

class AdminHomeFragmentScreen extends StatefulWidget {
  @override
  _AdminHomeFragmentScreenState createState() => _AdminHomeFragmentScreenState();
}

class _AdminHomeFragmentScreenState extends State<AdminHomeFragmentScreen> {
  final CurrentMosque _currentMosque = Get.put(CurrentMosque());
  final CurrentAdmin _currentAdmin = Get.put(CurrentAdmin());
  late List<String> listOfTokens;
  bool _dataFetched = false; // Track if data has been fetched



  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes(); // Fetch the prayer times when the widget is initialized
    _fetchUserTokens();
  }

  Future<void> _fetchPrayerTimes() async {
    await _currentMosque.getMosqueInfo(); // Fetch the prayer times from the database
    setState(() {
      _dataFetched = true;
    }); // Trigger a rebuild after fetching the data
  }

  //image segment
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade900,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: Image.asset("images/mosque.png", width: 240,),
          ),

          const SizedBox(height: 20,),
          _dataFetched
              ? _buildPrayerTimeWidgets() // Build prayer time widgets if data is fetched
              : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching data

        ],
      ),
    );
  }

  //fetching user tokens
  void _fetchUserTokens() async {
    final res = await http.post(Uri.parse(API.fetchUserToken),
        body: {
          "mosque_id": _currentMosque.mosque.mosque_id.toString(),
        });
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      List<String> tokens = (data["tokens"] as List).map((token) => token.toString()).toList();
      listOfTokens = tokens;
      print(listOfTokens);
    } else {
      throw Exception('Failed to fetch tokens');
    }
  }

  ///sending notifications to the connected users
  Future<void> sendNotificationToConnectedUsers(String prayerName, TimeOfDay prayerTime) async {
    // Define the notification data
    var notification = {
      'title': '$prayerName time of ${_currentMosque.mosque.mosque_name} is updated',
      'body': '${_currentAdmin.admin.admin_name} updated the $prayerName time of ${_currentMosque.mosque.mosque_name}. The current time of $prayerName Jama-at is ${prayerTime.toString()}',
      'notification_count': 23,
    };

    var data = {
      'notification': notification,
      'data': {
        'type': 'schedule',
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


  //Time Controller
  timeController(String prayerName,TimeOfDay prayerTime) async {
    TimeOfDay ? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: prayerTime,
      builder: (context, child){
        return Theme(data: ThemeData.dark(), child: child!);
      },
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "Select $prayerName Time",
    );
    if(pickedTime != null && pickedTime != prayerTime){
      updateTimeNow(prayerName, pickedTime);
      return pickedTime;
    }
  }

  //Saving updated time into database
  updateTimeNow(String prayerName,TimeOfDay prayerTime) async {

    //string formation of dayOfTime
    String formatTimeOfDay(TimeOfDay time) {
    return "${time.hour}:${time.minute}";
  }
    try {
      var res = await http.post(Uri.parse(API.updateMosqueTime),
          body: {
            "mosque_id":_currentMosque.mosque.mosque_id.toString(),
            "mosque_name": _currentMosque.mosque.mosque_name,
            "admin_id": _currentAdmin.admin.admin_id.toString(),
            "admin_name": _currentAdmin.admin.admin_name,
            "prayer_name":prayerName,
            "prayer_time":formatTimeOfDay(prayerTime),
          });
      if(res.statusCode == 200){ //connection with api to server - Successful
        var resBody = jsonDecode(res.body);
        if(resBody['success']){
          Fluttertoast.showToast(msg: "Time Schedule of $prayerName is Successfully Updated");
          if(listOfTokens.isNotEmpty){
          sendNotificationToConnectedUsers(prayerName,prayerTime);
          }
        }
        else {
          Fluttertoast.showToast(msg: "Server don't responding");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }




Widget _buildPrayerTimeWidgets(){
    return Column(
      children: [
        const Text("Prayer Schedule",style: TextStyle(fontSize: 28,color: Colors.white70),),
        const Divider(color: Colors.white,),
        const SizedBox(height: 10,),
        //1st Tow Segments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //Fajr Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],


              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Fajr",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.fajr.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.fajr.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.fajr = await timeController("fajr",_currentMosque.mosque.fajr);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
            const SizedBox(width: 12,),

            //Zuhr Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Zuhr",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.zuhr.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.zuhr.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.zuhr = await timeController("zuhr",_currentMosque.mosque.zuhr);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
          ],
        ),

        const SizedBox(height: 12,),

        //2nd Tow Segments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            //Asr Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Asr",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.asr.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.asr.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.asr = await timeController("asr",_currentMosque.mosque.asr);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
            const SizedBox(width: 12,),

            //Maghrib Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Maghrib",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.maghrib.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.maghrib.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.maghrib = await timeController("maghrib",_currentMosque.mosque.maghrib);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
          ],
        ),

        const SizedBox(height: 12,),
//3ed Tow Segments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            //Isha Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Isha",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.isha.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.isha.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.isha = await timeController("isha",_currentMosque.mosque.isha);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
            const SizedBox(width: 12,),

            //Jumuah Time Segment
            Flexible(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.brown[300],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const Text(
                    "Jumuah",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  Text(
                    // prayerTime.value,
                    "${_currentMosque.mosque.jumuah.hour.toString().padLeft(2,"0")}:${_currentMosque.mosque.jumuah.minute.toString().padLeft(2,"0")}",
                    style: const TextStyle(
                      fontSize: 42,
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black,),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () async {
                      _currentMosque.mosque.jumuah = await timeController("jumuah",_currentMosque.mosque.jumuah);

                      //saving updated time data into local storage
                      await RememberMosquePrefs.storeMosqueInfo(_currentMosque.mosque);

                      setState(() {}); // Trigger a rebuild to reflect the changes
                    },
                  )
                ],
              ),
            )
            ),
          ],
        ),

        const SizedBox(height: 12,),

        // Add more widget boxes as needed
      ],
    );

}



}
