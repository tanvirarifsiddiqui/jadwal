import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';
import 'package:jadwal/mosques/profile/user_mosque_profile.dart';

class HomeFragmentScreen extends StatefulWidget {
  @override
  _HomeFragmentScreenState createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  final CurrentMosque _currentMosque1 = Get.put(CurrentMosque());

  bool _dataFetched = false; // Track if data has been fetched

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes(); // Fetch the prayer times when the widget is initialized
  }

  Future<void> _fetchPrayerTimes() async {
    await _currentMosque1
        .getMosqueInfo(); // Fetch the prayer times from the database
    setState(() {
      _dataFetched = true;
    }); // Trigger a rebuild after fetching the data
  }

  ///source code for expansion Tile
  final List<Map<String, dynamic>> _items = List.generate(
      5,
      (index) => {
            "id": index,
            "title": "Mosque $index",
            "content":
                "This is the main content of item $index. It is very long and you have to expand the tile to see it."
          });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final item = _items[index];
                return Card(
                  key: PageStorageKey(item['id']),
                  color: Colors.brown[700],
                  elevation: 4,
                  child: ExpansionTile(
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      childrenPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      // expandedCrossAxisAlignment: CrossAxisAlignment.end,
                      title: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      children: [
                        Text(item['content'],
                            style: const TextStyle(color: Colors.white)),
                        SizedBox(height: 15,),
                        // This button is used to remove this item
                        GestureDetector(
                          onTap: () {
                            Get.to(()=>UserMosqueProfile(mosqueId: 48));
                          },
                          child: Container(
                              height: 35,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.brown[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.brown.shade200,)
                              ),
                              child: Center(
                                  child: Text('View Profile', style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.brown[50]))
                              )
                          ),
                        ),
                      ]),
                );
              })

    );
  }
//todo uncommentable under listview.builder
// _dataFetched
//     ? _buildPrayerTimeWidgets() // Build prayer time widgets if data is fetched
//     : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching data
  //todo later uncomment
  //Mosque Name widget
  // Widget mosqueName(String mosqueName){
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       color: Colors.brown[400],
  //     ),
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 16,
  //       vertical: 8,
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.mosque,size: 30,color: Colors.black,),
  //         const SizedBox(width: 16,),
  //         Center(
  //           child: Text(
  //             mosqueName,
  //             style: const TextStyle(
  //               fontSize: 18,
  //               color: Colors.amberAccent
  //
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // //prayer time widget item
  // Widget prayerTimeItem(String prayerName, TimeOfDay prayerTime) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15),
  //       color: Colors.brown[400],
  //     ),
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 8,
  //       vertical: 8,
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           prayerName,
  //           style: const TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white70,
  //           ),
  //         ),
  //         const Divider(color: Colors.white,),
  //         Text(
  //           // prayerTime.value,
  //           "${prayerTime.hour.toString().padLeft(2,"0")}:${prayerTime.minute.toString().padLeft(2,"0")}",
  //           style: const TextStyle(
  //             fontSize: 42,
  //             color: Colors.white70,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildPrayerTimeWidgets(){
  //   return Column(
  //     children: [
  //       mosqueName(_currentMosque1.mosque.mosque_name),
  //       const SizedBox(height: 12,),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Flexible(child: prayerTimeItem('Fajr', _currentMosque1.mosque.fajr)),
  //           const SizedBox(width: 12,),
  //           Flexible(child: prayerTimeItem('Zuhr', _currentMosque1.mosque.zuhr)),
  //         ],
  //       ),
  //
  //       const SizedBox(height: 12,),
  //
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Flexible(child: prayerTimeItem('Asr', _currentMosque1.mosque.asr)),
  //           const SizedBox(width: 12,),
  //           Flexible(child: prayerTimeItem('Maghrib', _currentMosque1.mosque.maghrib)),
  //         ],
  //       ),
  //
  //       const SizedBox(height: 12,),
  //
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Flexible(child: prayerTimeItem('Isha', _currentMosque1.mosque.isha)),
  //           const SizedBox(width: 12,),
  //           Flexible(child: prayerTimeItem('Jumuah', _currentMosque1.mosque.jumuah)),
  //         ],
  //       ),
  //
  //       const SizedBox(height: 12,),
  //
  //       // Add more widget boxes as needed
  //     ],
  //   );
  //
  // }
}
