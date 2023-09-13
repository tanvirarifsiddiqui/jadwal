import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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
  late bool isConnected = false;

  @override
  void initState() {
    super.initState();
    getMosqueInfo();
    getMosqueConnectionStatus();
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

  getMosqueConnectionStatus()async{
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
            isConnected = true;
        }
        else {
            isConnected = false;
        }
      }else{
        Fluttertoast.showToast(msg: "Server Not Responding");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  sendMosqueConnectionStatus()async{
    try {
      var res = await http.post(Uri.parse(API.setConnectionStatus), body: {
        'connection_status': isConnected.toString(),
        'mosque_id': widget.mosqueId.toString(),
        'user_id': _currentUser.user.user_id.toString()
      });
      if (res.statusCode == 200) {
        //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if (resBodyOfMosqueData['success']) //Successfully Connected Or Disconnected
        {
          setState(() {
            isConnected = !isConnected;
          });
          if(isConnected){
            Fluttertoast.showToast(msg: "Successfully Connected");
          }else{
            Fluttertoast.showToast(msg: "Successfully Disconnected");
          }
        }
        else {
          Fluttertoast.showToast(msg: resBodyOfMosqueData['message']);
        }
      }else{
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
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Text(
              // prayerTime.value,
              "${prayerTime.hour.toString().padLeft(2, "0")}:${prayerTime.minute.toString().padLeft(2, "0")}",
              style: const TextStyle(
                fontSize: 42,
                color: Colors.black,
              ),
            )
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
              width: 10,
            ),
            Flexible(child: prayerTimeItem('Zuhr', _currentMosque!.zuhr)),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Asr', _currentMosque!.asr)),
            const SizedBox(
              width: 10,
            ),
            Flexible(child: prayerTimeItem('Maghrib', _currentMosque!.maghrib)),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Isha', _currentMosque!.isha)),
            const SizedBox(
              width: 10,
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
        ? Material(color: Colors.grey.shade900,
          child: ListView(
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
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                "${API.mosqueImage}${_currentMosque!.mosque_image}")),
                      )),
                )),

                const SizedBox(
                  height: 20,
                ),

                mosqueInfoItemProfile(Icons.mosque, _currentMosque!.mosque_name),
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
                            color: isConnected ? Colors.brown[800] : Color(0xffffff),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isConnected ? Colors.brown : Colors.brown.shade200,)
                        ),
                        child: Center(
                            child: Text(isConnected ? 'Disconnect' : 'Connect', style: TextStyle(
                              fontSize: 25,
                                color: isConnected ? Colors.white : Colors.brown[50]))
                        )
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildPrayerTimeWidgets(),

                mosqueInfoItemProfile(Icons.email, _currentMosque!.mosque_email),
                const SizedBox(
                  height: 10,
                ),

                mosqueInfoItemProfile(Icons.flag, _currentMosque!.mosque_country),
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
