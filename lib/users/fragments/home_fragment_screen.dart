import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jadwal/api_connection/api_connection.dart';
import 'package:jadwal/mosques/model/user_home_mosque_model.dart';
import 'package:jadwal/mosques/profile/user_mosque_profile.dart';
import 'package:jadwal/users/searches/search_mosque.dart';
import 'package:jadwal/users/userPreferences/current_user.dart';
import 'package:jadwal/widgets/qr_section/user_qr_scan.dart';

import '../../controllers/users_fetch_info.dart';

class HomeFragmentScreen extends StatefulWidget {
  @override
  _HomeFragmentScreenState createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  bool _dataFetched = false;

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
    _fetchUserMosqueInfo();
  }

  //fetching mosque information to check data is fetched or not
  Future<void> _fetchUserMosqueInfo() async {
    await _currentUser
        .getUserInfo(); // Fetch the prayer times from the database
    ///big problem solved
    await _fetchConnectedMosqueInfo(); // Fetch the prayer times when the widget is initialized
    setState(() {
      _dataFetched = true;
    }); // Trigger a rebuild after fetching the data
  }

  //mosques list
  List<MosqueUserHome> _mosques = [];

  Future<void> _fetchConnectedMosqueInfo() async {
    if (_mosques.isEmpty) {
      await UsersServerOperation.fetchMosquesForHome(_currentUser.user.user_id)
          .then((mosqueList) {
        setState(() {
          _mosques = mosqueList;
        });
      }).catchError((error) {});
    }
  }

// function for new oreder saving to database
  Future<void> saveOrder() async {
    List<Map<String, dynamic>> reorderedMosqueOrder = [];

    for (int newIndex = 0; newIndex < _mosques.length; newIndex++) {
      reorderedMosqueOrder.add({
        "user_id": _currentUser.user.user_id,
        "mosque_id": _mosques[newIndex].mosque_id,
        "order_index": newIndex + 1,
      });
    }
    String reorderedMosqueOrderJson = json.encode(reorderedMosqueOrder);
    UsersServerOperation.sendMosqueOrder(reorderedMosqueOrderJson);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ()async{
        _mosques.clear();
        _dataFetched = false;
       await _fetchUserMosqueInfo();
      },
      child: Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: const Color(0xff2b0c0d),
            title: const Text(
              "Jadwal",
              style: TextStyle(color: Color(0xffbcaaa4), fontSize: 28),
            ),
            actions: [
              IconButton(
                  onPressed:(){
                    Get.to(()=>SearchMosqueScreen());
                  },
                  icon: const Icon(Icons.search_outlined,color: Color(0xffbcaaa4))
              ),
              IconButton(
                  onPressed:(){
                    Get.to(()=>const QRScanner());
                  },
                  icon: const Icon(Icons.qr_code_scanner,color: Color(0xffbcaaa4),)
              ),
            ],
          ),
          body: _dataFetched
              ? _mosques.isNotEmpty
                  ? ReorderableListView.builder(
                      itemCount: _mosques.length,
                      itemBuilder: (_, index) {
                        return Card(
                          key: ValueKey(_mosques[
                              index]), // Use ValueKey for ReorderableListView
                          color: Colors.brown[800],
                          elevation: 4,
                          child: Column(
                            children: [
                              ExpansionTile(
                                iconColor: Colors.white,
                                collapsedIconColor: Colors.white,
                                childrenPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                //mosque image name and address
                                title: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipOval(
                                          child: Container(
                                            width: 75,
                                            height: 75,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white60, // Adjust the border color
                                                  width: 2.5, // Adjust the border width
                                                ),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(API.mosqueImage+_mosques[index].mosque_image),
                                                )
                                            ),
                                          )
                                      ),
                                      const SizedBox(width:20),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.4,//solved by media query
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_mosques[index].mosque_name,softWrap: true, style: const TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500)),
                                              const SizedBox(height: 5,),
                                              Text(_mosques[index].mosque_address, softWrap: true, style: TextStyle(color: Colors.brown[200],fontSize: 16)),
                                            ]
                                        ),
                                      ),
                                      const Spacer()
                                    ],
                                  ),
                                ),
                                children: [
                                  const Text("Prayer Schedule",style: TextStyle(fontSize: 28,color: Colors.white70),),
                                  const Divider(thickness: 1.5, color: Colors.white70,),
                                  const SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(child: prayerTimeItem('Fajr', _mosques[index].fajr)),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Flexible(child: prayerTimeItem('Zuhr', _mosques[index].zuhr)),
                                    ],
                                  ),

                                  const SizedBox(height: 4,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(child: prayerTimeItem('Asr', _mosques[index].asr)),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Flexible(child: prayerTimeItem('Maghrib', _mosques[index].maghrib)),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(child: prayerTimeItem('Isha', _mosques[index].isha)),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Flexible(child: prayerTimeItem('Jumuah', _mosques[index].jumuah)),
                                    ],
                                  ),

                                  const SizedBox(height: 20,),
                                  // This button is used to remove this item
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => UserMosqueProfile(
                                          mosqueId: _mosques[index].mosque_id));
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.brown[900],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.brown.shade200,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'View Profile',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.brown[50],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                              // todo apply another features here
                            ],
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        // Handle the reorder logic here
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -=
                                1; // Adjust the new index after removing the item
                          }
                          //reordering mosque list
                          final draggedMosque = _mosques.removeAt(
                              oldIndex); //removing mosque from old index
                          _mosques.insert(newIndex,
                              draggedMosque); //assigning mosque to new index
                        });

                        /// save this order in database
                        saveOrder();
                      },
                    )
                  : const Center(
                      child: Text(
                        "No Connected Mosque Found",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
              : const Center(child: CircularProgressIndicator())),
    );
  }

  Widget prayerTimeItem(String prayerName, TimeOfDay prayerTime) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Colors.white54, // Adjust the border color
          width: 2, // Adjust the border width
        ),
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
              thickness: 1.25,
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
}
