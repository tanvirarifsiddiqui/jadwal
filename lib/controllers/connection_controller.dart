import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jadwal/api_connection/api_connection.dart';
class ConnectionController{

  static Future<String> getMosqueInfo(int mosqueId) async {
    String value = "null";
    try {
      var res = await http.post(Uri.parse(API.getTotalMosqueConnections), body: {
        'mosque_id': mosqueId.toString(),
      });
      if (res.statusCode == 200) {
        print(res.body);
        //connection with api to server - Successful
        var resBodyOfMosqueData = jsonDecode(res.body);

        if (resBodyOfMosqueData['success']) {
            //
        } else {
          //
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return value;
  }
}