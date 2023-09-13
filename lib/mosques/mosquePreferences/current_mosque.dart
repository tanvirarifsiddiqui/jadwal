import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/mosques/mosquePreferences/mosquePreferences.dart';
import 'package:jadwal/mosques/model/mosque.dart';

class CurrentMosque extends GetxController{

  final Rx<Mosque> _currentMosque = Mosque(0, '', '', '', '', '','','','',TimeOfDay.now(),TimeOfDay.now(),TimeOfDay.now(),TimeOfDay.now(),TimeOfDay.now(),TimeOfDay.now()).obs;

  Mosque get mosque=> _currentMosque.value;



  getMosqueInfo() async {
    Mosque? getMosqueInfoFromLocalStorage = await RememberMosquePrefs.readMosqueInfo();
    if (getMosqueInfoFromLocalStorage != null) {
      _currentMosque.value = getMosqueInfoFromLocalStorage;
    }
  }
}

