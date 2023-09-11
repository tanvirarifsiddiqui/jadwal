import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/mosques/mosquePreferences/current_mosque.dart';

class HomeFragmentScreen extends StatefulWidget {
  @override
  _HomeFragmentScreenState createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  final CurrentMosque _currentMosque1 = Get.put(CurrentMosque());
  final CurrentMosque _currentMosque2 = Get.put(CurrentMosque());
  final CurrentMosque _currentMosque3 = Get.put(CurrentMosque());

  bool _dataFetched = false; // Track if data has been fetched


  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes(); // Fetch the prayer times when the widget is initialized
  }

  Future<void> _fetchPrayerTimes() async {
    await _currentMosque1.getMosqueInfo(); // Fetch the prayer times from the database
    setState(() {
      _dataFetched = true;
    }); // Trigger a rebuild after fetching the data
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }

  //Mosque Name widget
  Widget mosqueName(String mosqueName){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.brown[400],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(Icons.mosque,size: 30,color: Colors.amberAccent,),
          const SizedBox(width: 16,),
          Center(
            child: Text(
              mosqueName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.amberAccent

              ),
            ),
          )
        ],
      ),
    );
  }

  //prayer time widget item
  Widget prayerTimeItem(String prayerName, TimeOfDay prayerTime) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.brown[400],
      ),
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
              color: Colors.white70,
            ),
          ),
          const Divider(color: Colors.white,),
          Text(
            // prayerTime.value,
            "${prayerTime.hour.toString().padLeft(2,"0")}:${prayerTime.minute.toString().padLeft(2,"0")}",
            style: const TextStyle(
              fontSize: 42,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPrayerTimeWidgets(){
    return Column(
      children: [
        mosqueName(_currentMosque1.mosque.mosque_name),
        const SizedBox(height: 12,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Fajr', _currentMosque1.mosque.fajr)),
            const SizedBox(width: 12,),
            Flexible(child: prayerTimeItem('Zuhr', _currentMosque1.mosque.zuhr)),
          ],
        ),

        const SizedBox(height: 12,),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Asr', _currentMosque1.mosque.asr)),
            const SizedBox(width: 12,),
            Flexible(child: prayerTimeItem('Maghrib', _currentMosque1.mosque.maghrib)),
          ],
        ),

        const SizedBox(height: 12,),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: prayerTimeItem('Isha', _currentMosque1.mosque.isha)),
            const SizedBox(width: 12,),
            Flexible(child: prayerTimeItem('Jumuah', _currentMosque1.mosque.jumuah)),
          ],
        ),

        const SizedBox(height: 12,),

        // Add more widget boxes as needed
      ],
    );

  }




}
