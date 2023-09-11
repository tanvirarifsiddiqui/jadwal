import 'dart:convert';
import 'package:jadwal/mosques/model/mosque.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberMosquePrefs{
  // save-remember Mosque-info
  static Future<void> storeMosqueInfo(Mosque mosqueInfo) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String mosqueJsonData = jsonEncode(mosqueInfo.toJson());
    await preferences.setString("currentMosque", mosqueJsonData);
  }

  //get read Mosque-info
  static Future<Mosque?> readMosqueInfo() async{
    Mosque? currentMosqueInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? mosqueInfo = preferences.getString("currentMosque");
    if(mosqueInfo != null){
      Map<String, dynamic> mosqueDataMap = jsonDecode(mosqueInfo);
      currentMosqueInfo = Mosque.fromJson(mosqueDataMap);
    }
    return currentMosqueInfo;
  }

  static Future<void> removeMosqueInfo()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentMosque");
  }
}